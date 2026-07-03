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
# ║   github.com/R3G1ST/Proboy   github.com/R3G1ST/FreeLink             ║
# ║                                                                      ║
# ╚══════════════════════════════════════════════════════════════════════╝

set -e

# ─── Version ──────────────────────────────────────────────
PROBOY_VERSION="1.0.0"
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
banner()  { printf "${CYAN}$1${NC}\n"; }

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
    printf "  ${BOLD}Version:${NC} %s\n" "${PROBOY_VERSION}"
    printf "  ${BOLD}GitHub:${NC}  ${CYAN}github.com/R3G1ST/Proboy${NC}\n"
    echo ""
}

# ─── System Detection ─────────────────────────────────────
detect_system() {
    step "Detecting system..."

    # OS
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

    # Router model
    ROUTER_MODEL=""
    if [ -f /tmp/sysinfo/model ]; then
        ROUTER_MODEL="$(cat /tmp/sysinfo/model 2>/dev/null)"
    elif [ -f /proc/device-tree/model ]; then
        ROUTER_MODEL="$(cat /proc/device-tree/model 2>/dev/null | tr '\0' ' ')"
    elif [ -f /sys/class/dmi/id/product_name ]; then
        ROUTER_MODEL="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
    fi

    # Board name
    BOARD=""
    if [ -f /tmp/sysinfo/board_name ]; then
        BOARD="$(cat /tmp/sysinfo/board_name 2>/dev/null)"
    fi

    # Router brand
    BRAND="Unknown"
    case "${ROUTER_MODEL}" in
        *Xiaomi*|*Mi*)     BRAND="Xiaomi" ;;
        *TP-Link*|*TPINK*) BRAND="TP-Link" ;;
        *Netgear*)         BRAND="Netgear" ;;
        *ASUS*|*Asus*)     BRAND="ASUS" ;;
        *Keenetic*)        BRAND="Keenetic" ;;
        *GL.iNet*)         BRAND="GL.iNet" ;;
        *Zyxel*)           BRAND="Zyxel" ;;
        *Linksys*)         BRAND="Linksys" ;;
        *Ubiquiti*)        BRAND="Ubiquiti" ;;
        *MikroTik*)        BRAND="MikroTik" ;;
        *D-Link*)          BRAND="D-Link" ;;
        *Huawei*)          BRAND="Huawei" ;;
        *Tenda*)           BRAND="Tenda" ;;
        *Phicomm*)         BRAND="Phicomm" ;;
        *Realtek*)         BRAND="Realtek" ;;
    esac

    [ -n "${ROUTER_MODEL}" ] && info "Router: ${BRAND} ${ROUTER_MODEL}"
    [ -n "${BOARD}" ] && info "Board: ${BOARD}"

    # CPU
    CPU="$(cat /proc/cpuinfo 2>/dev/null | grep -m1 'model name' | cut -d: -f2 | xargs)"
    CORES="$(nproc 2>/dev/null || echo 1)"
    [ -n "${CPU}" ] && info "CPU: ${CPU} (${CORES} cores)"

    # RAM
    RAM="$(free -m 2>/dev/null | awk '/Mem:/{print $2}' || echo 0)"
    [ "${RAM}" -gt 0 ] && info "RAM: ${RAM} MB"

    # Flash
    FLASH_TOTAL="$(df -m / 2>/dev/null | tail -1 | awk '{print $2}' || echo 0)"
    FLASH_FREE="$(df -m / 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)"
    [ "${FLASH_TOTAL}" -gt 0 ] && info "Flash: ${FLASH_TOTAL} MB total, ${FLASH_FREE} MB free"

    # Package manager
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

    # nftables or iptables
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

# ─── Download helper ──────────────────────────────────────
dl() {
    local url="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    if command -v curl >/dev/null 2>&1; then
        curl -sL "${url}" -o "${dest}" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q "${url}" -O "${dest}" 2>/dev/null
    fi
}

# ─── Install binaries ────────────────────────────────────
install_binaries() {
    step "Installing binaries..."

    ARCH="$(uname -m)"

    # ── zapret ──
    if [ ! -f "${INSTALL_DIR}/bin/nfqws" ]; then
        info "Downloading zapret..."
        ZAPRET_VER="v72.12"
        dl "https://github.com/bol-van/zapret/releases/download/${ZAPRET_VER}/zapret-${ZAPRET_VER}.tar.gz" /tmp/zapret.tar.gz
        if [ -f /tmp/zapret.tar.gz ]; then
            tar -xzf /tmp/zapret.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/zapret*/nfqws "${INSTALL_DIR}/bin/" 2>/dev/null || true
            cp /tmp/zapret*/tpws "${INSTALL_DIR}/bin/" 2>/dev/null || true
            chmod +x "${INSTALL_DIR}/bin/nfqws" "${INSTALL_DIR}/bin/tpws" 2>/dev/null || true
            rm -rf /tmp/zapret* /tmp/zapret.tar.gz
            info "zapret installed"
        else
            warn "Failed to download zapret"
        fi
    fi

    # ── Hysteria2 ──
    if [ ! -f "${INSTALL_DIR}/bin/hysteria2" ]; then
        info "Downloading Hysteria2..."
        case "${ARCH}" in
            x86_64)  H2_ARCH="amd64" ;;
            aarch64) H2_ARCH="arm64" ;;
            armv7l)  H2_ARCH="armv7" ;;
            armv6l)  H2_ARCH="armv6" ;;
            mipsel)  H2_ARCH="mips-softfloat" ;;
            mips)    H2_ARCH="mipsel-softfloat" ;;
            *)       H2_ARCH="amd64" ;;
        esac
        dl "https://github.com/apernet/hysteria/releases/download/app%2Fv2.9.3/hysteria-linux-${H2_ARCH}" "${INSTALL_DIR}/bin/hysteria2"
        chmod +x "${INSTALL_DIR}/bin/hysteria2" 2>/dev/null || true
        info "Hysteria2 installed"
    fi

    # ── sing-box ──
    if [ ! -f "${INSTALL_DIR}/bin/sing-box" ]; then
        info "Downloading sing-box..."
        case "${ARCH}" in
            x86_64)  SB_ARCH="amd64" ;;
            aarch64) SB_ARCH="arm64" ;;
            armv7l)  SB_ARCH="armv7" ;;
            armv6l)  SB_ARCH="armv6" ;;
            mipsel)  SB_ARCH="mips" ;;
            mips)    SB_ARCH="mips64" ;;
            *)       SB_ARCH="amd64" ;;
        esac
        dl "https://github.com/SagerNet/sing-box/releases/download/v1.11.4/sing-box-1.11.4-linux-${SB_ARCH}.tar.gz" /tmp/singbox.tar.gz
        if [ -f /tmp/singbox.tar.gz ]; then
            tar -xzf /tmp/singbox.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/sing-box-*/sing-box "${INSTALL_DIR}/bin/" 2>/dev/null || true
            chmod +x "${INSTALL_DIR}/bin/sing-box" 2>/dev/null || true
            rm -rf /tmp/sing-box-* /tmp/singbox.tar.gz
            info "sing-box installed"
        fi
    fi
}

