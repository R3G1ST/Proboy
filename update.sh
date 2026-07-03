#!/bin/sh
# Proboy Updater — Safe in-place update
# Proboy x FreeLink — Internet Freedom for People

set -e

VER="1.0.0"
REPO="https://raw.githubusercontent.com/R3G1ST/Proboy/main"
DIR="/opt/proboy"
CFG="/etc/proboy"
BACKUP="/tmp/proboy-backup-$$"

# Colors
RED=$(printf '\033[0;31m')
GRN=$(printf '\033[0;32m')
YEL=$(printf '\033[1;33m')
BLU=$(printf '\033[0;34m')
CYN=$(printf '\033[0;36m')
NC=$(printf '\033[0m')
B=$(printf '\033[1m')

ok()   { printf "${GRN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YEL}[!!]${NC} %s\n" "$1"; }
err()  { printf "${RED}[XX]${NC} %s\n" "$1"; }
step() { printf "${BLU}[>>]${NC} %s\n" "$1"; }

dl() {
    if command -v curl >/dev/null 2>&1; then
        curl -sL "$1" -o "$2" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$1" -O "$2" 2>/dev/null
    fi
}

show_banner() {
    printf "\n"
    printf "%s\n" "  ============================================"
    printf "${CYN}%s${NC}\n" "  P R O B O Y   U P D A T E R"
    printf "%s\n" "  ============================================"
    printf "\n"
}

# Check if Proboy is installed
check_installed() {
    if [ ! -d "${DIR}" ]; then
        err "Proboy is not installed"
        err "Run install.sh first"
        exit 1
    fi

    if [ ! -f "${DIR}/VERSION" ]; then
        warn "Cannot determine current version"
        CURRENT_VER="unknown"
    else
        CURRENT_VER="$(cat "${DIR}/VERSION" 2>/dev/null)"
    fi
}

# Get latest version from GitHub
check_latest() {
    step "Checking latest version..."

    LATEST_VER=$(dl "${REPO}/VERSION" /dev/stdout 2>/dev/null || true)

    if [ -z "${LATEST_VER}" ]; then
        # Try GitHub API
        LATEST_VER=$(curl -sL "https://api.github.com/repos/R3G1ST/Proboy/contents/VERSION" 2>/dev/null | \
            grep '"content"' | head -1 | sed 's/.*"content": *"//;s/".*//' | base64 -d 2>/dev/null || true)
    fi

    if [ -z "${LATEST_VER}" ]; then
        warn "Cannot check latest version — will update anyway"
        LATEST_VER="unknown"
    fi

    ok "Current: ${CURRENT_VER}"
    ok "Latest:  ${LATEST_VER}"
}

