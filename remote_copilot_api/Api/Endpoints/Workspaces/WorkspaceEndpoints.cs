using RemoteCopilot.Api.Api.Endpoints.Workspaces;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Infrastructure.Managers;

namespace RemoteCopilot.Api.Api.Endpoints.Workspaces;

public static class WorkspaceEndpoints
{
    public static void MapWorkspaceEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/workspaces")
            .WithTags("Workspaces");

        group.MapGet("/", GetAllAsync)
            .WithName("GetWorkspaces");

        group.MapPost("/sync", SyncAsync)
            .WithName("SyncWorkspaces");

        group.MapPost("/", CreateAsync)
            .WithName("CreateWorkspace");

        group.MapPut("/{workspaceId}", UpdateAsync)
            .WithName("UpdateWorkspace");

        group.MapDelete("/{workspaceId}", DeleteAsync)
            .WithName("DeleteWorkspace");
    }

    private static async Task<IResult> GetAllAsync(
        IWorkspaceRepository workspaceRepository,
        CancellationToken cancellationToken)
    {
        var workspaces = await workspaceRepository.GetAllAsync(cancellationToken);
        return Results.Ok(workspaces.Select(WorkspaceEndpointsResults.WorkspaceSummaryApiResult.FromDomain));
    }

    private static async Task<IResult> SyncAsync(
        WorkspaceCatalogManager workspaceCatalogManager,
        CancellationToken cancellationToken)
    {
        var workspaces = await workspaceCatalogManager.SyncAsync(cancellationToken);
        return Results.Ok(WorkspaceEndpointsResults.SyncWorkspacesApiResult.FromDomain(workspaces));
    }

    private static async Task<IResult> CreateAsync(
        WorkspaceEndpointsParameters.CreateWorkspaceApiParameter parameter,
        WorkspaceCatalogManager workspaceCatalogManager,
        CancellationToken cancellationToken)
    {
        var result = await workspaceCatalogManager.CreateAsync(parameter.Name, cancellationToken);
        return ToResult(result);
    }

    private static async Task<IResult> UpdateAsync(
        string workspaceId,
        WorkspaceEndpointsParameters.UpdateWorkspaceApiParameter parameter,
        WorkspaceCatalogManager workspaceCatalogManager,
        CancellationToken cancellationToken)
    {
        var result = await workspaceCatalogManager.RenameAsync(workspaceId, parameter.Name, cancellationToken);
        return ToResult(result);
    }

    private static async Task<IResult> DeleteAsync(
        string workspaceId,
        WorkspaceCatalogManager workspaceCatalogManager,
        CancellationToken cancellationToken)
    {
        var result = await workspaceCatalogManager.DeleteAsync(workspaceId, cancellationToken);
        return ToResult(result);
    }

    private static IResult ToResult(AppResult<Domain.Model.WorkspaceDefinition> result)
    {
        if (!result.IsSuccess || result.Value is null)
        {
            return Results.BadRequest(result.Error);
        }

        return Results.Ok(WorkspaceEndpointsResults.WorkspaceSummaryApiResult.FromDomain(result.Value));
    }
}
