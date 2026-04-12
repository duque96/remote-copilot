namespace RemoteCopilot.Api.Api.Endpoints.Conversations;

public static class ConversationEndpointsParameters
{
    public sealed record SendConversationMessageApiParameter(string Content, string? Model = null);
}
