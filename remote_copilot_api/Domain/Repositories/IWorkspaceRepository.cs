using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Repositories;

public interface IWorkspaceRepository
{
    Task<IReadOnlyList<WorkspaceDefinition>> GetAllAsync(CancellationToken cancellationToken);

    Task<WorkspaceDefinition?> GetByIdAsync(string workspaceId, CancellationToken cancellationToken);

    Task<IReadOnlyList<WorkspaceDefinition>> SyncAsync(
        IReadOnlyList<WorkspaceDefinition> discoveredWorkspaces,
        CancellationToken cancellationToken);

    Task<WorkspaceDefinition> UpsertAsync(WorkspaceDefinition workspace, CancellationToken cancellationToken);

    Task<WorkspaceDefinition?> ReplaceAsync(
        string workspaceId,
        WorkspaceDefinition workspace,
        CancellationToken cancellationToken);

    Task DeleteAsync(string workspaceId, CancellationToken cancellationToken);

    Task TouchAsync(string workspaceId, CancellationToken cancellationToken);
}
