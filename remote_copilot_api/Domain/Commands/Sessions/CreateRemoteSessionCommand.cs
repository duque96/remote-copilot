using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Commands.Sessions;

public sealed record CreateRemoteSessionCommand(string? WorkspaceId, string? Title);

public sealed record CreateRemoteSessionCommandResult(RemoteSession Session, ConversationThread Conversation);
