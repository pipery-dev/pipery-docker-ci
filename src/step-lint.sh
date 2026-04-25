#!/usr/bin/env bash
set -euo pipefail

LOG="${INPUT_LOG_FILE:-pipery.jsonl}"
PROJECT_PATH="${INPUT_PROJECT_PATH:-.}"
DOCKERFILE="${INPUT_DOCKERFILE:-Dockerfile}"

# Install hadolint if not present
if ! command -v hadolint &>/dev/null; then
  echo "hadolint not found, attempting to install..."
  # Pick the right binary for the current platform
  OS="$(uname -s)"
  ARCH="$(uname -m)"
  if [ "$OS" = "Linux" ] && [ "$ARCH" = "x86_64" ]; then
    HADOLINT_URL="https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64"
  elif [ "$OS" = "Linux" ] && [ "$ARCH" = "aarch64" ]; then
    HADOLINT_URL="https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-arm64"
  elif [ "$OS" = "Darwin" ]; then
    HADOLINT_URL="https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Darwin-x86_64"
  else
    echo "Unsupported platform $OS/$ARCH, skipping hadolint install."
    HADOLINT_URL=""
  fi

  if [ -n "$HADOLINT_URL" ] && curl -fsSL "$HADOLINT_URL" -o /tmp/hadolint 2>/dev/null; then
    INSTALL_DIR="/usr/local/bin"
    install -m755 /tmp/hadolint "$INSTALL_DIR/hadolint" 2>/dev/null || {
      mkdir -p "$HOME/.local/bin"
      install -m755 /tmp/hadolint "$HOME/.local/bin/hadolint"
      export PATH="$HOME/.local/bin:$PATH"
    }
    echo "hadolint installed successfully."
  else
    echo "Could not install hadolint, skipping lint step gracefully."
    exit 0
  fi
fi

# Verify hadolint is actually runnable (not a wrong-arch binary)
if ! hadolint --version &>/dev/null 2>&1; then
  echo "hadolint is not executable on this platform, skipping lint step gracefully."
  exit 0
fi

DOCKERFILE_PATH="${PROJECT_PATH}/${DOCKERFILE}"
if [ ! -f "$DOCKERFILE_PATH" ]; then
  echo "Dockerfile not found at $DOCKERFILE_PATH, skipping lint."
  exit 0
fi

echo "Running hadolint on $DOCKERFILE_PATH..."

# Build config flag: use .hadolint.yaml from the project directory if present
HADOLINT_CONFIG_FLAG=""
PROJECT_HADOLINT="${PROJECT_PATH}/.hadolint.yaml"
if [ -f "$PROJECT_HADOLINT" ]; then
  HADOLINT_CONFIG_FLAG="--config ${PROJECT_HADOLINT}"
fi

if command -v psh &>/dev/null && psh --version &>/dev/null 2>&1; then
  # shellcheck disable=SC2086
  psh -log-file "$LOG" -fail-on-error -c "hadolint ${HADOLINT_CONFIG_FLAG} ${DOCKERFILE_PATH}"
else
  # shellcheck disable=SC2086
  hadolint $HADOLINT_CONFIG_FLAG "$DOCKERFILE_PATH"
fi

echo "Lint passed."