# Backup user config
backup_config() {
    step "Backing up configuration..."
    mkdir -p "${BACKUP}"

    # Save user config
    if [ -f "${CFG}/proboy.conf" ]; then
        cp "${CFG}/proboy.conf" "${BACKUP}/proboy.conf"
        ok "Config backed up"
    fi

    # Save custom lists
    for f in lists/*.txt; do
        [ -f "${DIR}/${f}" ] && cp "${DIR}/${f}" "${BACKUP}/" 2>/dev/null || true
    done

    # Save custom strategies
    for f in strategies/*.sh; do
        [ -f "${DIR}/${f}" ] && cp "${DIR}/${f}" "${BACKUP}/" 2>/dev/null || true
    done

    ok "Backup at ${BACKUP}"
}

# Stop services before update
stop_services() {
    step "Stopping services..."

    if [ -f /etc/init.d/proboy ]; then
        /etc/init.d/proboy stop 2>/dev/null || true
    fi
    if command -v systemctl >/dev/null 2>&1; then
        systemctl stop proboy 2>/dev/null || true
    fi

    # Stop web server
    if [ -x "${DIR}/scripts/webserver.sh" ]; then
        "${DIR}/scripts/webserver.sh" stop 2>/dev/null || true
    fi

    # Kill running processes
    pkill -f "proboy.sh" 2>/dev/null || true
    pkill -f "nfqws" 2>/dev/null || true
    pkill -f "sing-box" 2>/dev/null || true

    sleep 1
    ok "Services stopped"
}

# Update project files (scripts, web, modules, strategies, lists, etc.)
update_files() {
    step "Updating project files..."
    TOTAL=64
    CNT=0
    FAIL=0

    for f in \
        scripts/proboy.sh scripts/webserver.sh scripts/detect_system.sh scripts/apply_config.sh \
        web/cgi-bin/proboy-api \
        modules/zapret/zapret_manager.py modules/gamefilter/gamefilter.py \
        modules/ps5/ps5_manager.py modules/network/network_analyzer.py \
        modules/dns/dns_manager.py modules/youtube/youtube_manager.py \
        modules/ipv6/ipv6_manager.py modules/subscriptions/sub_manager.py \
        modules/failover/failover.py modules/combo/combo_builder.py \
        web/index.html web/css/proboy.css web/js/app.js web/js/api.js \
        web/js/combo.js web/js/authors.js web/js/i18n.js \
        web/modules/zapret.html web/modules/games.html web/modules/network.html \
        web/modules/combo.html web/modules/authors.html web/modules/subscriptions.html \
        web/modules/settings.html \
        strategies/general.sh strategies/general-alt.sh strategies/fake-tls-auto.sh \
        strategies/fake-tls-auto-alt.sh strategies/discord.sh strategies/youtube.sh \
        strategies/telegram.sh strategies/gaming.sh strategies/fortnite.sh \
        strategies/cs2.sh strategies/psn.sh strategies/steam.sh strategies/epic.sh \
        strategies/aggressive.sh strategies/auto.sh \
        lists/domains.txt lists/ips.txt lists/game-domains.txt lists/psn-domains.txt \
        lists/youtube-domains.txt lists/telegram-domains.txt lists/discord-domains.txt \
        game-servers/steam.json game-servers/epic.json game-servers/riot.json \
        game-servers/blizzard.json game-servers/ea.json game-servers/sony.json \
        game-servers/microsoft.json game-servers/nintendo.json \
        nftables/nftables-game.nft nftables/ps5-nftables.nft nftables/dns-bypass.nft \
        nftables/youtube-nftables.nft nftables/ipv6-nftables.nft \
        presets.json uninstall.sh VERSION
    do
        CNT=$((CNT+1))
        PCT=$((CNT * 100 / TOTAL))
        printf "\r  [%3d%%] %s" "${PCT}" "$(basename "$f")"
        mkdir -p "$(dirname "${DIR}/${f}")"
        dl "${REPO}/${f}" "${DIR}/${f}" 2>/dev/null
        [ ! -f "${DIR}/${f}" ] && FAIL=$((FAIL+1))
    done
    echo ""

    if [ "${FAIL}" -gt 0 ]; then
        warn "${FAIL} files failed to download"
    else
        ok "All files updated"
    fi
}

# Update binaries (zapret, hysteria2, sing-box)
update_binaries() {
    step "Updating binaries..."

    ARCH="$(uname -m)"

    # Update zapret
    if [ ! -f "${DIR}/bin/nfqws" ]; then
        step "  Downloading zapret..."
        dl "https://github.com/bol-van/zapret/releases/download/v72.12/zapret-v72.12.tar.gz" /tmp/zapret.tar.gz
        if [ -f /tmp/zapret.tar.gz ]; then
            tar -xzf /tmp/zapret.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/zapret*/nfqws "${DIR}/bin/" 2>/dev/null || true
            cp /tmp/zapret*/tpws "${DIR}/bin/" 2>/dev/null || true
            chmod +x "${DIR}/bin/nfqws" "${DIR}/bin/tpws" 2>/dev/null || true
            rm -rf /tmp/zapret*
            ok "  zapret updated"
        fi
    else
        ok "  zapret present"
    fi

    # Update hysteria2
    if [ ! -f "${DIR}/bin/hysteria2" ]; then
        case "${ARCH}" in
            x86_64)  HA="amd64" ;;
            aarch64) HA="arm64" ;;
            armv7l)  HA="armv7" ;;
            armv6l)  HA="armv6" ;;
            *)       HA="amd64" ;;
        esac
        step "  Downloading Hysteria2..."
        dl "https://github.com/apernet/hysteria/releases/download/app%2Fv2.9.3/hysteria-linux-${HA}" "${DIR}/bin/hysteria2"
        chmod +x "${DIR}/bin/hysteria2" 2>/dev/null || true
        ok "  Hysteria2 updated"
    else
        ok "  Hysteria2 present"
    fi

    # Update sing-box
    if [ ! -f "${DIR}/bin/sing-box" ]; then
        case "${ARCH}" in
            x86_64)  SA="amd64" ;;
            aarch64) SA="arm64" ;;
            armv7l)  SA="armv7" ;;
            armv6l)  SA="armv6" ;;
            *)       SA="amd64" ;;
        esac
        step "  Downloading sing-box..."
        dl "https://github.com/SagerNet/sing-box/releases/download/v1.11.4/sing-box-1.11.4-linux-${SA}.tar.gz" /tmp/sb.tar.gz
        if [ -f /tmp/sb.tar.gz ]; then
            tar -xzf /tmp/sb.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/sing-box-*/sing-box "${DIR}/bin/" 2>/dev/null || true
            chmod +x "${DIR}/bin/sing-box" 2>/dev/null || true
            rm -rf /tmp/sing-box-* /tmp/sb.tar.gz
            ok "  sing-box updated"
        fi
    else
        ok "  sing-box present"
    fi
}

