namespace RemoteCopilot.Api.Infrastructure.Options;

public sealed class PersistenceOptions
{
    public const string SectionName = "Persistence";

    public string ConnectionString { get; set; } = "Data Source=./data/remote-copilot.db";
}
