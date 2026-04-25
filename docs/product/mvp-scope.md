# MVP scope

## In scope

- single-user self-hosted deployment;
- Flutter conversational client;
- ASP.NET Core backend inside Docker;
- Copilot CLI server mode via `--headless`;
- general remote conversation mode without a workspace;
- durable persistence of sessions and messages;
- project discovery from a mounted root directory;
- project creation, rename, deletion, and manual sync from the app;
- workspace-linked conversation mode for repository-aware work;
- real-time assistant streaming.

## Out of scope for the first cut

- multi-user tenancy;
- direct repository cloning from the app;
- MCP installation UI;
- skills management UI;
- advanced permission approval UX;
- production-grade auth flows.

## Designed for later evolution

The current structure intentionally leaves room for:

- visible session history management;
- repository source providers beyond mounted volumes;
- MCP server registration;
- skill directory management;
- richer execution controls and diagnostics.
