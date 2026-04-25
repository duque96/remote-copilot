using Microsoft.Data.Sqlite;
using System.Data.Common;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Infrastructure.Persistence;

namespace RemoteCopilot.Api.Infrastructure.Repositories;

public sealed class SqliteRemoteSessionRepository(SqliteConnectionFactory connectionFactory)
    : IRemoteSessionRepository
{
    public async Task<IReadOnlyList<RemoteSession>> GetAllAsync(string? workspaceId, CancellationToken cancellationToken)
    {
        var sessions = new List<RemoteSession>();

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText = string.IsNullOrWhiteSpace(workspaceId)
            ?
            """
            SELECT id, workspace_id, title, copilot_session_id, status, created_at, updated_at
            FROM sessions
            ORDER BY updated_at DESC;
            """
            :
            """
            SELECT id, workspace_id, title, copilot_session_id, status, created_at, updated_at
            FROM sessions
            WHERE workspace_id = $workspaceId
            ORDER BY updated_at DESC;
            """;

        if (!string.IsNullOrWhiteSpace(workspaceId))
        {
            command.Parameters.AddWithValue("$workspaceId", workspaceId);
        }

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            sessions.Add(MapSession(reader));
        }

        return sessions;
    }

    public async Task<RemoteSession?> GetByIdAsync(string sessionId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id, workspace_id, title, copilot_session_id, status, created_at, updated_at
            FROM sessions
            WHERE id = $id
            LIMIT 1;
            """;
        command.Parameters.AddWithValue("$id", sessionId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapSession(reader);
    }

    public async Task<RemoteSession?> DeleteAsync(string sessionId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);
        await using var transaction = (SqliteTransaction)await connection.BeginTransactionAsync(cancellationToken);

        var session = await GetByIdAsync(connection, transaction, sessionId, cancellationToken);
        if (session is null)
        {
            await transaction.RollbackAsync(cancellationToken);
            return null;
        }

        await using (var deleteMessagesCommand = connection.CreateCommand())
        {
            deleteMessagesCommand.Transaction = transaction;
            deleteMessagesCommand.CommandText =
                """
                DELETE FROM messages
                WHERE conversation_id IN (
                    SELECT id
                    FROM conversations
                    WHERE session_id = $sessionId
                );
                """;
            deleteMessagesCommand.Parameters.AddWithValue("$sessionId", sessionId);

            await deleteMessagesCommand.ExecuteNonQueryAsync(cancellationToken);
        }

        await using (var deleteConversationsCommand = connection.CreateCommand())
        {
            deleteConversationsCommand.Transaction = transaction;
            deleteConversationsCommand.CommandText =
                """
                DELETE FROM conversations
                WHERE session_id = $sessionId;
                """;
            deleteConversationsCommand.Parameters.AddWithValue("$sessionId", sessionId);

            await deleteConversationsCommand.ExecuteNonQueryAsync(cancellationToken);
        }

        await using (var deleteSessionCommand = connection.CreateCommand())
        {
            deleteSessionCommand.Transaction = transaction;
            deleteSessionCommand.CommandText =
                """
                DELETE FROM sessions
                WHERE id = $id;
                """;
            deleteSessionCommand.Parameters.AddWithValue("$id", sessionId);

            await deleteSessionCommand.ExecuteNonQueryAsync(cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
        return session;
    }

    public async Task<RemoteSession> CreateAsync(string? workspaceId, string title, CancellationToken cancellationToken)
    {
        var session = new RemoteSession(
            Guid.CreateVersion7().ToString(),
            workspaceId,
            title,
            null,
            "ready",
            DateTimeOffset.UtcNow,
            DateTimeOffset.UtcNow);

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            INSERT INTO sessions (id, workspace_id, title, copilot_session_id, status, created_at, updated_at)
            VALUES ($id, $workspaceId, $title, NULL, $status, $createdAt, $updatedAt);
            """;
        command.Parameters.AddWithValue("$id", session.Id);
        command.Parameters.AddWithValue("$workspaceId", (object?)session.WorkspaceId ?? DBNull.Value);
        command.Parameters.AddWithValue("$title", session.Title);
        command.Parameters.AddWithValue("$status", session.Status);
        command.Parameters.AddWithValue("$createdAt", session.CreatedAt.ToString("O"));
        command.Parameters.AddWithValue("$updatedAt", session.UpdatedAt.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);

        return session;
    }

    public async Task UpdateCopilotSessionIdAsync(string sessionId, string copilotSessionId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            UPDATE sessions
            SET copilot_session_id = $copilotSessionId,
                updated_at = $updatedAt
            WHERE id = $id;
            """;
        command.Parameters.AddWithValue("$id", sessionId);
        command.Parameters.AddWithValue("$copilotSessionId", copilotSessionId);
        command.Parameters.AddWithValue("$updatedAt", DateTimeOffset.UtcNow.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task UpdateTitleAsync(string sessionId, string title, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(title))
        {
            return;
        }

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            UPDATE sessions
            SET title = $title,
                updated_at = $updatedAt
            WHERE id = $id;
            """;
        command.Parameters.AddWithValue("$id", sessionId);
        command.Parameters.AddWithValue("$title", title.Trim());
        command.Parameters.AddWithValue("$updatedAt", DateTimeOffset.UtcNow.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task TouchAsync(string sessionId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            UPDATE sessions
            SET updated_at = $updatedAt
            WHERE id = $id;
            """;
        command.Parameters.AddWithValue("$id", sessionId);
        command.Parameters.AddWithValue("$updatedAt", DateTimeOffset.UtcNow.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static RemoteSession MapSession(DbDataReader reader)
    {
        return new RemoteSession(
            reader.GetString(0),
            reader.IsDBNull(1) ? null : reader.GetString(1),
            reader.GetString(2),
            reader.IsDBNull(3) ? null : reader.GetString(3),
            reader.GetString(4),
            DateTimeOffset.Parse(reader.GetString(5)),
            DateTimeOffset.Parse(reader.GetString(6)));
    }

    private static async Task<RemoteSession?> GetByIdAsync(
        SqliteConnection connection,
        SqliteTransaction transaction,
        string sessionId,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText =
            """
            SELECT id, workspace_id, title, copilot_session_id, status, created_at, updated_at
            FROM sessions
            WHERE id = $id
            LIMIT 1;
            """;
        command.Parameters.AddWithValue("$id", sessionId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapSession(reader);
    }
}
