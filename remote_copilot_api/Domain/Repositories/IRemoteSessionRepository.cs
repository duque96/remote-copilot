using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Repositories;

public interface IRemoteSessionRepository
{
    Task<IReadOnlyList<RemoteSession>> GetAllAsync(CancellationToken cancellationToken);

    Task<RemoteSession?> GetByIdAsync(string sessionId, CancellationToken cancellationToken);

    Task<RemoteSession> CreateAsync(string? workspaceId, string title, CancellationToken cancellationToken);

    Task UpdateCopilotSessionIdAsync(string sessionId, string copilotSessionId, CancellationToken cancellationToken);

    Task TouchAsync(string sessionId, CancellationToken cancellationToken);
}
