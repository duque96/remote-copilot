using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Api.Endpoints.Workspaces;

public static class WorkspaceEndpointsResults
{
    public sealed record WorkspaceSummaryApiResult(
        string Id,
        string Name,
        string MountedPath,
        string SourceKind,
        DateTimeOffset CreatedAt,
        DateTimeOffset? LastUsedAt)
    {
        public static WorkspaceSummaryApiResult FromDomain(WorkspaceDefinition workspace)
        {
            return new WorkspaceSummaryApiResult(
                workspace.Id,
                workspace.Name,
                workspace.MountedPath,
                workspace.SourceKind,
                workspace.CreatedAt,
                workspace.LastUsedAt);
        }
    }

    public sealed record SyncWorkspacesApiResult(
        int TotalProjects,
        IReadOnlyList<WorkspaceSummaryApiResult> Projects)
    {
        public static SyncWorkspacesApiResult FromDomain(IReadOnlyList<WorkspaceDefinition> workspaces)
        {
            return new SyncWorkspacesApiResult(
                workspaces.Count,
                workspaces.Select(WorkspaceSummaryApiResult.FromDomain).ToList());
        }
    }
}
