using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Infrastructure.Persistence;

public sealed class SqliteConnectionFactory(IOptions<PersistenceOptions> options)
{
    public SqliteConnection CreateConnection()
    {
        return new SqliteConnection(options.Value.ConnectionString);
    }
}
