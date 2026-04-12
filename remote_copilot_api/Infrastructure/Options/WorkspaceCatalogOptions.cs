namespace RemoteCopilot.Api.Infrastructure.Options;

public sealed class WorkspaceCatalogOptions
{
    public const string SectionName = "WorkspaceCatalog";

    public List<WorkspaceCatalogItemOptions> Items { get; set; } = [];
}

public sealed class WorkspaceCatalogItemOptions
{
    public string Id { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public string MountedPath { get; set; } = string.Empty;

    public string SourceKind { get; set; } = "volume";
}
