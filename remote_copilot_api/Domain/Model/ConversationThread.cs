namespace RemoteCopilot.Api.Domain.Model;

public sealed record ConversationThread(
    string Id,
    string SessionId,
    string Title,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt);
