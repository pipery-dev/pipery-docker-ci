#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"
DOCKERFILE="${INPUT_DOCKERFILE:-Dockerfile}"
IMAGE_NAME="${INPUT_IMAGE_NAME:-test-image}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"
BUILD_ARGS_RAW="${INPUT_BUILD_ARGS:-}"

# Parse comma-separated VAR=val into --build-arg flags
BUILD_ARGS_FLAGS=""
if [ -n "$BUILD_ARGS_RAW" ]; then
  IFS=',' read -ra ARGS_ARRAY <<< "$BUILD_ARGS_RAW"
  for arg in "${ARGS_ARRAY[@]}"; do
    arg="$(echo "$arg" | xargs)"  # trim whitespace
    if [ -n "$arg" ]; then
      BUILD_ARGS_FLAGS="$BUILD_ARGS_FLAGS --build-arg $arg"
    fi
  done
fi

TAG="${IMAGE_NAME}:${IMAGE_TAG}"
DOCKERFILE_PATH="${PROJECT_PATH}/${DOCKERFILE}"

echo "Building Docker image: $TAG from $DOCKERFILE_PATH..."

if command -v psh &>/dev/null && psh --version &>/dev/null 2>&1; then
  # shellcheck disable=SC2086
  psh -log-file "$LOG" -fail-on-error -c "docker build --load -f ${DOCKERFILE_PATH} -t ${TAG} ${BUILD_ARGS_FLAGS} ${PROJECT_PATH}"
else
  # shellcheck disable=SC2086
  docker build --load -f "$DOCKERFILE_PATH" -t "$TAG" $BUILD_ARGS_FLAGS "$PROJECT_PATH"
fi

echo "BUILT_IMAGE=$TAG" >> "${GITHUB_ENV:-/dev/null}"
echo "Image built successfully: $TAG"
