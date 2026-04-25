using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Infrastructure.Managers;

public sealed class WorkspaceCatalogManager(
    IWorkspaceRepository workspaceRepository,
    IOptions<WorkspaceRootOptions> options,
    ILogger<WorkspaceCatalogManager> logger)
{
    public async Task<IReadOnlyList<WorkspaceDefinition>> SyncAsync(CancellationToken cancellationToken)
    {
        var discovered = DiscoverWorkspaces();
        var synchronized = await workspaceRepository.SyncAsync(discovered, cancellationToken);

        logger.LogInformation(
            "Synchronized {WorkspaceCount} workspaces from root path {WorkspaceRootPath}.",
            synchronized.Count,
            GetRootPath());

        return synchronized;
    }

    public async Task<AppResult<WorkspaceDefinition>> CreateAsync(string name, CancellationToken cancellationToken)
    {
        var normalizedName = NormalizeWorkspaceName(name);
        if (normalizedName is null)
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_invalid_name",
                "The project name is invalid.");
        }

        var rootPath = EnsureRootDirectory();
        var workspacePath = Path.Combine(rootPath, normalizedName);
        if (Directory.Exists(workspacePath))
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_already_exists",
                $"The project '{normalizedName}' already exists.");
        }

        Directory.CreateDirectory(workspacePath);

        var workspace = new WorkspaceDefinition(
            normalizedName,
            normalizedName,
            workspacePath,
            "volume",
            DateTimeOffset.UtcNow,
            null);

        var saved = await workspaceRepository.UpsertAsync(workspace, cancellationToken);
        return AppResult<WorkspaceDefinition>.Success(saved);
    }

    public async Task<AppResult<WorkspaceDefinition>> RenameAsync(
        string workspaceId,
        string name,
        CancellationToken cancellationToken)
    {
        var workspace = await workspaceRepository.GetByIdAsync(workspaceId, cancellationToken);
        if (workspace is null)
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_not_found",
                $"The project '{workspaceId}' was not found.");
        }

        var normalizedName = NormalizeWorkspaceName(name);
        if (normalizedName is null)
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_invalid_name",
                "The project name is invalid.");
        }

        if (string.Equals(workspace.Id, normalizedName, StringComparison.Ordinal))
        {
            return AppResult<WorkspaceDefinition>.Success(workspace);
        }

        var rootPath = EnsureRootDirectory();
        var targetPath = Path.Combine(rootPath, normalizedName);
        if (Directory.Exists(targetPath))
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_already_exists",
                $"The project '{normalizedName}' already exists.");
        }

        if (!Directory.Exists(workspace.MountedPath))
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_path_not_found",
                $"The project directory '{workspace.MountedPath}' does not exist.");
        }

        Directory.Move(workspace.MountedPath, targetPath);

        var renamedWorkspace = workspace with
        {
            Id = normalizedName,
            Name = normalizedName,
            MountedPath = targetPath,
        };

        var saved = await workspaceRepository.ReplaceAsync(workspace.Id, renamedWorkspace, cancellationToken);
        if (saved is null)
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_not_found",
                $"The project '{workspaceId}' was not found.");
        }

        return AppResult<WorkspaceDefinition>.Success(saved);
    }

    public async Task<AppResult<WorkspaceDefinition>> DeleteAsync(string workspaceId, CancellationToken cancellationToken)
    {
        var workspace = await workspaceRepository.GetByIdAsync(workspaceId, cancellationToken);
        if (workspace is null)
        {
            return AppResult<WorkspaceDefinition>.Failure(
                "workspace_not_found",
                $"The project '{workspaceId}' was not found.");
        }

        if (Directory.Exists(workspace.MountedPath))
        {
            Directory.Delete(workspace.MountedPath, recursive: true);
        }

        await workspaceRepository.DeleteAsync(workspaceId, cancellationToken);
        return AppResult<WorkspaceDefinition>.Success(workspace);
    }

    private IReadOnlyList<WorkspaceDefinition> DiscoverWorkspaces()
    {
        var rootPath = EnsureRootDirectory();

        return Directory
            .GetDirectories(rootPath)
            .Select(path => new DirectoryInfo(path))
            .Where(directory => !directory.Name.StartsWith(".", StringComparison.Ordinal))
            .OrderBy(directory => directory.Name, StringComparer.OrdinalIgnoreCase)
            .Select(directory => new WorkspaceDefinition(
                directory.Name,
                directory.Name,
                directory.FullName,
                "volume",
                DateTimeOffset.UtcNow,
                null))
            .ToList();
    }

    private string EnsureRootDirectory()
    {
        var rootPath = GetRootPath();
        Directory.CreateDirectory(rootPath);
        return rootPath;
    }

    private string GetRootPath()
    {
        var configuredPath = options.Value.Path?.Trim();
        var rootPath = string.IsNullOrWhiteSpace(configuredPath) ? "/workspaces" : configuredPath;
        return Path.GetFullPath(rootPath);
    }

    private static string? NormalizeWorkspaceName(string? rawValue)
    {
        var trimmed = rawValue?.Trim();
        if (string.IsNullOrWhiteSpace(trimmed))
        {
            return null;
        }

        if (trimmed is "." or "..")
        {
            return null;
        }

        if (trimmed.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
        {
            return null;
        }

        if (trimmed.IndexOf(Path.DirectorySeparatorChar) >= 0 || trimmed.IndexOf(Path.AltDirectorySeparatorChar) >= 0)
        {
            return null;
        }

        return trimmed;
    }
}