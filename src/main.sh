#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-${PIPERY_TEST_PROJECT_PATH:-.}}"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "Expected project path to exist: $PROJECT_PATH" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run each CI step that hasn't been skipped already.
# In GitHub Actions, individual steps run via action.yml.
# When invoked directly (e.g., in tests), main.sh orchestrates everything.

if [ "${GITHUB_ACTIONS:-}" != "true" ]; then
  # Direct test execution: run all non-skipped steps

  export INPUT_LOG_FILE="$LOG"
  export INPUT_PROJECT_PATH="$PROJECT_PATH"

  if [ "${INPUT_SKIP_LINT:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-lint.sh" || true
  fi

  if [ "${INPUT_SKIP_SAST:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-sast.sh" || true
  fi

  if [ "${INPUT_SKIP_SCA:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-sca.sh" || true
  fi

  if [ "${INPUT_SKIP_BUILD:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-build.sh" || true
  fi

  if [ "${INPUT_SKIP_TEST:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-test.sh" || true
  fi

  if [ "${INPUT_SKIP_VERSIONING:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-version.sh" || true
  fi

  if [ "${INPUT_SKIP_PACKAGING:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-package.sh" || true
  fi

  if [ "${INPUT_SKIP_RELEASE:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-release.sh" || true
  fi

  if [ "${INPUT_SKIP_REINTEGRATION:-false}" != "true" ]; then
    bash "$SCRIPT_DIR/step-reintegrate.sh" || true
  fi
fi

printf '{"event":"build","status":"success","project":"docker","mode":"ci"}\n' >> "${INPUT_LOG_FILE:-pipery.jsonl}"
