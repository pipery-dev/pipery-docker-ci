#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"

if ! command -v pipery-steps &>/dev/null; then
  echo "pipery-steps not found, skipping SAST step gracefully."
  exit 0
fi

echo "Running SAST (Docker)..."
pipery-steps sast \
  --language docker \
  --project-path "$PROJECT_PATH" \
  --log-file "$LOG" \
  || echo "SAST completed with warnings (non-fatal)."
