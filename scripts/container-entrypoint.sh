#!/usr/bin/env bash
set -euo pipefail

mkdir -p /data/copilot-home /workspaces

copilot --headless --port "${COPILOT_PORT:-${COPILOT_ACP_PORT:-3000}}" >/tmp/copilot-server.log 2>&1 &
COPILOT_PID=$!

dotnet RemoteCopilot.Api.dll &
API_PID=$!

cleanup() {
  for pid in "$API_PID" "$COPILOT_PID"; do
    if kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  done
}

trap cleanup EXIT INT TERM

wait -n "$API_PID" "$COPILOT_PID"
EXIT_CODE=$?

cleanup
wait || true

exit "$EXIT_CODE"
