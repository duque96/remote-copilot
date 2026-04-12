using System.Text.Json;
using RemoteCopilot.Api.Domain.Commands.Conversations;
using RemoteCopilot.Api.Domain.Events;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Api.Endpoints.Sessions;

namespace RemoteCopilot.Api.Api.Endpoints.Conversations;

public static class ConversationEndpointsResults
{
    public sealed record ConversationMessageApiResult(
        string Id,
        string ConversationId,
        string Role,
        string Content,
        string Status,
        int Sequence,
        DateTimeOffset CreatedAt,
        DateTimeOffset UpdatedAt,
        string? Error)
    {
        public static ConversationMessageApiResult FromDomain(ConversationMessage message) =>
            new(
                message.Id,
                message.ConversationId,
                message.Role,
                message.Content,
                message.Status,
                message.Sequence,
                message.CreatedAt,
                message.UpdatedAt,
                message.Error);
    }

    public sealed record ConversationDetailsApiResult(
        string Id,
        string SessionId,
        string Title,
        DateTimeOffset CreatedAt,
        DateTimeOffset UpdatedAt,
        IReadOnlyList<ConversationMessageApiResult> Messages)
    {
        public static ConversationDetailsApiResult FromDomain(
            ConversationThread conversation,
            IReadOnlyList<ConversationMessage> messages) =>
            new(
                conversation.Id,
                conversation.SessionId,
                conversation.Title,
                conversation.CreatedAt,
                conversation.UpdatedAt,
                messages.Select(ConversationMessageApiResult.FromDomain).ToList());
    }

    public sealed record SendConversationMessageApiResult(
        SessionEndpointsResults.RemoteSessionApiResult Session,
        SessionEndpointsResults.ConversationThreadApiResult Conversation,
        ConversationMessageApiResult UserMessage,
        ConversationMessageApiResult AssistantMessage)
    {
        public static SendConversationMessageApiResult FromDomain(SendConversationMessageCommandResult result) =>
            new(
                SessionEndpointsResults.RemoteSessionApiResult.FromDomain(result.Session),
                SessionEndpointsResults.ConversationThreadApiResult.FromDomain(result.Conversation),
                ConversationMessageApiResult.FromDomain(result.UserMessage),
                ConversationMessageApiResult.FromDomain(result.AssistantMessage));
    }

    public sealed record ConversationStreamEventApiResult(
        string Type,
        string ConversationId,
        DateTimeOffset Timestamp,
        string? MessageId,
        string? EventId,
        string? ParentEventId,
        bool Ephemeral,
        string Source,
        JsonElement? Data)
    {
        public static ConversationStreamEventApiResult FromDomain(ConversationStreamEvent streamEvent) =>
            new(
                streamEvent.Type,
                streamEvent.ConversationId,
                streamEvent.Timestamp,
                streamEvent.MessageId,
                streamEvent.EventId,
                streamEvent.ParentEventId,
                streamEvent.Ephemeral,
                streamEvent.Source,
                streamEvent.Data);
    }
}
