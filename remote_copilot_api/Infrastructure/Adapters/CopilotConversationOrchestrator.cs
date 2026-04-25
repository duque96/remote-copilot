using System.Text.Json;
using GitHub.Copilot.SDK;
using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Domain.Events;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Domain.Services;
using RemoteCopilot.Api.Infrastructure.Managers;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Infrastructure.Adapters;

public sealed class CopilotConversationOrchestrator(
    CopilotClientAccessor clientAccessor,
    CopilotPermissionService permissionService,
    IRemoteSessionRepository remoteSessionRepository,
    IConversationRepository conversationRepository,
    IConversationStreamPublisher streamPublisher,
    IOptions<CopilotOptions> options,
    ILogger<CopilotConversationOrchestrator> logger)
    : ICopilotConversationOrchestrator
{
    public Task RunAsync(
        WorkspaceDefinition? workspace,
        RemoteSession session,
        ConversationThread conversation,
        ConversationMessage userMessage,
        ConversationMessage assistantMessage,
        string prompt,
        string? model,
        CancellationToken cancellationToken)
    {
        return Task.Run(
            async () =>
            {
                try
                {
                    var client = await clientAccessor.GetClientAsync(cancellationToken);
                    await using var copilotSession = await OpenSessionAsync(client, workspace, session, model, cancellationToken);

                    var completion = new TaskCompletionSource<(string Content, string? Error)>(
                        TaskCreationOptions.RunContinuationsAsynchronously);

                    string finalContent = string.Empty;
                    string? finalError = null;

                    using var subscription = copilotSession.On(evt =>
                    {
                        _ = streamPublisher.PublishAsync(
                            CreateSdkStreamEvent(evt, conversation.Id, userMessage, assistantMessage),
                            CancellationToken.None);

                        switch (evt)
                        {
                            case AssistantMessageEvent messageEvent when string.IsNullOrWhiteSpace(messageEvent.Data?.ParentToolCallId):
                                finalContent = messageEvent.Data?.Content ?? finalContent;
                                break;

                            case SessionTitleChangedEvent titleChangedEvent when !string.IsNullOrWhiteSpace(titleChangedEvent.Data?.Title):
                                _ = remoteSessionRepository.UpdateTitleAsync(
                                    session.Id,
                                    titleChangedEvent.Data!.Title,
                                    CancellationToken.None);
                                break;

                            case SessionErrorEvent errorEvent:
                                finalError = errorEvent.Data?.Message ?? "An unknown Copilot session error occurred.";
                                break;

                            case SessionIdleEvent:
                                completion.TrySetResult((finalContent, finalError));
                                break;
                        }
                    });

                    await copilotSession.SendAsync(
                        new MessageOptions
                        {
                            Prompt = prompt,
                        });

                    var outcome = await completion.Task.WaitAsync(TimeSpan.FromMinutes(10), cancellationToken);

                    if (!string.IsNullOrWhiteSpace(outcome.Error))
                    {
                        await conversationRepository.UpdateMessageAsync(
                            assistantMessage.Id,
                            outcome.Content,
                            "failed",
                            outcome.Error,
                            cancellationToken);

                        return;
                    }

                    await conversationRepository.UpdateMessageAsync(
                        assistantMessage.Id,
                        outcome.Content,
                        "completed",
                        null,
                        cancellationToken);

                    await remoteSessionRepository.TouchAsync(session.Id, cancellationToken);
                }
                catch (Exception exception)
                {
                    logger.LogError(exception, "Failed to execute Copilot conversation for session {SessionId}.", session.Id);

                    await conversationRepository.UpdateMessageAsync(
                        assistantMessage.Id,
                        string.Empty,
                        "failed",
                        exception.Message,
                        CancellationToken.None);
                }
            },
            cancellationToken);
    }

    private static ConversationStreamEvent CreateSdkStreamEvent(
        SessionEvent sessionEvent,
        string conversationId,
        ConversationMessage userMessage,
        ConversationMessage assistantMessage)
    {
        using var document = JsonDocument.Parse(sessionEvent.ToJson());
        var root = document.RootElement;

        var type = root.TryGetProperty("type", out var typeElement)
            ? typeElement.GetString() ?? "unknown"
            : "unknown";
        var timestamp = root.TryGetProperty("timestamp", out var timestampElement)
            && timestampElement.ValueKind == JsonValueKind.String
            && timestampElement.TryGetDateTimeOffset(out var parsedTimestamp)
                ? parsedTimestamp
                : DateTimeOffset.UtcNow;
        JsonElement? data = root.TryGetProperty("data", out var dataElement)
            ? dataElement.Clone()
            : null;

        return new ConversationStreamEvent(
            type,
            conversationId,
            timestamp,
            ResolveMessageId(sessionEvent, userMessage, assistantMessage),
            root.TryGetProperty("id", out var idElement) ? idElement.GetString() : null,
            root.TryGetProperty("parentId", out var parentIdElement) ? parentIdElement.GetString() : null,
            root.TryGetProperty("ephemeral", out var ephemeralElement)
            && ephemeralElement.ValueKind is JsonValueKind.True or JsonValueKind.False
            && ephemeralElement.GetBoolean(),
            "sdk",
            data);
    }

    private static string? ResolveMessageId(
        SessionEvent sessionEvent,
        ConversationMessage userMessage,
        ConversationMessage assistantMessage) =>
        sessionEvent switch
        {
            UserMessageEvent => userMessage.Id,
            AssistantMessageEvent messageEvent when string.IsNullOrWhiteSpace(messageEvent.Data?.ParentToolCallId) => assistantMessage.Id,
            AssistantMessageDeltaEvent deltaEvent when string.IsNullOrWhiteSpace(deltaEvent.Data?.ParentToolCallId) => assistantMessage.Id,
            AssistantTurnStartEvent => assistantMessage.Id,
            AssistantIntentEvent => assistantMessage.Id,
            AssistantReasoningEvent => assistantMessage.Id,
            AssistantReasoningDeltaEvent => assistantMessage.Id,
            AssistantStreamingDeltaEvent => assistantMessage.Id,
            AssistantTurnEndEvent => assistantMessage.Id,
            AssistantUsageEvent => assistantMessage.Id,
            AbortEvent => assistantMessage.Id,
            ToolUserRequestedEvent => assistantMessage.Id,
            ToolExecutionStartEvent => assistantMessage.Id,
            ToolExecutionPartialResultEvent => assistantMessage.Id,
            ToolExecutionProgressEvent => assistantMessage.Id,
            ToolExecutionCompleteEvent => assistantMessage.Id,
            SkillInvokedEvent => assistantMessage.Id,
            SubagentStartedEvent => assistantMessage.Id,
            SubagentCompletedEvent => assistantMessage.Id,
            SubagentFailedEvent => assistantMessage.Id,
            SubagentSelectedEvent => assistantMessage.Id,
            SubagentDeselectedEvent => assistantMessage.Id,
            HookStartEvent => assistantMessage.Id,
            HookEndEvent => assistantMessage.Id,
            SystemMessageEvent => assistantMessage.Id,
            SystemNotificationEvent => assistantMessage.Id,
            PermissionRequestedEvent => assistantMessage.Id,
            PermissionCompletedEvent => assistantMessage.Id,
            UserInputRequestedEvent => assistantMessage.Id,
            UserInputCompletedEvent => assistantMessage.Id,
            ElicitationRequestedEvent => assistantMessage.Id,
            ElicitationCompletedEvent => assistantMessage.Id,
            SamplingRequestedEvent => assistantMessage.Id,
            SamplingCompletedEvent => assistantMessage.Id,
            McpOauthRequiredEvent => assistantMessage.Id,
            McpOauthCompletedEvent => assistantMessage.Id,
            ExternalToolRequestedEvent => assistantMessage.Id,
            ExternalToolCompletedEvent => assistantMessage.Id,
            CommandQueuedEvent => assistantMessage.Id,
            CommandExecuteEvent => assistantMessage.Id,
            CommandCompletedEvent => assistantMessage.Id,
            ExitPlanModeRequestedEvent => assistantMessage.Id,
            ExitPlanModeCompletedEvent => assistantMessage.Id,
            SessionErrorEvent => assistantMessage.Id,
            SessionIdleEvent => assistantMessage.Id,
            SessionTitleChangedEvent => assistantMessage.Id,
            SessionTaskCompleteEvent => assistantMessage.Id,
            _ => null,
        };

    private async Task<CopilotSession> OpenSessionAsync(
        CopilotClient client,
        WorkspaceDefinition? workspace,
        RemoteSession session,
        string? model,
        CancellationToken cancellationToken)
    {
        var resolvedModel = string.IsNullOrWhiteSpace(model)
            ? options.Value.Model
            : model.Trim();
        var workspacePath = workspace?.MountedPath;

        if (!string.IsNullOrWhiteSpace(session.CopilotSessionId))
        {
            try
            {
                return await client.ResumeSessionAsync(
                    session.CopilotSessionId,
                    new ResumeSessionConfig
                    {
                        Model = resolvedModel,
                        OnPermissionRequest = (request, _) => permissionService.EvaluateAsync(workspacePath, request, cancellationToken),
                        Streaming = true,
                        WorkingDirectory = workspacePath,
                    },
                    cancellationToken);
            }
            catch (Exception exception)
            {
                logger.LogWarning(
                    exception,
                    "Failed to resume Copilot session {CopilotSessionId}; a new session will be created.",
                    session.CopilotSessionId);
            }
        }

        var createdSession = await client.CreateSessionAsync(
            new SessionConfig
            {
                ClientName = options.Value.ClientName,
                ConfigDir = options.Value.ConfigDirectory,
                Model = resolvedModel,
                WorkingDirectory = workspacePath,
                Streaming = true,
                SkillDirectories = options.Value.SkillDirectories,
                DisabledSkills = options.Value.DisabledSkills,
                OnPermissionRequest = (request, _) => permissionService.EvaluateAsync(workspacePath, request, cancellationToken),
            },
            cancellationToken);

        await remoteSessionRepository.UpdateCopilotSessionIdAsync(
            session.Id,
            createdSession.SessionId,
            cancellationToken);

        return createdSession;
    }
}
