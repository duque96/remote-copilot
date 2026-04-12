using RemoteCopilot.Api.Api.Endpoints.Workspaces;
using RemoteCopilot.Api.Domain.Repositories;

namespace RemoteCopilot.Api.Api.Endpoints.Workspaces;

public static class WorkspaceEndpoints
{
    public static void MapWorkspaceEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/workspaces")
            .WithTags("Workspaces");

        group.MapGet("/", GetAllAsync)
            .WithName("GetWorkspaces");
    }

    private static async Task<IResult> GetAllAsync(
        IWorkspaceRepository workspaceRepository,
        CancellationToken cancellationToken)
    {
        var workspaces = await workspaceRepository.GetAllAsync(cancellationToken);
        return Results.Ok(workspaces.Select(WorkspaceEndpointsResults.WorkspaceSummaryApiResult.FromDomain));
    }
}
