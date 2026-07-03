#!/bin/sh
# ╔══════════════════════════════════════════════════════════════════════╗
# ║                                                                      ║
# ║   ██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗                         ║
# ║   ██╔══██╗██╔══██╗██╔═══██╗██║   ██║██╔══██╗                        ║
# ║   ██████╔╝██████╔╝██║   ██║██║   ██║██████╔╝                        ║
# ║   ██╔═══╝ ██╔══██╗██║   ██║██║   ██║██╔═══╝                         ║
# ║   ██║     ██║  ██║╚██████╔╝╚██████╔╝██║                             ║
# ║   ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝                             ║
# ║                                                                      ║
# ║   Proboy x FreeLink — Internet Freedom for People                    ║
# ║   Anti-censorship suite for OpenWrt                                  ║
# ║   DPI bypass | Gaming | PS5 | Subscriptions                         ║
# ║                                                                      ║
# ╚══════════════════════════════════════════════════════════════════════╝

set -e

# ─── Version ──────────────────────────────────────────────
PROBOY_VERSION="1.0.0"
PROBOY_CODENAME="Phoenix"
PROBOY_STATUS="ALPHA"
GITHUB_RAW="https://raw.githubusercontent.com/R3G1ST/Proboy/main"

# ─── Install paths ────────────────────────────────────────
INSTALL_DIR="/opt/proboy"
CONFIG_DIR="/etc/proboy"
LOG_DIR="/var/log/proboy"

