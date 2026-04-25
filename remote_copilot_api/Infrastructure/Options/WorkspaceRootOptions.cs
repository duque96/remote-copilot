namespace RemoteCopilot.Api.Infrastructure.Options;

public sealed class WorkspaceRootOptions
{
    public const string SectionName = "WorkspaceRoot";

    public string Path { get; set; } = "/workspaces";
}