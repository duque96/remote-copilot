using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Services;

public interface ICopilotConversationOrchestrator
{
    Task RunAsync(
        WorkspaceDefinition? workspace,
        RemoteSession session,
        ConversationThread conversation,
    ConversationMessage userMessage,
        ConversationMessage assistantMessage,
        string prompt,
        string? model,
        CancellationToken cancellationToken);
}
