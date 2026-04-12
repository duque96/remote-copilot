using Microsoft.Data.Sqlite;
using System.Data.Common;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Infrastructure.Persistence;

namespace RemoteCopilot.Api.Infrastructure.Repositories;

public sealed class SqliteConversationRepository(SqliteConnectionFactory connectionFactory)
    : IConversationRepository
{
    public async Task<ConversationThread> CreateAsync(string sessionId, string title, CancellationToken cancellationToken)
    {
        var conversation = new ConversationThread(
            Guid.CreateVersion7().ToString(),
            sessionId,
            title,
            DateTimeOffset.UtcNow,
            DateTimeOffset.UtcNow);

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            INSERT INTO conversations (id, session_id, title, created_at, updated_at)
            VALUES ($id, $sessionId, $title, $createdAt, $updatedAt);
            """;
        command.Parameters.AddWithValue("$id", conversation.Id);
        command.Parameters.AddWithValue("$sessionId", conversation.SessionId);
        command.Parameters.AddWithValue("$title", conversation.Title);
        command.Parameters.AddWithValue("$createdAt", conversation.CreatedAt.ToString("O"));
        command.Parameters.AddWithValue("$updatedAt", conversation.UpdatedAt.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);

        return conversation;
    }

    public async Task<ConversationThread?> GetByIdAsync(string conversationId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id, session_id, title, created_at, updated_at
            FROM conversations
            WHERE id = $id
            LIMIT 1;
            """;
        command.Parameters.AddWithValue("$id", conversationId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapConversation(reader);
    }

    public async Task<ConversationThread?> GetBySessionIdAsync(string sessionId, CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id, session_id, title, created_at, updated_at
            FROM conversations
            WHERE session_id = $sessionId
            LIMIT 1;
            """;
        command.Parameters.AddWithValue("$sessionId", sessionId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return MapConversation(reader);
    }

    public async Task<IReadOnlyList<ConversationMessage>> GetMessagesAsync(
        string conversationId,
        CancellationToken cancellationToken)
    {
        var messages = new List<ConversationMessage>();

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            SELECT id, conversation_id, role, content, status, sequence, created_at, updated_at, error
            FROM messages
            WHERE conversation_id = $conversationId
            ORDER BY sequence;
            """;
        command.Parameters.AddWithValue("$conversationId", conversationId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            messages.Add(MapMessage(reader));
        }

        return messages;
    }

    public async Task<ConversationMessage> AddMessageAsync(
        string conversationId,
        string role,
        string content,
        string status,
        string? error,
        CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var nextSequenceCommand = connection.CreateCommand();
        nextSequenceCommand.CommandText =
            """
            SELECT COALESCE(MAX(sequence), 0) + 1
            FROM messages
            WHERE conversation_id = $conversationId;
            """;
        nextSequenceCommand.Parameters.AddWithValue("$conversationId", conversationId);

        var sequence = Convert.ToInt32(await nextSequenceCommand.ExecuteScalarAsync(cancellationToken));

        var message = new ConversationMessage(
            Guid.CreateVersion7().ToString(),
            conversationId,
            role,
            content,
            status,
            sequence,
            DateTimeOffset.UtcNow,
            DateTimeOffset.UtcNow,
            error);

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            INSERT INTO messages (id, conversation_id, role, content, status, sequence, created_at, updated_at, error)
            VALUES ($id, $conversationId, $role, $content, $status, $sequence, $createdAt, $updatedAt, $error);
            """;
        command.Parameters.AddWithValue("$id", message.Id);
        command.Parameters.AddWithValue("$conversationId", message.ConversationId);
        command.Parameters.AddWithValue("$role", message.Role);
        command.Parameters.AddWithValue("$content", message.Content);
        command.Parameters.AddWithValue("$status", message.Status);
        command.Parameters.AddWithValue("$sequence", message.Sequence);
        command.Parameters.AddWithValue("$createdAt", message.CreatedAt.ToString("O"));
        command.Parameters.AddWithValue("$updatedAt", message.UpdatedAt.ToString("O"));
        command.Parameters.AddWithValue("$error", (object?)message.Error ?? DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);

        await TouchConversationAsync(connection, conversationId, cancellationToken);

        return message;
    }

    public async Task UpdateMessageAsync(
        string messageId,
        string content,
        string status,
        string? error,
        CancellationToken cancellationToken)
    {
        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        string conversationId;

        await using (var lookup = connection.CreateCommand())
        {
            lookup.CommandText =
                """
                SELECT conversation_id
                FROM messages
                WHERE id = $id
                LIMIT 1;
                """;
            lookup.Parameters.AddWithValue("$id", messageId);

            var scalar = await lookup.ExecuteScalarAsync(cancellationToken);
            conversationId = scalar?.ToString() ?? string.Empty;
        }

        await using (var command = connection.CreateCommand())
        {
            command.CommandText =
                """
                UPDATE messages
                SET content = $content,
                    status = $status,
                    updated_at = $updatedAt,
                    error = $error
                WHERE id = $id;
                """;
            command.Parameters.AddWithValue("$id", messageId);
            command.Parameters.AddWithValue("$content", content);
            command.Parameters.AddWithValue("$status", status);
            command.Parameters.AddWithValue("$updatedAt", DateTimeOffset.UtcNow.ToString("O"));
            command.Parameters.AddWithValue("$error", (object?)error ?? DBNull.Value);

            await command.ExecuteNonQueryAsync(cancellationToken);
        }

        if (!string.IsNullOrWhiteSpace(conversationId))
        {
            await TouchConversationAsync(connection, conversationId, cancellationToken);
        }
    }

    private static ConversationThread MapConversation(DbDataReader reader)
    {
        return new ConversationThread(
            reader.GetString(0),
            reader.GetString(1),
            reader.GetString(2),
            DateTimeOffset.Parse(reader.GetString(3)),
            DateTimeOffset.Parse(reader.GetString(4)));
    }

    private static ConversationMessage MapMessage(DbDataReader reader)
    {
        return new ConversationMessage(
            reader.GetString(0),
            reader.GetString(1),
            reader.GetString(2),
            reader.GetString(3),
            reader.GetString(4),
            reader.GetInt32(5),
            DateTimeOffset.Parse(reader.GetString(6)),
            DateTimeOffset.Parse(reader.GetString(7)),
            reader.IsDBNull(8) ? null : reader.GetString(8));
    }

    private static async Task TouchConversationAsync(
        SqliteConnection connection,
        string conversationId,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            UPDATE conversations
            SET updated_at = $updatedAt
            WHERE id = $id;
            """;
        command.Parameters.AddWithValue("$id", conversationId);
        command.Parameters.AddWithValue("$updatedAt", DateTimeOffset.UtcNow.ToString("O"));

        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}
