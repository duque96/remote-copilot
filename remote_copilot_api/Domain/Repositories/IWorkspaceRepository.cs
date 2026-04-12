using RemoteCopilot.Api.Domain.Model;

namespace RemoteCopilot.Api.Domain.Repositories;

public interface IWorkspaceRepository
{
    Task<IReadOnlyList<WorkspaceDefinition>> GetAllAsync(CancellationToken cancellationToken);

    Task<WorkspaceDefinition?> GetByIdAsync(string workspaceId, CancellationToken cancellationToken);
}
