#!/usr/bin/env psh
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"
VERSION_BUMP="${INPUT_VERSION_BUMP:-patch}"

if ! command -v pipery-steps &>/dev/null; then
  echo "pipery-steps not found, skipping versioning step gracefully."
  exit 0
fi

echo "Running versioning (Docker, bump=$VERSION_BUMP)..."
VERSION_OUTPUT="$(pipery-steps version \
  --language docker \
  --project-path "$PROJECT_PATH" \
  --bump "$VERSION_BUMP" \
  --log-file "$LOG" 2>&1)" || {
  echo "Versioning step completed with warnings: $VERSION_OUTPUT (non-fatal)."
  exit 0
}

echo "$VERSION_OUTPUT"

NEW_VERSION="$(echo "$VERSION_OUTPUT" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+' | tail -1 || true)"
if [ -n "$NEW_VERSION" ] && [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
  echo "Wrote version=$NEW_VERSION to GITHUB_OUTPUT"
fi