# ─── Colors ───────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# ─── Helpers ──────────────────────────────────────────────
info()    { printf "${GREEN}[✓]${NC} %s\n" "$1"; }
warn()    { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
error()   { printf "${RED}[✗]${NC} %s\n" "$1"; }
step()    { printf "${BLUE}[→]${NC} %s\n" "$1"; }
progress() { printf "${CYAN}[...]${NC} %s" "$1"; }
done_msg() { printf "\r${GREEN}[✓]${NC} %s\n" "$1"; }
banner()  { printf "${CYAN}$1${NC}\n"; }

# ─── Download with progress ───────────────────────────────
dl() {
    local url="$1"
    local dest="$2"
    local name="$3"
    mkdir -p "$(dirname "$dest")"

    if command -v curl >/dev/null 2>&1; then
        curl -# -L "${url}" -o "${dest}" 2>&1 | while IFS= read -r line; do
            printf "\r${CYAN}[...]${NC} %s %s" "${name}" "${line}"
        done
        echo ""
    elif command -v wget >/dev/null 2>&1; then
        wget --show-progress -q "${url}" -O "${dest}" 2>&1
    fi
}

# ─── Banner ───────────────────────────────────────────────
show_banner() {
    echo ""
    banner "  ╔═══════════════════════════════════════════════════════════╗"
    banner "  ║                                                           ║"
    banner "  ║   ${BOLD}${CYAN}██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗              ${NC}${CYAN}║${NC}"
    banner "  ║   ${BOLD}${CYAN}██╔══██╗██╔══██╗██╔═══██╗██║   ██║██╔══██╗             ${NC}${CYAN}║${NC}"
    banner "  ║   ${BOLD}${CYAN}██████╔╝██████╔╝██║   ██║██║   ██║██████╔╝             ${NC}${CYAN}║${NC}"
    banner "  ║   ${BOLD}${CYAN}██╔═══╝ ██╔══██╗██║   ██║██║   ██║██╔═══╝              ${NC}${CYAN}║${NC}"
    banner "  ║   ${BOLD}${CYAN}██║     ██║  ██║╚██████╔╝╚██████╔╝██║                  ${NC}${CYAN}║${NC}"
    banner "  ║   ${BOLD}${CYAN}╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝                  ${NC}${CYAN}║${NC}"
    banner "  ║                                                           ║"
    banner "  ║   ${GREEN}Proboy x FreeLink — Internet Freedom for People${NC}         ${CYAN}║${NC}"
    banner "  ║   ${YELLOW}Anti-censorship suite for OpenWrt${NC}                       ${CYAN}║${NC}"
    banner "  ║   ${MAGENTA}DPI bypass | Gaming | PS5 | Subscriptions${NC}              ${CYAN}║${NC}"
    banner "  ║                                                           ║"
    banner "  ╚═══════════════════════════════════════════════════════════╝"
    echo ""
    printf "  ${BOLD}Version:${NC}    ${CYAN}%s${NC}\n" "${PROBOY_VERSION}"
    printf "  ${BOLD}Codename:${NC}   ${MAGENTA}%s${NC}\n" "${PROBOY_CODENAME}"
    printf "  ${BOLD}Status:${NC}     ${YELLOW}%s${NC}\n" "${PROBOY_STATUS}"
    printf "  ${BOLD}GitHub:${NC}     ${CYAN}github.com/R3G1ST/Proboy${NC}\n"
    echo ""
}

# ─── System Detection ─────────────────────────────────────
detect_system() {
    step "Detecting system..."

    if [ -f /etc/openwrt_release ]; then
        . /etc/openwrt_release
        OS="openwrt"
        OS_VERSION="${DISTRIB_RELEASE}"
        OS_TARGET="${DISTRIB_TARGET}"
        OS_ARCH="${DISTRIB_ARCH}"
        info "OpenWrt ${OS_VERSION} (${OS_TARGET})"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="${ID:-linux}"
        OS_VERSION="${VERSION_ID}"
        OS_ARCH="$(uname -m)"
        info "${PRETTY_NAME:-Linux ${OS_VERSION}}"
    else
        OS="linux"
        OS_VERSION="$(uname -r)"
        OS_ARCH="$(uname -m)"
        info "Linux ${OS_VERSION}"
    fi

    ROUTER_MODEL=""
    [ -f /tmp/sysinfo/model ] && ROUTER_MODEL="$(cat /tmp/sysinfo/model 2>/dev/null)"
    [ -z "${ROUTER_MODEL}" ] && [ -f /proc/device-tree/model ] && ROUTER_MODEL="$(cat /proc/device-tree/model 2>/dev/null | tr '\0' ' ')"
    [ -z "${ROUTER_MODEL}" ] && [ -f /sys/class/dmi/id/product_name ] && ROUTER_MODEL="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"

    BOARD=""
    [ -f /tmp/sysinfo/board_name ] && BOARD="$(cat /tmp/sysinfo/board_name 2>/dev/null)"

    BRAND="Unknown"
    case "${ROUTER_MODEL}" in
        *Xiaomi*|*Mi*|*Redmi*) BRAND="Xiaomi" ;;
        *TP-Link*|*TPINK*)     BRAND="TP-Link" ;;
        *Netgear*)             BRAND="Netgear" ;;
        *ASUS*|*Asus*)         BRAND="ASUS" ;;
        *Keenetic*)            BRAND="Keenetic" ;;
        *GL.iNet*)             BRAND="GL.iNet" ;;
        *Zyxel*)               BRAND="Zyxel" ;;
        *Linksys*)             BRAND="Linksys" ;;
        *Ubiquiti*)            BRAND="Ubiquiti" ;;
        *MikroTik*)            BRAND="MikroTik" ;;
        *D-Link*)              BRAND="D-Link" ;;
        *Huawei*)              BRAND="Huawei" ;;
        *Tenda*)               BRAND="Tenda" ;;
    esac

    # If brand still unknown, try board name
    if [ "${BRAND}" = "Unknown" ] && [ -n "${BOARD}" ]; then
        case "${BOARD}" in
            *redmi*|*xiaomi*|*mi-*)  BRAND="Xiaomi" ;;
            *tp-link*|*tplink*)       BRAND="TP-Link" ;;
            *netgear*)                BRAND="Netgear" ;;
            *asus*)                   BRAND="ASUS" ;;
            *keenetic*)               BRAND="Keenetic" ;;
            *gl-*)                    BRAND="GL.iNet" ;;
            *dlink*|*d-link*)         BRAND="D-Link" ;;
        esac
    fi

    [ -n "${ROUTER_MODEL}" ] && info "Router: ${BRAND} ${ROUTER_MODEL}"
    [ -n "${BOARD}" ] && [ "${BOARD}" != "${ROUTER_MODEL}" ] && info "Board: ${BOARD}"

    CPU="$(cat /proc/cpuinfo 2>/dev/null | grep -m1 'model name' | cut -d: -f2 | xargs)"
    CORES="$(nproc 2>/dev/null || echo 1)"
    [ -n "${CPU}" ] && info "CPU: ${CPU} (${CORES} cores)"

    RAM="$(free -m 2>/dev/null | awk '/Mem:/{print $2}' || echo 0)
    [ "${RAM}" -gt 0 ] && info "RAM: ${RAM} MB"

    FLASH_TOTAL="$(df -m / 2>/dev/null | tail -1 | awk '{print $2}' || echo 0)"
    FLASH_FREE="$(df -m / 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)"
    [ "${FLASH_TOTAL}" -gt 0 ] && info "Flash: ${FLASH_TOTAL} MB total, ${FLASH_FREE} MB free"

    if command -v apk >/dev/null 2>&1; then
        PKG_MGR="apk"
        PKG_INSTALL="apk add --no-cache"
        info "Package manager: APK"
    elif command -v opkg >/dev/null 2>&1; then
        PKG_MGR="opkg"
        PKG_INSTALL="opkg install"
        info "Package manager: opkg"
    elif command -v apt-get >/dev/null 2>&1; then
        PKG_MGR="apt"
        PKG_INSTALL="apt-get install -y"
        info "Package manager: apt"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MGR="yum"
        PKG_INSTALL="yum install -y"
        info "Package manager: yum"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MGR="dnf"
        PKG_INSTALL="dnf install -y"
        info "Package manager: dnf"
    else
        PKG_MGR="none"
        warn "No package manager found"
    fi
}

