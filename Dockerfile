# ========================================
# Build Web
# Compile the Flutter application for web.
# ========================================
FROM ghcr.io/cirruslabs/flutter:3.41.6 AS build-web
WORKDIR /src/remote_copilot_app

## Copy the minimum dependency manifests first to maximize Docker layer reuse.
COPY remote_copilot_app/pubspec.yaml remote_copilot_app/analysis_options.yaml remote_copilot_app/l10n.yaml ./

## Enable web support and restore Dart/Flutter packages.
RUN flutter config --enable-web \
    && flutter pub get

## Copy the full Flutter project and publish the production web bundle.
COPY remote_copilot_app/ ./

RUN flutter build web --release

# ========================================
# Build API
# Restore and publish the ASP.NET Core API.
# ========================================
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build-api
WORKDIR /src

## Copy the solution-level build metadata and the API project file for restore.
COPY remote_copilot_api/Directory.Build.props remote_copilot_api/Directory.Packages.props RemoteCopilot.sln ./
COPY remote_copilot_api/remote_copilot_api.csproj remote_copilot_api/

RUN dotnet restore RemoteCopilot.sln

## Copy the API sources and publish the application.
COPY remote_copilot_api/ remote_copilot_api/

RUN dotnet publish remote_copilot_api/remote_copilot_api.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

# ========================================
# Runtime
# Install Copilot CLI and assemble the final image.
# ========================================
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

## Install Node.js and the GitHub Copilot CLI used by the backend runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g @github/copilot \
    && rm -rf /var/lib/apt/lists/*

## Copy the published API and the generated Flutter web assets into the runtime image.
COPY --from=build-api /app/publish/ .
COPY --from=build-web /src/remote_copilot_app/build/web/ /app/wwwroot/
COPY scripts/container-entrypoint.sh /app/container-entrypoint.sh

## Prepare runtime directories and make the entrypoint executable.
RUN chmod +x /app/container-entrypoint.sh \
    && mkdir -p /data /workspaces

## Runtime configuration for the API and Copilot headless server.
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV HOME=/data/copilot-home
ENV COPILOT_PORT=3000

## Expose the HTTP port served by the ASP.NET Core application.
EXPOSE 8080

## Start both the API and the Copilot headless runtime.
ENTRYPOINT ["/app/container-entrypoint.sh"]
