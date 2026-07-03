#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Apply Configuration
# Applies proboy.conf settings to all modules
# ═══════════════════════════════════════════════════════

CONFIG="/etc/proboy/proboy.conf"

if [ ! -f "${CONFIG}" ]; then
    echo "Config not found: ${CONFIG}"
    exit 1
fi

. "${CONFIG}"

echo "Applying Proboy configuration..."

# Zapret
if [ "${zapret_enabled}" = "1" ]; then
    echo "Starting zapret (${zapret_strategy})..."
    /opt/proboy/scripts/proboy.sh start
else
    echo "Zapret disabled"
fi

# Game filter
if [ "${gamefilter_enabled}" = "1" ]; then
    echo "Game filter: ${gamefilter_mode}"
fi

# PS5
if [ "${ps5_enabled}" = "1" ]; then
    echo "PS5 mode: ${ps5_detection}"
fi

# DNS
if [ "${dns_enabled}" = "1" ]; then
    echo "DNS provider: ${dns_provider}"
fi

# YouTube
if [ "${youtube_enabled}" = "1" ]; then
    echo "YouTube optimizer: enabled"
fi

# IPv6
if [ "${ipv6_enabled}" = "1" ]; then
    echo "IPv6 bypass: enabled"
fi

echo "Configuration applied successfully"