# ─── Download project files ──────────────────────────────
install_files() {
    step "Downloading project files..."

    # Scripts
    for f in scripts/proboy.sh scripts/detect_system.sh scripts/apply_config.sh; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # Modules
    for f in \
        modules/zapret/zapret_manager.py \
        modules/gamefilter/gamefilter.py \
        modules/ps5/ps5_manager.py \
        modules/network/network_analyzer.py \
        modules/dns/dns_manager.py \
        modules/youtube/youtube_manager.py \
        modules/ipv6/ipv6_manager.py \
        modules/subscriptions/sub_manager.py \
        modules/failover/failover.py \
        modules/combo/combo_builder.py; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # Web files
    for f in \
        web/index.html \
        web/css/proboy.css \
        web/js/app.js web/js/api.js web/js/combo.js web/js/authors.js \
        web/js/i18n.js web/js/dashboard.js \
        web/modules/zapret.html web/modules/games.html \
        web/modules/network.html web/modules/combo.html \
        web/modules/authors.html web/modules/subscriptions.html \
        web/modules/settings.html; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # Strategies
    for f in \
        strategies/general.sh strategies/general-alt.sh \
        strategies/fake-tls-auto.sh strategies/fake-tls-auto-alt.sh \
        strategies/discord.sh strategies/youtube.sh strategies/telegram.sh \
        strategies/gaming.sh strategies/fortnite.sh strategies/cs2.sh \
        strategies/psn.sh strategies/steam.sh strategies/epic.sh \
        strategies/aggressive.sh strategies/auto.sh; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # Lists
    for f in \
        lists/domains.txt lists/ips.txt lists/game-domains.txt \
        lists/psn-domains.txt lists/youtube-domains.txt \
        lists/telegram-domains.txt lists/discord-domains.txt; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # Game servers
    for f in \
        game-servers/steam.json game-servers/epic.json \
        game-servers/riot.json game-servers/blizzard.json \
        game-servers/ea.json game-servers/sony.json \
        game-servers/microsoft.json game-servers/nintendo.json; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # nftables
    for f in \
        nftables/nftables-game.nft nftables/ps5-nftables.nft \
        nftables/dns-bypass.nft nftables/youtube-nftables.nft \
        nftables/ipv6-nftables.nft; do
        dl "${GITHUB_RAW}/${f}" "${INSTALL_DIR}/${f}"
    done

    # Config
    dl "${GITHUB_RAW}/presets.json" "${INSTALL_DIR}/presets.json"

    info "All files downloaded"
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
        # OpenWrt procd init
        cat > /etc/init.d/proboy << 'INITSCRIPT'
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

PROG=/opt/proboy/scripts/proboy.sh

start_service() {
    procd_open_instance
    procd_set_param command "$PROG" start
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    "$PROG" stop
}
INITSCRIPT
        chmod +x /etc/init.d/proboy
        /etc/init.d/proboy enable 2>/dev/null || true
        info "OpenWrt init script installed"
    else
        # systemd
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

# ─── Permissions ──────────────────────────────────────────
set_permissions() {
    step "Setting permissions..."
    chmod -R 755 "${INSTALL_DIR}" 2>/dev/null || true
    [ -d "${INSTALL_DIR}/bin" ] && chmod +x "${INSTALL_DIR}/bin/"* 2>/dev/null || true
    [ -d "${INSTALL_DIR}/scripts" ] && chmod +x "${INSTALL_DIR}/scripts/"*.sh 2>/dev/null || true
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
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════════════════════════╣${NC}\n"
    printf "${CYAN}  ║${NC}                                                           ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${YELLOW}${BOLD}Web Panel:${NC}  ${CYAN}http://%s:%s${NC}                            ${CYAN}║${NC}\n" "${LOCAL_IP}" "8080"
    printf "${CYAN}  ║${NC}  ${YELLOW}${BOLD}CLI:${NC}        ${NC}proboy start | stop | restart | status       ${CYAN}║${NC}\n"
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
    set_permissions
    show_summary
}

main "$@"