# ─── Dependencies ─────────────────────────────────────────
install_deps() {
    step "Installing dependencies..."
    NEED=""
    for cmd in curl wget tar gzip ip; do
        command -v "$cmd" >/dev/null 2>&1 || NEED="${NEED} ${cmd}"
    done
    command -v nft >/dev/null 2>&1 || command -v iptables >/dev/null 2>&1 || NEED="${NEED} nftables"

    if [ -n "${NEED}" ]; then
        warn "Missing:${NEED}"
        case "${PKG_MGR}" in
            apk)  ${PKG_INSTALL} curl wget tar gzip ip-full nftables 2>/dev/null || true ;;
            opkg) ${PKG_INSTALL} curl wget tar gzip ip-full nftables iptables 2>/dev/null || true ;;
            apt)  ${PKG_INSTALL} curl wget tar gzip iproute2 nftables 2>/dev/null || true ;;
            yum|dnf) ${PKG_INSTALL} curl wget tar gzip iproute nftables 2>/dev/null || true ;;
        esac
    fi
    info "Dependencies ready"
}

# ─── Install binaries ────────────────────────────────────
install_binaries() {
    step "Installing binaries..."
    ARCH="$(uname -m)"
    TOTAL=3
    CURRENT=0

    # zapret
    CURRENT=$((CURRENT+1))
    if [ ! -f "${INSTALL_DIR}/bin/nfqws" ]; then
        progress "[$CURRENT/$TOTAL] Downloading zapret..."
        ZAPRET_VER="v72.12"
        dl "https://github.com/bol-van/zapret/releases/download/${ZAPRET_VER}/zapret-${ZAPRET_VER}.tar.gz" /tmp/zapret.tar.gz "zapret"
        if [ -f /tmp/zapret.tar.gz ]; then
            tar -xzf /tmp/zapret.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/zapret*/nfqws "${INSTALL_DIR}/bin/" 2>/dev/null || true
            cp /tmp/zapret*/tpws "${INSTALL_DIR}/bin/" 2>/dev/null || true
            chmod +x "${INSTALL_DIR}/bin/nfqws" "${INSTALL_DIR}/bin/tpws" 2>/dev/null || true
            rm -rf /tmp/zapret* /tmp/zapret.tar.gz
            done_msg "zapret installed"
        else
            warn "Failed to download zapret"
        fi
    else
        info "zapret already installed"
    fi

    # Hysteria2
    CURRENT=$((CURRENT+1))
    if [ ! -f "${INSTALL_DIR}/bin/hysteria2" ]; then
        progress "[$CURRENT/$TOTAL] Downloading Hysteria2..."
        case "${ARCH}" in
            x86_64)  H2_ARCH="amd64" ;;
            aarch64) H2_ARCH="arm64" ;;
            armv7l)  H2_ARCH="armv7" ;;
            armv6l)  H2_ARCH="armv6" ;;
            mipsel)  H2_ARCH="mips-softfloat" ;;
            *)       H2_ARCH="amd64" ;;
        esac
        dl "https://github.com/apernet/hysteria/releases/download/app%2Fv2.9.3/hysteria-linux-${H2_ARCH}" "${INSTALL_DIR}/bin/hysteria2" "Hysteria2"
        chmod +x "${INSTALL_DIR}/bin/hysteria2" 2>/dev/null || true
        done_msg "Hysteria2 installed"
    else
        info "Hysteria2 already installed"
    fi

    # sing-box
    CURRENT=$((CURRENT+1))
    if [ ! -f "${INSTALL_DIR}/bin/sing-box" ]; then
        progress "[$CURRENT/$TOTAL] Downloading sing-box..."
        case "${ARCH}" in
            x86_64)  SB_ARCH="amd64" ;;
            aarch64) SB_ARCH="arm64" ;;
            armv7l)  SB_ARCH="armv7" ;;
            armv6l)  SB_ARCH="armv6" ;;
            mipsel)  SB_ARCH="mips" ;;
            *)       SB_ARCH="amd64" ;;
        esac
        dl "https://github.com/SagerNet/sing-box/releases/download/v1.11.4/sing-box-1.11.4-linux-${SB_ARCH}.tar.gz" /tmp/singbox.tar.gz "sing-box"
        if [ -f /tmp/singbox.tar.gz ]; then
            tar -xzf /tmp/singbox.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/sing-box-*/sing-box "${INSTALL_DIR}/bin/" 2>/dev/null || true
            chmod +x "${INSTALL_DIR}/bin/sing-box" 2>/dev/null || true
            rm -rf /tmp/sing-box-* /tmp/singbox.tar.gz
            done_msg "sing-box installed"
        fi
    else
        info "sing-box already installed"
    fi
}

