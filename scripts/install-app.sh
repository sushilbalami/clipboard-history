#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="Clipboard History"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"

./scripts/build-release-bundle.sh

echo "Installing to /Applications..."
rm -rf "/Applications/$APP_NAME.app"
cp -R "$APP_DIR" "/Applications/$APP_NAME.app"

echo
echo "Installed: /Applications/$APP_NAME.app"
echo "Run it from Applications. It will launch as a background menu bar app."
