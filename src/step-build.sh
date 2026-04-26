#!/usr/bin/env psh
set -euo pipefail

PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"
DOCKERFILE="${INPUT_DOCKERFILE:-Dockerfile}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-test-image}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"
BUILD_ARGS_RAW="${INPUT_BUILD_ARGS:-}"

BUILD_ARGS_FLAGS=()
if [ -n "$BUILD_ARGS_RAW" ]; then
  IFS=',' read -ra ARGS_ARRAY <<< "$BUILD_ARGS_RAW"
  for arg in "${ARGS_ARRAY[@]}"; do
    arg="$(echo "$arg" | xargs)"
    if [ -n "$arg" ]; then
      BUILD_ARGS_FLAGS+=("--build-arg" "$arg")
    fi
  done
fi

TAG="${IMAGE_NAME}:${IMAGE_TAG}"
DOCKERFILE_PATH="${PROJECT_PATH}/${DOCKERFILE}"

echo "Building Docker image: $TAG from $DOCKERFILE_PATH..."

docker build --load -f "$DOCKERFILE_PATH" -t "$TAG" "${BUILD_ARGS_FLAGS[@]}" "$PROJECT_PATH"

echo "BUILT_IMAGE=$TAG" >> "${GITHUB_ENV:-/dev/null}"
echo "Image built successfully: $TAG"
