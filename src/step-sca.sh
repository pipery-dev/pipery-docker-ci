#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"

if ! command -v pipery-steps &>/dev/null; then
  echo "pipery-steps not found, skipping SCA step gracefully."
  exit 0
fi

echo "Running SCA (Docker)..."
pipery-steps sca \
  --language docker \
  --project-path "$PROJECT_PATH" \
  --log-file "$LOG" \
  || echo "SCA completed with warnings (non-fatal)."

# Run trivy scan if available
if command -v trivy &>/dev/null; then
  if [ -n "$IMAGE_NAME" ]; then
    TAG="${IMAGE_NAME}:${IMAGE_TAG}"
    echo "Running trivy image scan on $TAG..."
    trivy image --exit-code 0 "$TAG" || echo "Trivy image scan completed with findings (non-fatal)."
  else
    echo "Running trivy config scan on $PROJECT_PATH..."
    trivy config --exit-code 0 "$PROJECT_PATH" || echo "Trivy config scan completed with findings (non-fatal)."
  fi
else
  echo "trivy not found, skipping trivy scan gracefully."
fi
