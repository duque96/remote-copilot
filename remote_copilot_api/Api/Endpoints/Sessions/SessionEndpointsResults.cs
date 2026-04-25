using RemoteCopilot.Api.Domain.Commands.Sessions;
using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Api.Endpoints.Sessions;

public static class SessionEndpointsResults
{
    public sealed record RemoteSessionApiResult(
        string Id,
        string? WorkspaceId,
        string Title,
        string? CopilotSessionId,
        string Status,
        DateTimeOffset CreatedAt,
        DateTimeOffset UpdatedAt)
    {
        public static RemoteSessionApiResult FromDomain(RemoteSession session) =>
            new(
                session.Id,
                session.WorkspaceId,
                session.Title,
                session.CopilotSessionId,
                session.Status,
                session.CreatedAt,
                session.UpdatedAt);
    }

    public sealed record ConversationMessageApiResult(
        string Id,
        string ConversationId,
        string Role,
        string Content,
        string Status,
        int Sequence,
        DateTimeOffset CreatedAt,
        DateTimeOffset UpdatedAt,
        string? Error)
    {
        public static ConversationMessageApiResult FromDomain(ConversationMessage message) =>
            new(
                message.Id,
                message.ConversationId,
                message.Role,
                message.Content,
                message.Status,
                message.Sequence,
                message.CreatedAt,
                message.UpdatedAt,
                message.Error);
    }

    public sealed record ConversationThreadApiResult(
        string Id,
        string SessionId,
        string Title,
        DateTimeOffset CreatedAt,
        DateTimeOffset UpdatedAt,
        IReadOnlyList<ConversationMessageApiResult> Messages)
    {
        public static ConversationThreadApiResult FromDomain(
            ConversationThread conversation,
            IReadOnlyList<ConversationMessage> messages) =>
            new(
                conversation.Id,
                conversation.SessionId,
                conversation.Title,
                conversation.CreatedAt,
                conversation.UpdatedAt,
                messages.Select(ConversationMessageApiResult.FromDomain).ToList());
    }

    public sealed record CreateRemoteSessionApiResult(
        RemoteSessionApiResult Session,
        ConversationThreadApiResult Conversation)
    {
        public static CreateRemoteSessionApiResult FromDomain(CreateRemoteSessionCommandResult result) =>
            new(
                RemoteSessionApiResult.FromDomain(result.Session),
                ConversationThreadApiResult.FromDomain(result.Conversation, []));
    }

    public sealed record SessionDetailsApiResult(
        RemoteSessionApiResult Session,
        ConversationThreadApiResult Conversation)
    {
        public static SessionDetailsApiResult FromDomain(
            RemoteSession session,
            ConversationThread conversation,
            IReadOnlyList<ConversationMessage> messages) =>
            new(
                RemoteSessionApiResult.FromDomain(session),
                ConversationThreadApiResult.FromDomain(conversation, messages));
    }
}
