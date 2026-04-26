#!/usr/bin/env psh
set -euo pipefail

IMAGE_NAME="${INPUT_IMAGE_NAME:-test-image}"
IMAGE_TAG="${INPUT_IMAGE_TAG:-latest}"
TESTS_PATH="${INPUT_TESTS_PATH:-}"

TAG="${IMAGE_NAME}:${IMAGE_TAG}"

if [ -n "$TESTS_PATH" ]; then
  echo "Running test command in container $TAG: $TESTS_PATH"
  CMD="$TESTS_PATH"
else
  echo "Running container smoke test on $TAG..."
  CMD="echo 'Container smoke test OK'"
fi

docker run --rm "$TAG" sh -c "$CMD"

echo "Test passed."
