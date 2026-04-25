#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-test-image}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"

TAG="${IMAGE_NAME}:${IMAGE_TAG}"

echo "Running container smoke test on $TAG..."

if command -v psh &>/dev/null && psh --version &>/dev/null 2>&1; then
  psh -log-file "$LOG" -fail-on-error -c "docker run --rm ${TAG} echo 'Container smoke test OK'"
else
  docker run --rm "$TAG" echo 'Container smoke test OK'
fi

echo "Smoke test passed."
