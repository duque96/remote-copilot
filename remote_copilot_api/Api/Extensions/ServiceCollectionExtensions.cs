using System.Text.Json;
using Microsoft.AspNetCore.Http.Json;
using RemoteCopilot.Api.Domain.Extensions;
using RemoteCopilot.Api.Infrastructure.Extensions;

namespace RemoteCopilot.Api.Api.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddApiServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOpenApi()
            .AddCors(options =>
            {
                options.AddPolicy(
                    "remote-copilot-client",
                    policy => policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
            });

        services
            .AddDomainServices()
            .AddInfrastructureServices(configuration);

        return services;
    }
}
