using System.Data.Common;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Infrastructure.Persistence;

namespace RemoteCopilot.Api.Infrastructure.Repositories;

public sealed class SqliteWorkspaceRepository(SqliteConnectionFactory connectionFactory)
    : IWorkspaceRepository
{
    public async Task<IReadOnlyList<WorkspaceDefinition>> GetAllAsync(CancellationToken cancellationToken)
    {
        var workspaces = new List<WorkspaceDefinition>();

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id, name, mounted_path, source_kind, created_at, last_used_at
            FROM workspaces
            ORDER BY name;
            """;

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            workspaces.Add(MapWorkspace(reader));
        }

        return workspaces;
    }

    public async Task<WorkspaceDefinition?> GetByIdAsync(string workspaceId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id, name, mounted_path, source_kind, created_at, last_used_at
            FROM workspaces
            WHERE id = $id
            LIMIT 1;
            """;
        command.Parameters.AddWithValue("$id", workspaceId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapWorkspace(reader);
    }

    private static WorkspaceDefinition MapWorkspace(DbDataReader reader)
    {
        return new WorkspaceDefinition(
            reader.GetString(0),
            reader.GetString(1),
            reader.GetString(2),
            reader.GetString(3),
            DateTimeOffset.Parse(reader.GetString(4)),
            reader.IsDBNull(5) ? null : DateTimeOffset.Parse(reader.GetString(5)));
    }
}
