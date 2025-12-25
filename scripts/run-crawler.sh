#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

docker compose \
  --env-file "$ROOT_DIR/.env" \
  -f compose/docker-compose.yml \
  run --rm crawler