# ─── Download project files ──────────────────────────────
install_files() {
    step "Downloading project files..."

    FILES=(
        "scripts/proboy.sh"
        "scripts/detect_system.sh"
        "scripts/apply_config.sh"
        "modules/zapret/zapret_manager.py"
        "modules/gamefilter/gamefilter.py"
        "modules/ps5/ps5_manager.py"
        "modules/network/network_analyzer.py"
        "modules/dns/dns_manager.py"
        "modules/youtube/youtube_manager.py"
        "modules/ipv6/ipv6_manager.py"
        "modules/subscriptions/sub_manager.py"
        "modules/failover/failover.py"
        "modules/combo/combo_builder.py"
        "web/index.html"
        "web/css/proboy.css"
        "web/js/app.js"
        "web/js/api.js"
        "web/js/combo.js"
        "web/js/authors.js"
        "web/js/i18n.js"
        "web/modules/zapret.html"
        "web/modules/games.html"
        "web/modules/network.html"
        "web/modules/combo.html"
        "web/modules/authors.html"
        "web/modules/subscriptions.html"
        "web/modules/settings.html"
        "strategies/general.sh"
        "strategies/general-alt.sh"
        "strategies/fake-tls-auto.sh"
        "strategies/fake-tls-auto-alt.sh"
        "strategies/discord.sh"
        "strategies/youtube.sh"
        "strategies/telegram.sh"
        "strategies/gaming.sh"
        "strategies/fortnite.sh"
        "strategies/cs2.sh"
        "strategies/psn.sh"
        "strategies/steam.sh"
        "strategies/epic.sh"
        "strategies/aggressive.sh"
        "strategies/auto.sh"
        "lists/domains.txt"
        "lists/ips.txt"
        "lists/game-domains.txt"
        "lists/psn-domains.txt"
        "lists/youtube-domains.txt"
        "lists/telegram-domains.txt"
        "lists/discord-domains.txt"
        "game-servers/steam.json"
        "game-servers/epic.json"
        "game-servers/riot.json"
        "game-servers/blizzard.json"
        "game-servers/ea.json"
        "game-servers/sony.json"
        "game-servers/microsoft.json"
        "game-servers/nintendo.json"
        "nftables/nftables-game.nft"
        "nftables/ps5-nftables.nft"
        "nftables/dns-bypass.nft"
        "nftables/youtube-nftables.nft"
        "nftables/ipv6-nftables.nft"
        "presets.json"
        "uninstall.sh"
    )

    TOTAL=${#FILES[@]}
    CURRENT=0
    FAILED=0

    for f in "${FILES[@]}"; do
        CURRENT=$((CURRENT+1))
        PROGRESS=$((CURRENT * 100 / TOTAL))
        printf "\r${CYAN}[...]${NC} [%3d%%] Downloading: %s" "${PROGRESS}" "$(basename "$f")"

        mkdir -p "$(dirname "${INSTALL_DIR}/${f}")"
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}" "" 2>/dev/null

        if [ ! -f "${INSTALL_DIR}/${f}" ]; then
            FAILED=$((FAILED+1))
        fi
    done

    echo ""
    if [ "${FAILED}" -gt 0 ]; then
        warn "${FAILED} files failed to download (some features may be limited)"
    else
        info "All ${TOTAL} files downloaded successfully"
    fi
}

