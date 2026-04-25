using GitHub.Copilot.SDK;
using Microsoft.Extensions.Options;
using RemoteCopilot.Api.Infrastructure.Options;

namespace RemoteCopilot.Api.Infrastructure.Managers;

public sealed class CopilotPermissionService(IOptions<PermissionPolicyOptions> options)
{
    public Task<PermissionRequestResult> EvaluateAsync(
        string? workspacePath,
        PermissionRequest request,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        if (request is PermissionRequestRead readRequest)
        {
            if (string.IsNullOrWhiteSpace(workspacePath))
            {
                return Task.FromResult(DenyByRules());
            }

            var fileName = readRequest.Path ?? string.Empty;
            return Task.FromResult(IsPathInsideWorkspace(fileName, workspacePath)
                ? Approve()
                : DenyByRules());
        }

        if (request is PermissionRequestWrite writeRequest)
        {
            if (string.IsNullOrWhiteSpace(workspacePath))
            {
                return Task.FromResult(DenyByRules());
            }

            var fileName = writeRequest.FileName ?? string.Empty;
            return Task.FromResult(IsPathInsideWorkspace(fileName, workspacePath)
                ? Approve()
                : DenyByRules());
        }

        if (request is PermissionRequestShell shellRequest)
        {
            if (string.IsNullOrWhiteSpace(workspacePath))
            {
                return Task.FromResult(DenyByRules());
            }

            var command = shellRequest.FullCommandText?.Trim() ?? string.Empty;
            if (string.IsNullOrWhiteSpace(command))
            {
                return Task.FromResult(DenyByRules());
            }

            if (options.Value.DeniedShellFragments.Any(fragment =>
                    command.Contains(fragment, StringComparison.OrdinalIgnoreCase)))
            {
                return Task.FromResult(DenyByRules());
            }

            if (options.Value.AllowShellByDefault)
            {
                return Task.FromResult(Approve());
            }

            return Task.FromResult(DenyByRules());
        }

        return Task.FromResult(Approve());
    }

    private static bool IsPathInsideWorkspace(string candidatePath, string workspacePath)
    {
        try
        {
            var fullWorkspacePath = Path.TrimEndingDirectorySeparator(Path.GetFullPath(workspacePath));
            var fullCandidatePath = Path.GetFullPath(candidatePath);

            if (string.Equals(fullWorkspacePath, fullCandidatePath, StringComparison.Ordinal))
            {
                return true;
            }

            return fullCandidatePath.StartsWith(
                fullWorkspacePath + Path.DirectorySeparatorChar,
                StringComparison.Ordinal);
        }
        catch
        {
            return false;
        }
    }

    private static PermissionRequestResult Approve() => new()
    {
        Kind = PermissionRequestResultKind.Approved
    };

    private static PermissionRequestResult DenyByRules() => new()
    {
        Kind = PermissionRequestResultKind.DeniedByRules
    };
}
