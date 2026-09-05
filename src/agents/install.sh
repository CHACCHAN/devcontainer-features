#!/bin/sh
set -e

PACKAGES=""

command -v curl >/dev/null 2>&1 || PACKAGES="$PACKAGES curl"

if [ "${CLAUDE}" = "true" ] || [ "${ANTIGRAVITY}" = "true" ]; then
    command -v bash >/dev/null 2>&1 || PACKAGES="$PACKAGES bash"
fi

if [ -n "$PACKAGES" ]; then
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y --no-install-recommends $PACKAGES
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache $PACKAGES
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y $PACKAGES
    elif command -v yum >/dev/null 2>&1; then
        yum install -y $PACKAGES
    else
        echo "Unsupported package manager"
        exit 1
    fi
fi

if [ "${CLAUDE}" = "true" ]; then
    su - "$_REMOTE_USER" -c \
        'curl -fsSL https://claude.ai/install.sh | bash'
fi

if [ "${CODEX}" = "true" ]; then
    su - "$_REMOTE_USER" -c \
        'curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_HOME="$HOME/.local/share/codex-cli" CODEX_NON_INTERACTIVE=1 sh'
fi

if [ "${ANTIGRAVITY}" = "true" ]; then
    su - "$_REMOTE_USER" -c \
        'curl -fsSL https://antigravity.google/cli/install.sh | bash'
fi
