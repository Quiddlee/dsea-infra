#!/usr/bin/env bash
set -e

./scripts/bootstrap.sh
docker compose -f compose/docker-compose.yml up --build
