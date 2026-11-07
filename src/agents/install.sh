#!/bin/sh
set -ex

PACKAGES=""

command -v curl >/dev/null 2>&1 || PACKAGES="$PACKAGES curl"
if [ "${CLAUDE}" = "true" ] || [ "${ANTIGRAVITY}" = "true" ] || \
   [ "${OPENCODE}" = "true" ] || [ "${MISTRAL}" = "true" ]; then
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
        'curl --compressed -fsSL https://antigravity.google/cli/install.sh | bash'
fi

if [ "${OPENCODE}" = "true" ]; then
    su - "$_REMOTE_USER" -c \
        'curl -fsSL https://opencode.ai/install | bash'
fi

if [ "${MISTRAL}" = "true" ]; then
    su - "$_REMOTE_USER" -c \
        'curl -fsSL https://mistral.ai/cli/install.sh | bash'
fi

BROWSER_VERSION="${BROWSER:-0.41.2}"
if [ "$BROWSER_VERSION" != "none" ] && [ "$BROWSER_VERSION" != "false" ]; then
    BROWSER_VERSION="${BROWSER_VERSION#v}"
    if ! printf '%s\n' "$BROWSER_VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "Invalid browser version: $BROWSER_VERSION (expected X.Y.Z or none)" >&2
        exit 1
    fi
    AGENT_BROWSER_VERSION="v${BROWSER_VERSION}"
    case "$(uname -m)" in
        x86_64) BROWSER_ARCH="x64" ;;
        aarch64|arm64) BROWSER_ARCH="arm64" ;;
        *) echo "Unsupported agent-browser architecture: $(uname -m)" >&2; exit 1 ;;
    esac
    BROWSER_PLATFORM="linux"
    if ls /lib/ld-musl-*.so.1 >/dev/null 2>&1; then
        BROWSER_PLATFORM="linux-musl"
    fi

    BROWSER_TMP=$(mktemp -d)
    trap 'rm -f "$BROWSER_TMP/agent-browser" "$BROWSER_TMP/SKILL.md"; rmdir "$BROWSER_TMP"' EXIT
    curl -fsSL --retry 3 \
        "https://github.com/vercel-labs/agent-browser/releases/download/${AGENT_BROWSER_VERSION}/agent-browser-${BROWSER_PLATFORM}-${BROWSER_ARCH}" \
        -o "$BROWSER_TMP/agent-browser"
    mkdir -p /usr/local/bin
    install -m 0755 "$BROWSER_TMP/agent-browser" /usr/local/bin/agent-browser

    curl -fsSL --retry 3 \
        "https://raw.githubusercontent.com/vercel-labs/agent-browser/${AGENT_BROWSER_VERSION}/skills/agent-browser/SKILL.md" \
        -o "$BROWSER_TMP/SKILL.md"

    install_browser_skill() {
        su - "$_REMOTE_USER" -c \
            "set -e; mkdir -p \"\$HOME/$1/agent-browser\"; cat > \"\$HOME/$1/agent-browser/SKILL.md\"" \
            < "$BROWSER_TMP/SKILL.md"
    }

    if [ "${CLAUDE}" = "true" ]; then
        install_browser_skill .claude/skills
    fi
    if [ "${CODEX}" = "true" ]; then
        install_browser_skill .agents/skills
    fi
    if [ "${ANTIGRAVITY}" = "true" ]; then
        install_browser_skill .gemini/config/skills
    fi
    if [ "${OPENCODE}" = "true" ]; then
        install_browser_skill .config/opencode/skills
    fi
    if [ "${MISTRAL}" = "true" ]; then
        install_browser_skill .vibe/skills
    fi
fi