# ─── Create config ────────────────────────────────────────
create_config() {
    step "Creating configuration..."
    mkdir -p "${CONFIG_DIR}"

    if [ ! -f "${CONFIG_DIR}/proboy.conf" ]; then
        cat > "${CONFIG_DIR}/proboy.conf" << 'EOF'
# ═══════════════════════════════════════════════════════
# Proboy Configuration
# Proboy x FreeLink — Internet Freedom for People
# Version: 1.0.0 Phoenix ALPHA
# ═══════════════════════════════════════════════════════

# General
enabled=1
log_level=info

# Zapret (DPI Bypass)
zapret_enabled=1
zapret_strategy=auto

# Game Filter
gamefilter_enabled=1
gamefilter_mode=universal

# PS5
ps5_enabled=0
ps5_detection=auto

# DNS
dns_enabled=1
dns_provider=cloudflare

# YouTube
youtube_enabled=1

# IPv6
ipv6_enabled=0

# Failover
failover_enabled=1
failover_check_interval=30

# Subscription
subscription_url=
subscription_auto_refresh=24

# Web Panel
web_enabled=1
web_port=8080
EOF
        info "Config created at ${CONFIG_DIR}/proboy.conf"
    else
        info "Config exists, keeping current"
    fi
}

# ─── Install service ──────────────────────────────────────
install_service() {
    step "Installing service..."

    if [ "${OS}" = "openwrt" ]; then
        cat > /etc/init.d/proboy << 'INITSCRIPT'
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

PROG=/opt/proboy/scripts/proboy.sh

start_service() {
    # Check if enabled
    if [ -f /etc/proboy/proboy.conf ]; then
        . /etc/proboy/proboy.conf
        if [ "${enabled}" != "1" ]; then
            echo "Proboy is disabled in config"
            return
        fi
    fi

    procd_open_instance
    procd_set_param command "$PROG" start
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    "$PROG" stop
}

reload_service() {
    stop
    start
}
INITSCRIPT
        chmod +x /etc/init.d/proboy
        /etc/init.d/proboy enable 2>/dev/null || true
        info "OpenWrt init script installed"
    else
        cat > /etc/systemd/system/proboy.service << 'SERVICE'
[Unit]
Description=Proboy x FreeLink — Anti-Censorship Suite
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/opt/proboy/scripts/proboy.sh start
ExecStop=/opt/proboy/scripts/proboy.sh stop
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE
        systemctl daemon-reload 2>/dev/null || true
        systemctl enable proboy 2>/dev/null || true
        info "systemd service installed"
    fi
}

