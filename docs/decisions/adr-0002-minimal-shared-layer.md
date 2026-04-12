# ADR-0002: Minimal shared layer inside the repo

## Status

Accepted

## Context

The MVP should start with a base that is cleaner and more extensible than a throwaway prototype, but without recreating a large internal framework.

## Decision

Allow a **minimal shared layer** inside each runtime where it materially improves consistency:

- backend `Common/` for result and command abstractions;
- `shared/contracts/` for transport notes and future shared contract artifacts.

## Consequences

- the repo keeps enough architectural structure to grow;
- the shared layer remains intentionally small;
- future MCP/skills/repository management features have a clear extension point.
