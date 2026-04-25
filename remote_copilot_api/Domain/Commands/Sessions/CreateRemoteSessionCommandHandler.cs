using RemoteCopilot.Api.Common.Abstractions;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;

namespace RemoteCopilot.Api.Domain.Commands.Sessions;

public sealed class CreateRemoteSessionCommandHandler(
    IWorkspaceRepository workspaceRepository,
    IRemoteSessionRepository remoteSessionRepository,
    IConversationRepository conversationRepository)
    : ICommandHandler<CreateRemoteSessionCommand, AppResult<CreateRemoteSessionCommandResult>>
{
    public async Task<AppResult<CreateRemoteSessionCommandResult>> HandleAsync(
        CreateRemoteSessionCommand command,
        CancellationToken cancellationToken)
    {
        WorkspaceDefinition? workspace = null;
        if (!string.IsNullOrWhiteSpace(command.WorkspaceId))
        {
            workspace = await workspaceRepository.GetByIdAsync(command.WorkspaceId, cancellationToken);
            if (workspace is null)
            {
                return AppResult<CreateRemoteSessionCommandResult>.Failure(
                    "workspace_not_found",
                    $"The workspace '{command.WorkspaceId}' was not found.");
            }
        }

        var title = string.IsNullOrWhiteSpace(command.Title)
            ? workspace is null
                ? "General Copilot Session"
                : $"Session for {workspace.Name}"
            : command.Title.Trim();

        var session = await remoteSessionRepository.CreateAsync(workspace?.Id, title, cancellationToken);
        var conversation = await conversationRepository.CreateAsync(session.Id, title, cancellationToken);

        if (workspace is not null)
        {
            await workspaceRepository.TouchAsync(workspace.Id, cancellationToken);
        }

        return AppResult<CreateRemoteSessionCommandResult>.Success(
            new CreateRemoteSessionCommandResult(session, conversation));
    }
}
