#!/bin/bash
set -euo pipefail

CONFIG_DIR="$HOME/.zeroclaw"
CONFIG_FILE="$CONFIG_DIR/config.toml"
WORKSPACE_DIR="$CONFIG_DIR/workspace"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[zeroclaw] Generating config from environment..."

    : "${TELEGRAM_BOT_TOKEN:?TELEGRAM_BOT_TOKEN is required — get one from @BotFather on Telegram}"
    : "${TELEGRAM_USER_ID:?TELEGRAM_USER_ID is required — get yours from @userinfobot on Telegram}"

    PROVIDER="${LLM_PROVIDER:-openai}"
    MODEL="${LLM_MODEL:-gpt-4o}"

    sed \
        -e "s|__TELEGRAM_BOT_TOKEN__|${TELEGRAM_BOT_TOKEN}|g" \
        -e "s|__TELEGRAM_USER_ID__|${TELEGRAM_USER_ID}|g" \
        -e "s|__LLM_PROVIDER__|${PROVIDER}|g" \
        -e "s|__LLM_MODEL__|${MODEL}|g" \
        "$HOME/config.template.toml" > "$CONFIG_FILE"

    chmod 600 "$CONFIG_FILE"
    echo "[zeroclaw] Config ready (provider=${PROVIDER}, model=${MODEL})"
else
    echo "[zeroclaw] Using existing config.toml"
fi

if [ -z "$(ls -A "$WORKSPACE_DIR" 2>/dev/null)" ]; then
    echo "[zeroclaw] Initializing workspace with defaults..."
    cp "$HOME/workspace-defaults/"* "$WORKSPACE_DIR/"
fi

# Start virtual framebuffer for headless browser automation
Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp &
export DISPLAY=:99

echo "[zeroclaw] Starting daemon..."
exec zeroclaw daemon
