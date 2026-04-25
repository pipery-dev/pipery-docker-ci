#!/usr/bin/env bash
set -euo pipefail
echo "Building artifact..."
echo "Hello from multi-stage build!" > /app/output
echo "Build complete."
