using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Commands.Conversations;

public sealed record SendConversationMessageCommand(string ConversationId, string Content, string? Model = null);

public sealed record SendConversationMessageCommandResult(
    RemoteSession Session,
    ConversationThread Conversation,
    ConversationMessage UserMessage,
    ConversationMessage AssistantMessage);
