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
CHUNK_SIZE_TEXT="${CHUNK_SIZE_TEXT:-900}"
CHUNK_OVERLAP_TEXT="${CHUNK_OVERLAP_TEXT:-150}"
CHUNK_SIZE_PDF="${CHUNK_SIZE_PDF:-650}"
CHUNK_OVERLAP_PDF="${CHUNK_OVERLAP_PDF:-120}"
CHUNK_SIZE_IMAGE="${CHUNK_SIZE_IMAGE:-450}"
CHUNK_OVERLAP_IMAGE="${CHUNK_OVERLAP_IMAGE:-80}"
ENCODING_TOKENIZER="${ENCODING_TOKENIZER:-cl100k_base}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-data/artifacts}"
PARSING_ARTIFACTS_DIR="${PARSING_ARTIFACTS_DIR:-parsing/artifacts}"
EMBEDDING_MODEL="${EMBEDDING_MODEL:-text-embedding-3-small}"
EMBEDDING_DIMENSIONS="${EMBEDDING_DIMENSIONS:-1536}"

# 4. Required vars
: "${POSTGRES_DB:?Missing POSTGRES_DB in .env}"
: "${POSTGRES_USER:?Missing POSTGRES_USER in .env}"
: "${POSTGRES_PASSWORD:?Missing POSTGRES_PASSWORD in .env}"
: "${POSTGRES_PORT:?Missing POSTGRES_PORT in .env}"
: "${OPENAI_API_KEY:?Missing OPENAI_API_KEY in .env}"
: "${TELEGRAM_BOT_TOKEN:?Missing TELEGRAM_BOT_TOKEN in .env}"

if [[ -z "${INTERNAL_SHARED_SECRET:-}" ]]; then
  echo "❌ INTERNAL_SHARED_SECRET is not set."
  echo "👉 Generate one with: openssl rand -hex 32"
  exit 1
fi

# 5. Generate docker env files
AI_CORE_ENV="$ROOT_DIR/services/ai-core/.env.docker"
TG_ENV="$ROOT_DIR/services/telegram-interface/.env.docker"

echo "• Generating $AI_CORE_ENV"
cat > "$AI_CORE_ENV" <<EOF
PORT=${AI_CORE_PORT}
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:${POSTGRES_PORT}/${POSTGRES_DB}
OPENAI_API_KEY=${OPENAI_API_KEY}
AI_CORE_INTERNAL_TOKEN=${INTERNAL_SHARED_SECRET}
CHUNK_SIZE_TEXT=${CHUNK_SIZE_TEXT}
CHUNK_OVERLAP_TEXT=${CHUNK_OVERLAP_TEXT}
CHUNK_SIZE_PDF=${CHUNK_SIZE_PDF}
CHUNK_OVERLAP_PDF=${CHUNK_OVERLAP_PDF}
CHUNK_SIZE_IMAGE=${CHUNK_SIZE_IMAGE}
CHUNK_OVERLAP_IMAGE=${CHUNK_OVERLAP_IMAGE}
ENCODING_TOKENIZER=${ENCODING_TOKENIZER}
ARTIFACTS_DIR=${ARTIFACTS_DIR}
EMBEDDING_MODEL=${EMBEDDING_MODEL}
EMBEDDING_DIMENSIONS=${EMBEDDING_DIMENSIONS}
EOF

echo "• Generating $TG_ENV"
cat > "$TG_ENV" <<EOF
DB_NAME=${POSTGRES_DB}
DB_USER=${POSTGRES_USER}
DB_PASSWORD=${POSTGRES_PASSWORD}
DB_HOST=postgres
DB_PORT=5432

AI_CORE_URL=http://ai-core:${AI_CORE_PORT}
AI_CORE_INTERNAL_TOKEN=${INTERNAL_SHARED_SECRET}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
ARTIFACTS_DIR=${PARSING_ARTIFACTS_DIR}
EOF

echo "✅ Bootstrap completed"
