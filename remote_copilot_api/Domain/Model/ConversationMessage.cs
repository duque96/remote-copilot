namespace RemoteCopilot.Api.Domain.Model;

public sealed record ConversationMessage(
    string Id,
    string ConversationId,
    string Role,
    string Content,
    string Status,
    int Sequence,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt,
    string? Error);
