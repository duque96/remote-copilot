using System.Text.Json;
using Microsoft.AspNetCore.Http.Json;
using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Common.Abstractions;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Commands.Conversations;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Domain.Services;

namespace RemoteCopilot.Api.Api.Endpoints.Conversations;

public static class ConversationEndpoints
{
    public static void MapConversationEndpoints(this IEndpointRouteBuilder endpoints)
    {
        var group = endpoints.MapGroup("/api/conversations")
            .WithTags("Conversations");

        group.MapGet("/{conversationId}", GetByIdAsync)
            .WithName("GetConversation");

        group.MapPost("/{conversationId}/messages", SendMessageAsync)
            .WithName("SendConversationMessage");

        group.MapGet("/{conversationId}/events", StreamAsync)
            .WithName("StreamConversationEvents");
    }

    private static async Task<IResult> GetByIdAsync(
        string conversationId,
        IConversationRepository conversationRepository,
        CancellationToken cancellationToken)
    {
        var conversation = await conversationRepository.GetByIdAsync(conversationId, cancellationToken);
        if (conversation is null)
        {
            return Results.NotFound();
        }

        var messages = await conversationRepository.GetMessagesAsync(conversationId, cancellationToken);
        return Results.Ok(ConversationEndpointsResults.ConversationDetailsApiResult.FromDomain(conversation, messages));
    }

    private static async Task<IResult> SendMessageAsync(
        string conversationId,
        ConversationEndpointsParameters.SendConversationMessageApiParameter parameter,
        ICommandHandler<SendConversationMessageCommand, AppResult<SendConversationMessageCommandResult>> handler,
        CancellationToken cancellationToken)
    {
        var result = await handler.HandleAsync(
            new SendConversationMessageCommand(conversationId, parameter.Content, parameter.Model),
            cancellationToken);

        if (!result.IsSuccess || result.Value is null)
        {
            return Results.BadRequest(result.Error);
        }

        return Results.Accepted(
            $"/api/conversations/{conversationId}",
            ConversationEndpointsResults.SendConversationMessageApiResult.FromDomain(result.Value));
    }

    private static async Task StreamAsync(
        string conversationId,
        HttpContext httpContext,
        IConversationStreamPublisher streamPublisher,
        CancellationToken cancellationToken)
    {
        httpContext.Response.Headers.ContentType = "text/event-stream";
        httpContext.Response.Headers.CacheControl = "no-cache";

        using var linkedCancellationTokenSource = CancellationTokenSource.CreateLinkedTokenSource(
            cancellationToken,
            httpContext.RequestAborted);
        var streamCancellationToken = linkedCancellationTokenSource.Token;

        try
        {
            await foreach (var streamEvent in streamPublisher.SubscribeAsync(conversationId, streamCancellationToken))
            {
                var payload = JsonSerializer.Serialize(
                    ConversationEndpointsResults.ConversationStreamEventApiResult.FromDomain(streamEvent),
                    JsonSerializerOptions.Web);

                await httpContext.Response.WriteAsync($"event: {streamEvent.Type}\n", streamCancellationToken);
                await httpContext.Response.WriteAsync($"data: {payload}\n\n", streamCancellationToken);
                await httpContext.Response.Body.FlushAsync(streamCancellationToken);
            }
        }
        catch (OperationCanceledException) when (streamCancellationToken.IsCancellationRequested)
        {
            // Expected when the client closes the SSE connection.
        }
    }
}
