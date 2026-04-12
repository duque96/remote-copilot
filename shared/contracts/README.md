# Shared contracts

This folder is intentionally lightweight.

It exists to hold:

- transport contracts that may later be shared between frontend and backend;
- JSON examples or OpenAPI-derived snapshots;
- protocol notes for SSE events and future MCP/skills configuration.

For the initial MVP, the source of truth for the HTTP contract is:

- `docs/api/mvp-api.md`
- the backend endpoint definitions under `remote_copilot_api/Api/Endpoints/`
