#!/bin/sh
set -e

# Generate the locale configured in containerEnv before interactive shells use it.
export LANG=C
export LC_ALL=C

if ! command -v locale-gen >/dev/null 2>&1; then
    echo "locale-gen is required; ensure the locales dependency is installed" >&2
    exit 1
fi

if [ -f /etc/locale.gen ]; then
    sed -i '/^[#[:space:]]*ja_JP.UTF-8[[:space:]]/d' /etc/locale.gen
    printf '%s\n' 'ja_JP.UTF-8 UTF-8' >> /etc/locale.gen
fi
locale-gen ja_JP.UTF-8
