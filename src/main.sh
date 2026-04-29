#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-${PIPERY_TEST_PROJECT_PATH:-.}}"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "Expected project path to exist: $PROJECT_PATH" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${GITHUB_ACTIONS:-}" != "true" ] || [ -n "${PIPERY_TEST_PROJECT_PATH:-}" ]; then
  export INPUT_LOG_FILE="$LOG"
  export INPUT_PROJECT_PATH="$PROJECT_PATH"

  if [ "${INPUT_SKIP_LINT:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-lint.sh"
  fi

  if [ "${INPUT_SKIP_SAST:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-sast.sh" || true
  fi

  if [ "${INPUT_SKIP_SCA:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-sca.sh" || true
  fi

  if [ "${INPUT_SKIP_BUILD:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-build.sh"
  fi

  if [ "${INPUT_SKIP_TEST:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-test.sh"
  fi

  if [ "${INPUT_SKIP_VERSIONING:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-version.sh" || true
  fi

  if [ "${INPUT_SKIP_PACKAGING:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-package.sh" || true
  fi

  if [ "${INPUT_SKIP_RELEASE:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-release.sh" || true
  fi

  if [ "${INPUT_SKIP_REINTEGRATION:-false}" != "true" ]; then
    "$SCRIPT_DIR/step-reintegrate.sh" || true
  fi
fi

CI_STATUS="${PIPERY_CI_STATUS:-success}"
printf '{"event":"build","status":"%s","project":"docker","mode":"ci"}\n' "$CI_STATUS" >> "${INPUT_LOG_FILE:-pipery.jsonl}"
