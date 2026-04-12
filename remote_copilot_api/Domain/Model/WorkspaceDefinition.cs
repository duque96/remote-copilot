namespace RemoteCopilot.Api.Domain.Model;

public sealed record WorkspaceDefinition(
    string Id,
    string Name,
    string MountedPath,
    string SourceKind,
    DateTimeOffset CreatedAt,
    DateTimeOffset? LastUsedAt);