# ─── Install uninstall script ────────────────────────────
install_uninstall() {
    step "Installing uninstall script..."

    cat > "${INSTALL_DIR}/uninstall.sh" << 'UNINSTALL'
#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Uninstaller
# Proboy x FreeLink — Internet Freedom for People
# ═══════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${RED}╔═══════════════════════════════════════╗${NC}"
echo -e "${RED}║  Proboy Uninstaller                   ║${NC}"
echo -e "${RED}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This will remove Proboy and all its files.${NC}"
echo ""
read -p "Are you sure? (y/N): " confirm

if [ "${confirm}" != "y" ] && [ "${confirm}" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Stopping services..."

# Stop OpenWrt service
if [ -f /etc/init.d/proboy ]; then
    /etc/init.d/proboy stop 2>/dev/null || true
    /etc/init.d/proboy disable 2>/dev/null || true
    rm -f /etc/init.d/proboy
    echo "OpenWrt service removed"
fi

# Stop systemd service
if command -v systemctl >/dev/null 2>&1; then
    systemctl stop proboy 2>/dev/null || true
    systemctl disable proboy 2>/dev/null || true
    rm -f /etc/systemd/system/proboy.service
    systemctl daemon-reload 2>/dev/null || true
    echo "systemd service removed"
fi

# Flush nftables rules
if command -v nft >/dev/null 2>&1; then
    nft flush ruleset 2>/dev/null || true
    echo "Firewall rules flushed"
fi

# Remove files
echo "Removing files..."
rm -rf /opt/proboy
rm -rf /etc/proboy
rm -rf /var/log/proboy
rm -rf /var/run/proboy
rm -f /usr/local/bin/proboy

echo ""
echo -e "${GREEN}Proboy has been removed.${NC}"
echo ""
UNINSTALL

    chmod +x "${INSTALL_DIR}/uninstall.sh"
    info "Uninstall script at ${INSTALL_DIR}/uninstall.sh"
}

# ─── Permissions ──────────────────────────────────────────
set_permissions() {
    step "Setting permissions..."
    chmod -R 755 "${INSTALL_DIR}" 2>/dev/null || true
    [ -d "${INSTALL_DIR}/bin" ] && chmod +x "${INSTALL_DIR}/bin/"* 2>/dev/null || true
    [ -d "${INSTALL_DIR}/scripts" ] && chmod +x "${INSTALL_DIR}/scripts/"*.sh 2>/dev/null || true
    chmod +x "${INSTALL_DIR}/uninstall.sh" 2>/dev/null || true
    info "Permissions set"
}

# ─── Summary ──────────────────────────────────────────────
show_summary() {
    LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
    [ -z "${LOCAL_IP}" ] && LOCAL_IP="your-router-ip"

    echo ""
    printf "${CYAN}  ╔═══════════════════════════════════════════════════════════╗${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${GREEN}${BOLD}Installation Complete!${NC}                                     ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${YELLOW}Version: ${PROBOY_VERSION} ${PROBOY_CODENAME} (${PROBOY_STATUS})${NC}                        ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════════════════════════╣${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${BOLD}System:${NC}     %-44s${CYAN}║${NC}\n" "${OS:-?} ${OS_VERSION:-}"
    printf "${CYAN}  ║${NC}  ${BOLD}Router:${NC}     %-44s${CYAN}║${NC}\n" "${BRAND} ${ROUTER_MODEL:-?}"
    printf "${CYAN}  ║${NC}  ${BOLD}Arch:${NC}       %-44s${CYAN}║${NC}\n" "${OS_ARCH:-?}"
    printf "${CYAN}  ║${NC}  ${BOLD}CPU:${NC}        %-44s${CYAN}║${NC}\n" "${CPU:-?} (${CORES} cores)"
    printf "${CYAN}  ║${NC}  ${BOLD}RAM:${NC}        %-44s${CYAN}║${NC}\n" "${RAM} MB"
    printf "${CYAN}  ║${NC}  ${BOLD}Flash:${NC}      %-44s${CYAN}║${NC}\n" "${FLASH_FREE} MB free"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════════════════════════╣${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${BOLD}Install:${NC}    ${CYAN}%-44s${NC}${CYAN}║${NC}\n" "${INSTALL_DIR}"
    printf "${CYAN}  ║${NC}  ${BOLD}Config:${NC}     ${CYAN}%-44s${NC}${CYAN}║${NC}\n" "${CONFIG_DIR}"
    printf "${CYAN}  ║${NC}  ${BOLD}Logs:${NC}       ${CYAN}%-44s${NC}${CYAN}║${NC}\n" "${LOG_DIR}"
    printf "${CYAN}  ║${NC}  ${BOLD}Uninstall:${NC}  ${CYAN}%-44s${NC}${CYAN}║${NC}\n" "${INSTALL_DIR}/uninstall.sh"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════════════════════════╣${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${YELLOW}${BOLD}Web Panel:${NC}  ${CYAN}http://%s:%s${NC}                            ${CYAN}║${NC}\n" "${LOCAL_IP}" "8080"
    printf "${CYAN}  ║${NC}  ${YELLOW}${BOLD}CLI:${NC}        ${NC}proboy start | stop | restart | status       ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${YELLOW}${BOLD}Uninstall:${NC}  ${NC}/opt/proboy/uninstall.sh                  ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════════════════════════╣${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${GREEN}Proboy x FreeLink — Internet Freedom for People${NC}          ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${MAGENTA}github.com/R3G1ST/Proboy${NC}                                  ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${MAGENTA}github.com/R3G1ST/FreeLink${NC}                                ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ╚═══════════════════════════════════════════════════════════╝${NC}\n"
    echo ""
}

# ─── Main ─────────────────────────────────────────────────
main() {
    show_banner

    if [ "$(id -u)" -ne 0 ]; then
        error "Run as root: sudo ./install.sh"
        exit 1
    fi

    detect_system
    install_deps
    mkdir -p "${INSTALL_DIR}/bin" "${INSTALL_DIR}/scripts" "${LOG_DIR}"
    install_binaries
    install_files
    create_config
    install_service
    install_uninstall
    set_permissions
    show_summary
}

main "$@"
