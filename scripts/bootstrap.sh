#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
ENV_EXAMPLE="$ROOT_DIR/.env.example"

echo "▶ Bootstrapping dsea stack"

# 1. Ensure .env exists
if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$ENV_EXAMPLE" ]]; then
    echo "• .env not found, copying from .env.example"
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo "  ⚠️  Please review $ENV_FILE and update secrets if needed"
  else
    echo "❌ Missing .env and .env.example"
    exit 1
  fi
fi

# 2. Load env
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# 3. Defaults (safe under set -u)
AI_CORE_PORT="${AI_CORE_PORT:-3000}"

# 4. Required vars
: "${POSTGRES_DB:?Missing POSTGRES_DB in .env}"
: "${POSTGRES_USER:?Missing POSTGRES_USER in .env}"
: "${POSTGRES_PASSWORD:?Missing POSTGRES_PASSWORD in .env}"

# 5. Generate docker env files
AI_CORE_ENV="$ROOT_DIR/services/ai-core/.env.docker"
TG_ENV="$ROOT_DIR/services/telegram-interface/.env.docker"

echo "• Generating $AI_CORE_ENV"
cat > "$AI_CORE_ENV" <<EOF
PORT=${AI_CORE_PORT}
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:${POSTGRES_PORT}/${POSTGRES_DB}
OPENAI_API_KEY=${OPENAI_API_KEY:?Missing OPENAI_API_KEY in .env}
EOF

echo "• Generating $TG_ENV"
cat > "$TG_ENV" <<EOF
AI_CORE_URL=http://ai-core:${AI_CORE_PORT}
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:${POSTGRES_PORT}/${POSTGRES_DB}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:?Missing TELEGRAM_BOT_TOKEN in .env}
EOF

echo "✅ Bootstrap completed"
