#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${BACKSTAGE_APP_DIR:-/workspace/local-backstage}"
APP_NAME="${BACKSTAGE_APP_NAME:-local-backstage}"

mkdir -p "$APP_DIR"

if [[ ! -f "$APP_DIR/package.json" ]]; then
  echo "Bootstrapping Backstage app into $APP_DIR"

  # Use the official create-app flow in a non-interactive way for the local stack.
  BACKSTAGE_APP_NAME="$APP_NAME" npx @backstage/create-app@latest \
    --path "$APP_DIR" \
    --skip-install
fi

cd "$APP_DIR"

if [[ ! -d node_modules ]]; then
  echo "Installing Backstage dependencies in $APP_DIR"
  yarn install
fi

exec yarn start
