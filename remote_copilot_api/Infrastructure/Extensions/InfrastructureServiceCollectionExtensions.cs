using RemoteCopilot.Api.Domain.Repositories;
using RemoteCopilot.Api.Domain.Services;
using RemoteCopilot.Api.Infrastructure.Adapters;
using RemoteCopilot.Api.Infrastructure.Managers;
using RemoteCopilot.Api.Infrastructure.Options;
using RemoteCopilot.Api.Infrastructure.Persistence;
using RemoteCopilot.Api.Infrastructure.Repositories;

namespace RemoteCopilot.Api.Infrastructure.Extensions;

public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.Configure<PersistenceOptions>(configuration.GetSection(PersistenceOptions.SectionName));
        services.Configure<CopilotOptions>(configuration.GetSection(CopilotOptions.SectionName));
        services.Configure<WorkspaceCatalogOptions>(configuration.GetSection(WorkspaceCatalogOptions.SectionName));
        services.Configure<PermissionPolicyOptions>(configuration.GetSection(PermissionPolicyOptions.SectionName));

        services.AddSingleton<SqliteConnectionFactory>();
        services.AddSingleton<SqliteDatabaseInitializer>();
        services.AddSingleton<CopilotClientAccessor>();
        services.AddSingleton<CopilotPermissionService>();
        services.AddSingleton<IConversationStreamPublisher, ConversationStreamPublisher>();

        services.AddScoped<IWorkspaceRepository, SqliteWorkspaceRepository>();
        services.AddScoped<IRemoteSessionRepository, SqliteRemoteSessionRepository>();
        services.AddScoped<IConversationRepository, SqliteConversationRepository>();
        services.AddScoped<ICopilotConversationOrchestrator, CopilotConversationOrchestrator>();

        return services;
    }
}
