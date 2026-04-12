# ADR-0001: Public dependencies only

## Status

Accepted

## Context

The project owner explicitly requested that this repository must not depend on internal/private utility libraries referenced by external architecture skills.

## Decision

RemoteCopilot uses only:

- framework capabilities from Flutter and .NET;
- public packages available from pub.dev and NuGet;
- small repo-local primitives when they add clear value.

## Consequences

- the repo remains publishable and self-contained;
- architecture guidance can still be reused without importing private ecosystems;
- some repeated plumbing is acceptable if it avoids coupling the project to private code.
