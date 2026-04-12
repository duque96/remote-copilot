using RemoteCopilot.Api.Api.Endpoints.Container;
using RemoteCopilot.Api.Api.Endpoints.Conversations;
using RemoteCopilot.Api.Api.Endpoints.Health;
using RemoteCopilot.Api.Api.Endpoints.Sessions;
using RemoteCopilot.Api.Api.Endpoints.Workspaces;
using RemoteCopilot.Api.Infrastructure.Persistence;

namespace RemoteCopilot.Api.Api.Extensions;

public static class WebApplicationExtensions
{
    public static async Task InitializeApiAsync(this WebApplication app)
    {
        await using var scope = app.Services.CreateAsyncScope();
        var initializer = scope.ServiceProvider.GetRequiredService<SqliteDatabaseInitializer>();

        await initializer.InitializeAsync();

        app.UseCors("remote-copilot-client");
        app.UseDefaultFiles();
        app.UseStaticFiles();

        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
        }

        app.MapHealthEndpoints();
        app.MapContainerEndpoints();
        app.MapWorkspaceEndpoints();
        app.MapSessionEndpoints();
        app.MapConversationEndpoints();
        app.MapFallbackToFile("index.html");
    }
}
