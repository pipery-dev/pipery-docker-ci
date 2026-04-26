#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"
GITHUB_TOKEN="${INPUT_GITHUB_TOKEN:-}"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "No GitHub token provided, skipping reintegration step."
  exit 0
fi

if ! command -v pipery-steps &>/dev/null; then
  echo "pipery-steps not found, skipping reintegration step gracefully."
  exit 0
fi

echo "Running reintegration..."
pipery-steps reintegrate \
  --project-path "$PROJECT_PATH" \
  --log-file "$LOG" \
  || echo "Reintegration completed with warnings (non-fatal)."
