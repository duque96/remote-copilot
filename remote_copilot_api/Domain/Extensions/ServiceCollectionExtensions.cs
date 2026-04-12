using RemoteCopilot.Api.Common.Abstractions;
using RemoteCopilot.Api.Common.Results;
using RemoteCopilot.Api.Domain.Commands.Conversations;
using RemoteCopilot.Api.Domain.Commands.Sessions;
using RemoteCopilot.Api.Domain.Model;
using RemoteCopilot.Api.Domain.Repositories;

namespace RemoteCopilot.Api.Domain.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddDomainServices(this IServiceCollection services)
    {
        services.AddScoped<ICommandHandler<CreateRemoteSessionCommand, AppResult<CreateRemoteSessionCommandResult>>, CreateRemoteSessionCommandHandler>();
        services.AddScoped<ICommandHandler<SendConversationMessageCommand, AppResult<SendConversationMessageCommandResult>>, SendConversationMessageCommandHandler>();

        return services;
    }
}
