using GitHub.Copilot.SDK;
using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Infrastructure.Managers;

public sealed class CopilotClientAccessor(
    IOptions<CopilotOptions> options,
    ILogger<CopilotClientAccessor> logger)
    : IAsyncDisposable
{
    public sealed record CopilotModelSummary(string Id, string Name, object? Multiplier);

    private readonly SemaphoreSlim _gate = new(1, 1);
    private CopilotClient? _client;

    public async Task<CopilotClient> GetClientAsync(CancellationToken cancellationToken)
    {
        await _gate.WaitAsync(cancellationToken);
        try
        {
            if (_client is not null)
            {
                return _client;
            }

            _client = new CopilotClient(new CopilotClientOptions
            {
                AutoStart = false,
                CliUrl = options.Value.ServerUrl,
                UseStdio = false,
                Logger = logger,
            });


            await _client.StartAsync(cancellationToken);

            return _client;
        }
        finally
        {
            _gate.Release();
        }
    }

    public async Task<IReadOnlyList<CopilotModelSummary>> GetModelsAsync(CancellationToken cancellationToken)
    {
        try
        {
            var client = await GetClientAsync(cancellationToken);
            var result = await client.ListModelsAsync(cancellationToken);

            return result
                .Select(model => new CopilotModelSummary(
                    model.Id,
                    string.IsNullOrWhiteSpace(model.Name) ? model.Id : model.Name,
                    model.Billing?.Multiplier))
                .ToList();
        }
        catch (Exception exception)
        {
            logger.LogWarning(exception, "Failed to list Copilot models.");
            return [];
        }
    }

    public async Task<bool> PingAsync(CancellationToken cancellationToken)
    {
        try
        {
            var client = await GetClientAsync(cancellationToken);
            await client.PingAsync("remote-copilot");
            return true;
        }
        catch (Exception exception)
        {
            logger.LogWarning(exception, "Copilot CLI server ping failed.");
            return false;
        }
    }

    public async ValueTask DisposeAsync()
    {
        if (_client is not null)
        {
            await _client.DisposeAsync();
        }

        _gate.Dispose();
    }
}
