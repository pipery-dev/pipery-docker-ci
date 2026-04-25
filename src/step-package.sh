#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"

if [ -z "$IMAGE_NAME" ]; then
  echo "No image name set, skipping packaging step."
  exit 0
fi

TAG="${IMAGE_NAME}:${IMAGE_TAG}"

# Try to determine the version from GITHUB_OUTPUT or tag
VERSION="${INPUT_VERSION:-}"

if [ -z "$VERSION" ]; then
  echo "No version set, skipping version alias tagging."
  exit 0
fi

# Parse version into major.minor.patch components
MAJOR="$(echo "$VERSION" | cut -d. -f1)"
MINOR="$(echo "$VERSION" | cut -d. -f1-2)"

echo "Tagging image $TAG with version aliases..."

if command -v psh &>/dev/null && psh --version &>/dev/null 2>&1; then
  psh -log-file "$LOG" -fail-on-error -c "docker tag ${TAG} ${IMAGE_NAME}:${VERSION}"
  psh -log-file "$LOG" -fail-on-error -c "docker tag ${TAG} ${IMAGE_NAME}:${MINOR}"
  psh -log-file "$LOG" -fail-on-error -c "docker tag ${TAG} ${IMAGE_NAME}:${MAJOR}"
else
  docker tag "$TAG" "${IMAGE_NAME}:${VERSION}"
  docker tag "$TAG" "${IMAGE_NAME}:${MINOR}"
  docker tag "$TAG" "${IMAGE_NAME}:${MAJOR}"
fi

echo "Image tagged: ${IMAGE_NAME}:${VERSION}, ${IMAGE_NAME}:${MINOR}, ${IMAGE_NAME}:${MAJOR}"
