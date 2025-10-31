#!/usr/bin/env bash
set -euo pipefail

# Clean dist
rm -rf dist
mkdir -p dist

echo "Downloading latest NCE-Flow (main branch) zip..."
ZIP_URL="https://codeload.github.com/luzhenhua/NCE-Flow/zip/refs/heads/main"
curl -L "$ZIP_URL" -o /tmp/nce-flow.zip

echo "Unzipping..."
unzip -q /tmp/nce-flow.zip -d /tmp
# The folder will be /tmp/NCE-Flow-main
SRC_DIR="/tmp/NCE-Flow-main"

# Copy everything into dist
rsync -a "$SRC_DIR"/ dist/

# Remove CNAME if present (avoid sticking to original author's custom domain)
rm -f dist/CNAME

# Inject our headers and 404 (override if upstream adds their own later)
cp _headers dist/_headers
cp 404.html dist/404.html

echo "Build finished. dist/ is ready."
