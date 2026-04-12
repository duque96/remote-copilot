using RemoteCopilot.Api.Api.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApiServices(builder.Configuration);

var app = builder.Build();

await app.InitializeApiAsync();

app.Run();
