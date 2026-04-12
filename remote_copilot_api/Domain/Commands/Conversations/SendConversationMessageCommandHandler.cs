using RemoteCopilot.Api.Common.Abstractions;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Domain.Services;

namespace RemoteCopilot.Api.Domain.Commands.Conversations;

public sealed class SendConversationMessageCommandHandler(
    IConversationRepository conversationRepository,
    IRemoteSessionRepository remoteSessionRepository,
    IWorkspaceRepository workspaceRepository,
    ICopilotConversationOrchestrator orchestrator)
    : ICommandHandler<SendConversationMessageCommand, AppResult<SendConversationMessageCommandResult>>
{
    public async Task<AppResult<SendConversationMessageCommandResult>> HandleAsync(
        SendConversationMessageCommand command,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(command.Content))
        {
            return AppResult<SendConversationMessageCommandResult>.Failure(
                "empty_message",
                "A message cannot be empty.");
        }

        var conversation = await conversationRepository.GetByIdAsync(command.ConversationId, cancellationToken);
        if (conversation is null)
        {
            return AppResult<SendConversationMessageCommandResult>.Failure(
                "conversation_not_found",
                $"The conversation '{command.ConversationId}' was not found.");
        }

        var session = await remoteSessionRepository.GetByIdAsync(conversation.SessionId, cancellationToken);
        if (session is null)
        {
            return AppResult<SendConversationMessageCommandResult>.Failure(
                "session_not_found",
                $"The session '{conversation.SessionId}' was not found.");
        }

        WorkspaceDefinition? workspace = null;
        if (!string.IsNullOrWhiteSpace(session.WorkspaceId))
        {
            workspace = await workspaceRepository.GetByIdAsync(session.WorkspaceId, cancellationToken);
            if (workspace is null)
            {
                return AppResult<SendConversationMessageCommandResult>.Failure(
                    "workspace_not_found",
                    $"The workspace '{session.WorkspaceId}' was not found.");
            }
        }

        var trimmedContent = command.Content.Trim();
        var userMessage = await conversationRepository.AddMessageAsync(
            conversation.Id,
            "user",
            trimmedContent,
            "completed",
            null,
            cancellationToken);

        var assistantMessage = await conversationRepository.AddMessageAsync(
            conversation.Id,
            "assistant",
            string.Empty,
            "streaming",
            null,
            cancellationToken);

        await remoteSessionRepository.TouchAsync(session.Id, cancellationToken);

        _ = orchestrator.RunAsync(
            workspace,
            session,
            conversation,
            userMessage,
            assistantMessage,
            trimmedContent,
            command.Model,
            CancellationToken.None);

        return AppResult<SendConversationMessageCommandResult>.Success(
            new SendConversationMessageCommandResult(
                session,
                conversation,
                userMessage,
                assistantMessage));
    }
}
