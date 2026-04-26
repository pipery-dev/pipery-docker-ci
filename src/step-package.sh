#!/usr/bin/env psh
set -euo pipefail

IMAGE_NAME="${INPUT_IMAGE_NAME:-}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"

if [ -z "$IMAGE_NAME" ]; then
  echo "No image name set, skipping packaging step."
  exit 0
fi

TAG="${IMAGE_NAME}:${IMAGE_TAG}"
VERSION="${INPUT_VERSION:-}"

if [ -z "$VERSION" ]; then
  echo "No version set, skipping version alias tagging."
  exit 0
fi

MAJOR="$(echo "$VERSION" | cut -d. -f1)"
MINOR="$(echo "$VERSION" | cut -d. -f1-2)"

echo "Tagging image $TAG with version aliases..."

docker tag "$TAG" "${IMAGE_NAME}:${VERSION}"
docker tag "$TAG" "${IMAGE_NAME}:${MINOR}"
docker tag "$TAG" "${IMAGE_NAME}:${MAJOR}"

echo "Image tagged: ${IMAGE_NAME}:${VERSION}, ${IMAGE_NAME}:${MINOR}, ${IMAGE_NAME}:${MAJOR}"
