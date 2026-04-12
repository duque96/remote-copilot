# RemoteCopilot

RemoteCopilot is a self-hosted MVP for using **GitHub Copilot CLI remotely**. It combines:

- a **Flutter** conversational client;
- an **ASP.NET Core Minimal API** backend;
- a **Docker** runtime where the backend, Copilot CLI, and the published Flutter web client live together in isolation.

The current MVP focuses on:

- opening a general remote conversation with Copilot;
- optionally selecting a mounted workspace/repository;
- creating persistent remote sessions;
- chatting with Copilot through the backend;
- streaming assistant output back to the client;
- keeping the architecture ready for future support of sessions, repositories, MCPs, and skills.

## Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter 3.41.6 / Dart 3.11.4 |
| Backend | ASP.NET Core .NET 10 Minimal API |
| Copilot runtime | GitHub Copilot CLI in headless server mode (`--headless`) |
| Persistence | SQLite |
| Orchestration | Docker Compose |

## Repository layout

```text
RemoteCopilot/
  remote_copilot_app/
  remote_copilot_api/
  shared/
    contracts/
  docs/
    architecture/
    decisions/
    api/
    product/
    operations/
  scripts/
  workspaces/
```

## How it works

1. The API lists workspaces that are mounted into the Docker container.
2. The Flutter app can create either a general session or a workspace-linked session.
3. The backend uses the **GitHub Copilot .NET SDK** to connect to a Copilot CLI server started in headless mode (`--headless`).
4. Workspace-linked sessions are created with their own `WorkingDirectory`, so Copilot operates inside the selected repository, while general sessions run without a repository binding.
5. Conversation metadata is persisted in SQLite while Copilot session state is persisted by the CLI/SDK runtime.
6. The API exposes the full Copilot SDK session event stream over SSE, including reasoning, tool execution, skills, permissions, and assistant output in real time.

## Local development

### Backend

```bash
cd remote_copilot_api
dotnet build
dotnet run
```

### Flutter app

```bash
cd remote_copilot_app
flutter pub get
flutter run
```

## Docker runtime

The intended self-hosted setup is:

```bash
docker compose up --build
```

The image builds the ASP.NET Core API, installs the Copilot CLI, publishes the Flutter app as a web bundle, and serves that bundle from the API container.

The compose file mounts `./workspaces` into the container so the API can expose those repositories as selectable workspaces.

## Copilot authentication in Docker

The container expects Copilot CLI to be authenticated inside `/data/copilot-home`.

Copilot CLI also supports token-based authentication through environment variables:

- `GH_TOKEN`
- `GITHUB_TOKEN`

If both are present, `GH_TOKEN` takes precedence.

Two practical options:

1. Mount a persistent volume and log in once from inside the container.
2. Mount a pre-existing authenticated Copilot CLI config into `/data/copilot-home`.
3. Export a fine-grained PAT with the `Copilot Requests` permission as `GH_TOKEN` or `GITHUB_TOKEN` before running `docker compose up`.

See `docs/operations/docker-runtime.md` for the operational details.

## Documentation

- `docs/architecture/overview.md`
- `docs/api/mvp-api.md`
- `docs/product/mvp-scope.md`
- `docs/operations/docker-runtime.md`
- `docs/decisions/adr-0001-public-dependencies-only.md`
- `docs/decisions/adr-0002-minimal-shared-layer.md`
