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

        group.MapGet("/{sessionId}", GetByIdAsync)
            .WithName("GetSession");

        group.MapDelete("/{sessionId}", DeleteAsync)
            .WithName("DeleteSession");

        group.MapPost("/", CreateAsync)
            .WithName("CreateSession");
    }

    private static async Task<IResult> GetAllAsync(
        string? workspaceId,
        IRemoteSessionRepository remoteSessionRepository,
        CancellationToken cancellationToken)
    {
        var sessions = await remoteSessionRepository.GetAllAsync(workspaceId, cancellationToken);
        return Results.Ok(sessions.Select(SessionEndpointsResults.RemoteSessionApiResult.FromDomain));
    }

    private static async Task<IResult> GetByIdAsync(
        string sessionId,
        IRemoteSessionRepository remoteSessionRepository,
        IConversationRepository conversationRepository,
        CancellationToken cancellationToken)
    {
        var session = await remoteSessionRepository.GetByIdAsync(sessionId, cancellationToken);
        if (session is null)
        {
            return Results.NotFound();
        }

        var conversation = await conversationRepository.GetBySessionIdAsync(sessionId, cancellationToken);
        if (conversation is null)
        {
            return Results.NotFound();
        }

        var messages = await conversationRepository.GetMessagesAsync(conversation.Id, cancellationToken);
        return Results.Ok(SessionEndpointsResults.SessionDetailsApiResult.FromDomain(session, conversation, messages));
    }

    private static async Task<IResult> DeleteAsync(
        string sessionId,
        IRemoteSessionRepository remoteSessionRepository,
        CancellationToken cancellationToken)
    {
        var deletedSession = await remoteSessionRepository.DeleteAsync(sessionId, cancellationToken);
        if (deletedSession is null)
        {
            return Results.NotFound();
        }

        return Results.Ok(SessionEndpointsResults.RemoteSessionApiResult.FromDomain(deletedSession));
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
