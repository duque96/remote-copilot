namespace RemoteCopilot.Api.Api.Endpoints.Sessions;

public static class SessionEndpointsParameters
{
    public sealed record CreateRemoteSessionApiParameter(string? WorkspaceId, string? Title);
}
