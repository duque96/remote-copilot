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
        AddParameter(command, "$id", workspaceId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapWorkspace(reader);
    }

    public async Task<IReadOnlyList<WorkspaceDefinition>> SyncAsync(
        IReadOnlyList<WorkspaceDefinition> discoveredWorkspaces,
        CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

        var existing = await ReadAllInternalAsync(connection, transaction, cancellationToken);
        var existingById = existing.ToDictionary(workspace => workspace.Id, StringComparer.Ordinal);

        foreach (var discovered in discoveredWorkspaces)
        {
            var workspace = existingById.TryGetValue(discovered.Id, out var current)
                ? discovered with
                {
                    CreatedAt = current.CreatedAt,
                    LastUsedAt = current.LastUsedAt,
                }
                : discovered;

            await UpsertInternalAsync(connection, transaction, workspace, cancellationToken);
        }

        var removedIds = existingById.Keys.Except(discoveredWorkspaces.Select(workspace => workspace.Id), StringComparer.Ordinal);
        foreach (var workspaceId in removedIds)
        {
            await DeleteInternalAsync(connection, transaction, workspaceId, cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
        return await GetAllAsync(cancellationToken);
    }

    public async Task<WorkspaceDefinition> UpsertAsync(WorkspaceDefinition workspace, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var existing = await GetByIdInternalAsync(connection, null, workspace.Id, cancellationToken);
        var normalizedWorkspace = existing is null
            ? workspace
            : workspace with
            {
                CreatedAt = existing.CreatedAt,
                LastUsedAt = workspace.LastUsedAt ?? existing.LastUsedAt,
            };

        await UpsertInternalAsync(connection, null, normalizedWorkspace, cancellationToken);
        return await GetByIdInternalAsync(connection, null, normalizedWorkspace.Id, cancellationToken)
            ?? normalizedWorkspace;
    }

    public async Task<WorkspaceDefinition?> ReplaceAsync(
        string workspaceId,
        WorkspaceDefinition workspace,
        CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        var existing = await GetByIdInternalAsync(connection, null, workspaceId, cancellationToken);
        if (existing is null)
        {
            return null;
        }

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            UPDATE workspaces
            SET id = $newId,
                name = $name,
                mounted_path = $mountedPath,
                source_kind = $sourceKind,
                created_at = $createdAt,
                last_used_at = $lastUsedAt
            WHERE id = $currentId;
            """;
        command.Parameters.AddWithValue("$currentId", workspaceId);
        command.Parameters.AddWithValue("$newId", workspace.Id);
        command.Parameters.AddWithValue("$name", workspace.Name);
        command.Parameters.AddWithValue("$mountedPath", workspace.MountedPath);
        command.Parameters.AddWithValue("$sourceKind", workspace.SourceKind);
        command.Parameters.AddWithValue("$createdAt", existing.CreatedAt.ToString("O"));
        command.Parameters.AddWithValue("$lastUsedAt", (object?)existing.LastUsedAt?.ToString("O") ?? DBNull.Value);

        var rows = await command.ExecuteNonQueryAsync(cancellationToken);
        if (rows == 0)
        {
            return null;
        }

        return await GetByIdInternalAsync(connection, null, workspace.Id, cancellationToken);
    }

    public async Task DeleteAsync(string workspaceId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await DeleteInternalAsync(connection, null, workspaceId, cancellationToken);
    }

    public async Task TouchAsync(string workspaceId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            UPDATE workspaces
            SET last_used_at = $lastUsedAt
            WHERE id = $id;
            """;
        command.Parameters.AddWithValue("$id", workspaceId);
        command.Parameters.AddWithValue("$lastUsedAt", DateTimeOffset.UtcNow.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static async Task<IReadOnlyList<WorkspaceDefinition>> ReadAllInternalAsync(
        DbConnection connection,
        DbTransaction? transaction,
        CancellationToken cancellationToken)
    {
        var workspaces = new List<WorkspaceDefinition>();

        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText =
            """
            SELECT id, name, mounted_path, source_kind, created_at, last_used_at
            FROM workspaces;
            """;

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            workspaces.Add(MapWorkspace(reader));
        }

        return workspaces;
    }

    private static async Task<WorkspaceDefinition?> GetByIdInternalAsync(
        DbConnection connection,
        DbTransaction? transaction,
        string workspaceId,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText =
            """
            SELECT id, name, mounted_path, source_kind, created_at, last_used_at
            FROM workspaces
            WHERE id = $id
            LIMIT 1;
            """;
        AddParameter(command, "$id", workspaceId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapWorkspace(reader);
    }

    private static async Task UpsertInternalAsync(
        DbConnection connection,
        DbTransaction? transaction,
        WorkspaceDefinition workspace,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText =
            """
            INSERT INTO workspaces (id, name, mounted_path, source_kind, created_at, last_used_at)
            VALUES ($id, $name, $mountedPath, $sourceKind, $createdAt, $lastUsedAt)
            ON CONFLICT(id) DO UPDATE SET
                name = excluded.name,
                mounted_path = excluded.mounted_path,
                source_kind = excluded.source_kind,
                created_at = excluded.created_at,
                last_used_at = excluded.last_used_at;
            """;
        AddParameter(command, "$id", workspace.Id);
        AddParameter(command, "$name", workspace.Name);
        AddParameter(command, "$mountedPath", workspace.MountedPath);
        AddParameter(command, "$sourceKind", workspace.SourceKind);
        AddParameter(command, "$createdAt", workspace.CreatedAt.ToString("O"));
        AddParameter(command, "$lastUsedAt", (object?)workspace.LastUsedAt?.ToString("O") ?? DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static async Task DeleteInternalAsync(
        DbConnection connection,
        DbTransaction? transaction,
        string workspaceId,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText =
            """
            DELETE FROM workspaces
            WHERE id = $id;
            """;
        AddParameter(command, "$id", workspaceId);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static void AddParameter(DbCommand command, string name, object? value)
    {
        var parameter = command.CreateParameter();
        parameter.ParameterName = name;
        parameter.Value = value ?? DBNull.Value;
        command.Parameters.Add(parameter);
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
