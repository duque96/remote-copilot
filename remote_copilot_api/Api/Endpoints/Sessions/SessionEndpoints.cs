using RemoteCopilot.Api.Common.Abstractions;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Commands.Sessions;
using RemoteCopilot.Api.Domain.Repositories;

namespace RemoteCopilot.Api.Api.Endpoints.Sessions;

public static class SessionEndpoints
{
    public static void MapSessionEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/sessions")
            .WithTags("Sessions");

        group.MapGet("/", GetAllAsync)
            .WithName("GetSessions");

        group.MapPost("/", CreateAsync)
            .WithName("CreateSession");
    }

    private static async Task<IResult> GetAllAsync(
        IRemoteSessionRepository remoteSessionRepository,
        CancellationToken cancellationToken)
    {
        var sessions = await remoteSessionRepository.GetAllAsync(cancellationToken);
        return Results.Ok(sessions.Select(SessionEndpointsResults.RemoteSessionApiResult.FromDomain));
    }

    private static async Task<IResult> CreateAsync(
        SessionEndpointsParameters.CreateRemoteSessionApiParameter parameter,
        ICommandHandler<CreateRemoteSessionCommand, AppResult<CreateRemoteSessionCommandResult>> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(
            new CreateRemoteSessionCommand(parameter.WorkspaceId, parameter.Title),
            cancellationToken);

        if (!result.IsSuccess || result.Value is null)
        {
            return Results.BadRequest(result.Error);
        }

        return Results.Ok(SessionEndpointsResults.CreateRemoteSessionApiResult.FromDomain(result.Value));
    }
}
