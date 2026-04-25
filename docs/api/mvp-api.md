# MVP API

## Health

### `GET /api/health`

Returns API health, database availability, and Copilot headless server availability.

## Container runtime

### `GET /api/container/runtime`

Returns runtime metadata such as Copilot server URL, connection status, and configured workspace count.

## Workspaces

### `GET /api/workspaces`

Returns the current list of discovered projects exposed from the mounted root directory.

### `POST /api/workspaces`

Creates a new project by creating a child directory under the configured workspace root.

```json
{
  "name": "sample-repo"
}
```

### `PUT /api/workspaces/{workspaceId}`

Renames an existing project. The backing directory is renamed as part of the operation.

```json
{
  "name": "sample-repo-renamed"
}
```

### `DELETE /api/workspaces/{workspaceId}`

Deletes a project and removes its backing directory from the mounted root.

### `POST /api/workspaces/sync`

Rescans the mounted root directory and synchronizes the persisted catalog with the current child directories.

## Sessions

### `GET /api/sessions`

Returns persisted remote sessions.

### `POST /api/sessions`

Creates a session and its initial conversation.

`workspaceId` is optional. When omitted, the session is created in general chat mode with no attached repository.

```json
{
  "workspaceId": "sample-repo",
  "title": "Session for Sample Repo"
}
```

General mode example:

```json
{
  "title": "General Copilot Session"
}
```

## Conversations

### `GET /api/conversations/{conversationId}`

Returns the conversation thread plus all persisted messages.

### `POST /api/conversations/{conversationId}/messages`

Creates the user message, creates an assistant placeholder, and starts the Copilot execution asynchronously.

```json
{
  "content": "Summarize this repository and suggest the next refactor."
}
```

### `GET /api/conversations/{conversationId}/events`

SSE stream for the full GitHub Copilot SDK session timeline.

The `event:` line matches the SDK event type exactly, for example:

- `assistant.turn_start`
- `assistant.reasoning_delta`
- `assistant.message_delta`
- `tool.execution_start`
- `tool.execution_progress`
- `tool.execution_complete`
- `skill.invoked`
- `permission.requested`
- `session.error`
- `session.idle`

Each `data:` payload uses this envelope:

```json
{
  "type": "assistant.reasoning_delta",
  "conversationId": "conversation-123",
  "timestamp": "2026-04-12T18:24:53.3062500+00:00",
  "messageId": "message-456",
  "eventId": "d20d61dd-10b0-4a52-89fd-7fb6f217f41c",
  "parentEventId": "090a84f7-5a3b-4f1f-bf1e-c8809e117078",
  "ephemeral": true,
  "source": "sdk",
  "data": {
    "reasoningId": "reasoning-1",
    "deltaContent": "Inspecting the workspace structure..."
  }
}
```

Notes:

- `data` is the raw event payload exposed by `GitHub.Copilot.SDK` for that event type.
- `messageId` is the persisted conversation message ID when the backend can correlate the SDK event with a local message.
- The stream is no longer limited to assistant text deltas; it includes reasoning, tools, skills, permissions, subagents, MCP, and session lifecycle events.

## Runtime configuration

The backend only needs the root path that contains all projects:

```json
{
  "WorkspaceRoot": {
    "Path": "/workspaces"
  }
}
```

Each child directory under that root is treated as an independent project. Copilot sessions remain linked to the selected project through `workspaceId`, while general chat continues to use `workspaceId = null`.
