#!/bin/bash
# Rebuild gitbrain CLI and update symlink

set -e

cd "$(dirname "$0")"

echo "Building gitbrain..."
swift build

echo ""
echo "✓ Build complete!"
echo "Binary: $(pwd)/.build/debug/gitbrain"
echo "Symlink: /usr/local/bin/gitbrain -> $(pwd)/.build/debug/gitbrain"
