# Docker runtime

## Runtime model

The container runs:

1. **Copilot CLI** in headless server mode (`--headless`) on an internal port.
2. **ASP.NET Core API** on port `8080`.
3. **Flutter web bundle** served by the API from `wwwroot`.

The entrypoint script supervises both processes in the same container.

## Start

```bash
docker compose up --build
```

## Workspace mounting

The compose file mounts:

```text
./workspaces -> /workspaces
```

You can add or replace mounted repositories there, then expose them through the API configuration in `appsettings*.json`.

## Copilot authentication

The runtime uses:

```text
/data/copilot-home
```

as the effective home/config directory.

Typical approaches:

1. Start the container, exec into it, and authenticate once with Copilot CLI.
2. Mount an already authenticated Copilot configuration into `/data/copilot-home`.
3. Pass a fine-grained GitHub PAT with the `Copilot Requests` permission using `GH_TOKEN` or `GITHUB_TOKEN` in Docker Compose.

If both token variables are present, Copilot CLI uses `GH_TOKEN` first.

## Persistence

- SQLite database: `/data/remote-copilot.db`
- Copilot home/config: `/data/copilot-home`

Both live on the named Docker volume `remote-copilot-data`.

## Notes

- The current permission policy is allowlist-based for shell commands.
- File access is restricted to paths inside the selected workspace.
- If the Copilot headless server is unavailable, `/api/health` reports a degraded state.
