# Architecture overview

## MVP topology

```text
Flutter app
    |
    | HTTP + SSE
    v
ASP.NET Core Minimal API
    |
    | GitHub.Copilot.SDK
    v
Copilot CLI headless server
    |
    | mounted workspace
    v
Git repository inside Docker volume mount
```

## Core concepts

- **Workspace**: a repository/path mounted into the Docker container and exposed to the UI.
- **Session**: a remote Copilot execution context that can be general or linked to one workspace.
- **Conversation**: the chat thread shown in the app for a session.
- **Message**: a user or assistant message persisted by the backend.

## Backend architecture

The backend uses a single ASP.NET Core project with internal separation into:

- `Api`: Minimal API endpoints and HTTP contracts.
- `Domain`: models, repository contracts, commands, and orchestration abstractions.
- `Infrastructure`: SQLite repositories, Copilot SDK integration, options, and streaming managers.
- `Common`: small shared primitives for command handling and typed results.

## Frontend architecture

The Flutter app is structured in layers:

- `domain/`: app models and repository contracts.
- `infrastructure/`: HTTP/SSE clients, persistence of local settings, repository implementation.
- `ui/`: startup flow, chat UI, settings, and reusable components.

## Runtime strategy

The backend does not implement a hand-made pseudo terminal bridge.

Instead it uses:

- **GitHub Copilot .NET SDK** for session lifecycle;
- **Copilot CLI headless server mode** (`--headless`) for the runtime process;
- an optional session-specific `WorkingDirectory` so workspace-linked sessions operate inside the selected repository while general sessions run without repository attachment.

## Persistence

Two persistence layers coexist:

1. **SQLite** for application data:
   - workspaces
   - sessions
   - conversations
   - messages
2. **Copilot session state** managed by the SDK/CLI runtime:
   - context persistence
   - infinite session workspace/checkpoints

## Security posture for the MVP

- single-user self-hosted deployment;
- workspaces restricted to mounted paths configured by the host;
- permission handler with shell allowlist and file access checks for workspace-linked sessions;
- general sessions deny workspace file and shell access because they have no attached repository context;
- runtime isolated inside Docker;
- no private/internal libraries.
