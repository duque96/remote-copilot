namespace RemoteCopilot.Api.Api.Endpoints.Workspaces;

public static class WorkspaceEndpointsParameters
{
    public sealed record CreateWorkspaceApiParameter(string Name);

    public sealed record UpdateWorkspaceApiParameter(string Name);
}