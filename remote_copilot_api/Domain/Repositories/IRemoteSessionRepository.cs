using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Repositories;

public interface IRemoteSessionRepository
{
    Task<IReadOnlyList<RemoteSession>> GetAllAsync(string? workspaceId, CancellationToken cancellationToken);

    Task<RemoteSession?> GetByIdAsync(string sessionId, CancellationToken cancellationToken);

    Task<RemoteSession?> DeleteAsync(string sessionId, CancellationToken cancellationToken);

    Task<RemoteSession> CreateAsync(string? workspaceId, string title, CancellationToken cancellationToken);

    Task UpdateCopilotSessionIdAsync(string sessionId, string copilotSessionId, CancellationToken cancellationToken);

    Task UpdateTitleAsync(string sessionId, string title, CancellationToken cancellationToken);

    Task TouchAsync(string sessionId, CancellationToken cancellationToken);
}