# Restore user config
restore_config() {
    step "Restoring configuration..."

    if [ -f "${BACKUP}/proboy.conf" ]; then
        cp "${BACKUP}/proboy.conf" "${CFG}/proboy.conf"
        ok "Config restored"
    fi

    # Restore custom lists if they differ from defaults
    for f in "${BACKUP}"/*.txt; do
        [ -f "$f" ] && cp "$f" "${DIR}/lists/" 2>/dev/null || true
    done

    # Restore custom strategies
    for f in "${BACKUP}"/*.sh; do
        [ -f "$f" ] && cp "$f" "${DIR}/strategies/" 2>/dev/null || true
    done

    # Ensure CGI script is executable
    chmod +x "${DIR}/web/cgi-bin/proboy-api" 2>/dev/null || true
    chmod +x "${DIR}/scripts/"*.sh 2>/dev/null || true

    ok "Configuration restored"
}

# Start services after update
start_services() {
    step "Starting services..."

    if [ -x "${DIR}/scripts/proboy.sh" ]; then
        "${DIR}/scripts/proboy.sh" start
    fi

    ok "Services started"
}

# Cleanup
cleanup() {
    rm -rf "${BACKUP}" 2>/dev/null || true
}

# Show update summary
show_summary() {
    NEW_VER="$(cat "${DIR}/VERSION" 2>/dev/null || echo 'unknown')"

    echo ""
    echo "  ============================================"
    echo "  ${GRN}Update Complete!${NC}"
    echo "  ============================================"
    echo ""
    echo "  ${B}Previous:${NC} ${CURRENT_VER}"
    echo "  ${B}Current:${NC}  ${NEW_VER}"
    echo ""
    echo "  ${B}Web Panel:${NC} http://$(hostname -I 2>/dev/null | awk '{print $1}'):8080"
    echo ""
    echo "  ============================================"
    echo ""
}

# Main
main() {
    show_banner

    if [ "$(id -u)" -ne 0 ]; then
        err "Run as root"
        exit 1
    fi

    check_installed
    check_latest
    backup_config
    stop_services
    update_files
    update_binaries
    restore_config
    start_services
    cleanup
    show_summary
}

# Handle --check flag (just check, don't update)
if [ "$1" = "--check" ]; then
    show_banner
    check_installed
    check_latest
    exit 0
fi

# Handle --help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (none)     Update Proboy to latest version"
    echo "  --check    Check for updates without installing"
    echo "  --help     Show this help"
    echo ""
    exit 0
fi

main "$@"
