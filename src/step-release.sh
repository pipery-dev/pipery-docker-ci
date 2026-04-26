#!/usr/bin/env psh
set -euo pipefail

REGISTRY="${INPUT_REGISTRY:-ghcr.io}"
REGISTRY_USERNAME="${INPUT_REGISTRY_USERNAME:-}"
REGISTRY_PASSWORD="${INPUT_REGISTRY_PASSWORD:-}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"
VERSION="${INPUT_VERSION:-}"
SHORT_SHA="${GITHUB_SHA:-}"
SHORT_SHA="${SHORT_SHA:0:7}"

if [ -z "$REGISTRY_PASSWORD" ]; then
  echo "No registry credentials provided, skipping push."
  exit 0
fi

if [ -z "$IMAGE_NAME" ]; then
  echo "No image name provided, skipping push."
  exit 0
fi

echo "Logging in to registry: $REGISTRY..."
echo "$REGISTRY_PASSWORD" | docker login "$REGISTRY" -u "$REGISTRY_USERNAME" --password-stdin

docker push "${IMAGE_NAME}:${IMAGE_TAG}"
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:sha-${SHORT_SHA}"
docker push "${IMAGE_NAME}:sha-${SHORT_SHA}"

if [ -n "$VERSION" ]; then
  MINOR="$(echo "$VERSION" | cut -d. -f1-2)"
  MAJOR="$(echo "$VERSION" | cut -d. -f1)"
  docker push "${IMAGE_NAME}:${VERSION}"
  docker push "${IMAGE_NAME}:${MINOR}"
  docker push "${IMAGE_NAME}:${MAJOR}"
fi

echo "Image pushed: ${IMAGE_NAME}:${IMAGE_TAG} sha-${SHORT_SHA}"
