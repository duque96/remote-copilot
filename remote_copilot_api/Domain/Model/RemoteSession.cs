namespace RemoteCopilot.Api.Domain.Model;

public sealed record RemoteSession(
    string Id,
    string? WorkspaceId,
    string Title,
    string? CopilotSessionId,
    string Status,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt);
