using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Infrastructure.Persistence;

public sealed class SqliteDatabaseInitializer(
    SqliteConnectionFactory connectionFactory,
    IOptions<WorkspaceCatalogOptions> workspaceOptions)
{
    public async Task InitializeAsync()
    {
        var connectionStringBuilder = new SqliteConnectionStringBuilder(
            connectionFactory.CreateConnection().ConnectionString);
        var directory = Path.GetDirectoryName(connectionStringBuilder.DataSource);
        if (!string.IsNullOrWhiteSpace(directory))
        {
            Directory.CreateDirectory(directory);
        }

        await using var connection = connectionFactory.CreateConnection();
        await connection.OpenAsync();

        await using var command = connection.CreateCommand();
        command.CommandText =
            """
            CREATE TABLE IF NOT EXISTS workspaces (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                mounted_path TEXT NOT NULL,
                source_kind TEXT NOT NULL,
                created_at TEXT NOT NULL,
                last_used_at TEXT NULL
            );

            CREATE TABLE IF NOT EXISTS sessions (
                id TEXT PRIMARY KEY,
                workspace_id TEXT NULL,
                title TEXT NOT NULL,
                copilot_session_id TEXT NULL,
                status TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                FOREIGN KEY(workspace_id) REFERENCES workspaces(id)
            );

            CREATE TABLE IF NOT EXISTS conversations (
                id TEXT PRIMARY KEY,
                session_id TEXT NOT NULL,
                title TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                FOREIGN KEY(session_id) REFERENCES sessions(id)
            );

            CREATE TABLE IF NOT EXISTS messages (
                id TEXT PRIMARY KEY,
                conversation_id TEXT NOT NULL,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                status TEXT NOT NULL,
                sequence INTEGER NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                error TEXT NULL,
                FOREIGN KEY(conversation_id) REFERENCES conversations(id)
            );
            """;

        await command.ExecuteNonQueryAsync();

        foreach (var workspace in workspaceOptions.Value.Items)
        {
            await using var upsert = connection.CreateCommand();
            upsert.CommandText =
                """
                INSERT INTO workspaces (id, name, mounted_path, source_kind, created_at, last_used_at)
                VALUES ($id, $name, $mountedPath, $sourceKind, $createdAt, NULL)
                ON CONFLICT(id) DO UPDATE SET
                    name = excluded.name,
                    mounted_path = excluded.mounted_path,
                    source_kind = excluded.source_kind;
                """;
            upsert.Parameters.AddWithValue("$id", workspace.Id);
            upsert.Parameters.AddWithValue("$name", workspace.Name);
            upsert.Parameters.AddWithValue("$mountedPath", workspace.MountedPath);
            upsert.Parameters.AddWithValue("$sourceKind", workspace.SourceKind);
            upsert.Parameters.AddWithValue("$createdAt", DateTimeOffset.UtcNow.ToString("O"));

            await upsert.ExecuteNonQueryAsync();
        }
    }
}
