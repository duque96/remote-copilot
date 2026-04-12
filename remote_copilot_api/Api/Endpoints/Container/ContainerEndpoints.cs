using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Infrastructure.Managers;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Api.Endpoints.Container;

public static class ContainerEndpoints
{
    public static void MapContainerEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet("/api/container/runtime", GetRuntimeAsync)
            .WithTags("Container")
            .WithName("GetContainerRuntime");

        endpoints.MapGet("/api/container/models", GetModelsAsync)
            .WithTags("Container")
            .WithName("GetContainerModels");
    }

    private static async Task<IResult> GetRuntimeAsync(
        IWorkspaceRepository workspaceRepository,
        CopilotClientAccessor clientAccessor,
        IOptions<CopilotOptions> copilotOptions,
        CancellationToken cancellationToken)
    {
        var workspaces = await workspaceRepository.GetAllAsync(cancellationToken);
        var copilotServerAvailable = await clientAccessor.PingAsync(cancellationToken);

        return Results.Ok(
            new
            {
                copilotServerUrl = copilotOptions.Value.ServerUrl,
                copilotServerAvailable,
                configuredWorkspaces = workspaces.Count,
            });
    }

    private static async Task<IResult> GetModelsAsync(
        CopilotClientAccessor clientAccessor,
        CancellationToken cancellationToken)
    {
        var models = await clientAccessor.GetModelsAsync(cancellationToken);
        var results = models
            .Select(model => new
            {
                id = model.Id,
                name = model.Name,
                multiplier = model.Multiplier,
            })
            .ToList();

        return Results.Ok(results);
    }
}
