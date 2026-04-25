#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
REGISTRY="${INPUT_REGISTRY:-ghcr.io}"
REGISTRY_USERNAME="${INPUT_REGISTRY_USERNAME:-}"
REGISTRY_PASSWORD="${INPUT_REGISTRY_PASSWORD:-}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"

if [ -z "$REGISTRY_PASSWORD" ]; then
  echo "No registry credentials provided, skipping push."
  exit 0
fi

if [ -z "$IMAGE_NAME" ]; then
  echo "No image name provided, skipping push."
  exit 0
fi

echo "Logging in to registry: $REGISTRY..."
if command -v psh &>/dev/null && psh --version &>/dev/null 2>&1; then
  echo "$REGISTRY_PASSWORD" | psh -log-file "$LOG" -fail-on-error -c "docker login ${REGISTRY} -u ${REGISTRY_USERNAME} --password-stdin"
  psh -log-file "$LOG" -fail-on-error -c "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
else
  echo "$REGISTRY_PASSWORD" | docker login "$REGISTRY" -u "$REGISTRY_USERNAME" --password-stdin
  docker push "${IMAGE_NAME}:${IMAGE_TAG}"
fi

echo "Image pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
