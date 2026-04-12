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

    public sealed record ConversationThreadApiResult(
        string Id,
        string SessionId,
        string Title,
        DateTimeOffset CreatedAt,
        DateTimeOffset UpdatedAt)
    {
        public static ConversationThreadApiResult FromDomain(ConversationThread conversation) =>
            new(
                conversation.Id,
                conversation.SessionId,
                conversation.Title,
                conversation.CreatedAt,
                conversation.UpdatedAt);
    }

    public sealed record CreateRemoteSessionApiResult(
        RemoteSessionApiResult Session,
        ConversationThreadApiResult Conversation)
    {
        public static CreateRemoteSessionApiResult FromDomain(CreateRemoteSessionCommandResult result) =>
            new(RemoteSessionApiResult.FromDomain(result.Session), ConversationThreadApiResult.FromDomain(result.Conversation));
    }
}
