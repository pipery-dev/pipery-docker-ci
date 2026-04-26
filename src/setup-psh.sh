#!/usr/bin/env bash
set -euo pipefail

if command -v psh &>/dev/null; then
  echo "psh already installed: $(psh --version 2>/dev/null || echo ok)"
  exit 0
fi

echo "Installing psh..."
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
curl -fsSL "https://github.com/pipery-dev/pipery/releases/download/v0.1.0/psh-0.1.0-linux-${ARCH}.tar.gz" \
  -o /tmp/psh.tar.gz
mkdir -p /tmp/psh-bin
tar -xzf /tmp/psh.tar.gz -C /tmp/psh-bin/
find /tmp/psh-bin -name psh -type f -exec sudo install -m755 {} /usr/local/bin/psh \;
echo "psh installed successfully."
