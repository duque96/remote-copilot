using RemoteCopilot.Api.Infrastructure.Managers;
using RemoteCopilot.Api.Infrastructure.Persistence;

namespace RemoteCopilot.Api.Api.Endpoints.Health;

public static class HealthEndpoints
{
    public static void MapHealthEndpoints(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet("/api/health", GetAsync)
            .WithTags("Health")
            .WithName("GetHealth");
    }

    private static async Task<IResult> GetAsync(
        SqliteConnectionFactory connectionFactory,
        CopilotClientAccessor clientAccessor,
        CancellationToken cancellationToken)
    {
        var databaseAvailable = await CanOpenDatabaseAsync(connectionFactory, cancellationToken);
        var copilotServerAvailable = await clientAccessor.PingAsync(cancellationToken);

        return Results.Ok(
            new
            {
                status = databaseAvailable && copilotServerAvailable ? "healthy" : "degraded",
                apiVersion = "0.1.0",
                databaseAvailable,
                copilotServerAvailable,
            });
    }

    private static async Task<bool> CanOpenDatabaseAsync(
        SqliteConnectionFactory connectionFactory,
        CancellationToken cancellationToken)
    {
        try
        {
            await using var connection = connectionFactory.CreateConnection();
            await connection.OpenAsync(cancellationToken);
            return true;
        }
        catch
        {
            return false;
        }
    }
}
