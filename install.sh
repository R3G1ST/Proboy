#!/bin/sh
# Proboy x FreeLink — Internet Freedom for People
# Anti-censorship suite for OpenWrt
# Version: 1.0.0 Phoenix ALPHA

set -e

VER="1.0.0"
CODENAME="Phoenix"
STATUS="ALPHA"
REPO="https://raw.githubusercontent.com/R3G1ST/Proboy/main"
DIR="/opt/proboy"
CFG="/etc/proboy"

# Generate escape codes properly for BusyBox ash
RED=$(printf '\033[0;31m')
GRN=$(printf '\033[0;32m')
YEL=$(printf '\033[1;33m')
BLU=$(printf '\033[0;34m')
CYN=$(printf '\033[0;36m')
MAG=$(printf '\033[0;35m')
NC=$(printf '\033[0m')
B=$(printf '\033[1m')

ok()   { printf "${GRN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YEL}[!!]${NC} %s\n" "$1"; }
err()  { printf "${RED}[XX]${NC} %s\n" "$1"; }
step() { printf "${BLU}[>>]${NC} %s\n" "$1"; }

dl() {
    mkdir -p "$(dirname "$2")"
    if command -v curl >/dev/null 2>&1; then
        curl -sL "$1" -o "$2" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$1" -O "$2" 2>/dev/null
    fi
}

show_banner() {
    printf "\n"
    printf "%s\n" "  ============================================"
    printf "${CYN}%s${NC}\n" "  P R O B O Y   x   F R E E L I N K"
    printf "%s\n" "  ============================================"
    printf "\n"
    printf "  ${B}%s${NC}     ${CYN}%s${NC}\n" "Version:" "${VER}"
    printf "  ${B}%s${NC}    ${MAG}%s${NC}\n" "Codename:" "${CODENAME}"
    printf "  ${B}%s${NC}      ${YEL}%s${NC}\n" "Status:" "${STATUS}"
    printf "  ${B}%s${NC}      ${CYN}%s${NC}\n" "GitHub:" "github.com/R3G1ST/Proboy"
    printf "\n"
    printf "  ${GRN}%s${NC}\n" "Internet Freedom for People"
    printf "  DPI bypass | Gaming | PS5 | Subscriptions"
    printf "\n\n"
}

detect_system() {
    step "Detecting system..."

    if [ -f /etc/openwrt_release ]; then
        . /etc/openwrt_release
        OS="openwrt"
        OS_VER="${DISTRIB_RELEASE}"
        OS_TGT="${DISTRIB_TARGET}"
        OS_ARCH="${DISTRIB_ARCH}"
        ok "OpenWrt ${OS_VER} (${OS_TGT})"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="${ID:-linux}"
        OS_VER="${VERSION_ID}"
        OS_ARCH="$(uname -m)"
        ok "${PRETTY_NAME:-Linux}"
    else
        OS="linux"
        OS_VER="$(uname -r)"
        OS_ARCH="$(uname -m)"
        ok "Linux ${OS_VER}"
    fi

    ROUTER=""
    [ -f /tmp/sysinfo/model ] && ROUTER="$(cat /tmp/sysinfo/model 2>/dev/null)"
    [ -z "${ROUTER}" ] && [ -f /proc/device-tree/model ] && ROUTER="$(cat /proc/device-tree/model 2>/dev/null | tr '\0' ' ')"
    [ -z "${ROUTER}" ] && [ -f /sys/class/dmi/id/product_name ] && ROUTER="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"

    BOARD=""
    [ -f /tmp/sysinfo/board_name ] && BOARD="$(cat /tmp/sysinfo/board_name 2>/dev/null)"

    BRAND="Unknown"
    case "${ROUTER}" in
        *Xiaomi*|*Mi*|*Redmi*) BRAND="Xiaomi" ;;
        *TP-Link*)             BRAND="TP-Link" ;;
        *Netgear*)             BRAND="Netgear" ;;
        *ASUS*)                BRAND="ASUS" ;;
        *Keenetic*)            BRAND="Keenetic" ;;
        *GL.iNet*)             BRAND="GL.iNet" ;;
        *Zyxel*)               BRAND="Zyxel" ;;
        *D-Link*)              BRAND="D-Link" ;;
        *Huawei*)              BRAND="Huawei" ;;
    esac

    if [ "${BRAND}" = "Unknown" ] && [ -n "${BOARD}" ]; then
        case "${BOARD}" in
            *redmi*|*xiaomi*)   BRAND="Xiaomi" ;;
            *tp-link*)          BRAND="TP-Link" ;;
            *keenetic*)         BRAND="Keenetic" ;;
            *gl-*)              BRAND="GL.iNet" ;;
        esac
    fi

    [ -n "${ROUTER}" ] && ok "Router: ${BRAND} ${ROUTER}"
    [ -n "${BOARD}" ] && [ "${BOARD}" != "${ROUTER}" ] && ok "Board: ${BOARD}"

    CPU="$(cat /proc/cpuinfo 2>/dev/null | grep -m1 'model name\|Processor\|Hardware\|CPU implementer' | cut -d: -f2 | xargs)"
    [ -z "${CPU}" ] && CPU="$(uname -m)"
    CORES="$(nproc 2>/dev/null || echo 1)"
    ok "CPU: ${CPU} - ${CORES} cores"

    RAM="$(free 2>/dev/null | awk '/Mem:/{print int($2/1024)}' || echo 0)"
    [ "${RAM}" -gt 0 ] && ok "RAM: ${RAM} MB"

    FLASH="$(df -m / 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)"
    [ "${FLASH}" -gt 0 ] && ok "Flash: ${FLASH} MB free"

    if command -v apk >/dev/null 2>&1; then
        PKG="apk"
        PKG_I="apk add --no-cache"
        ok "Package manager: APK"
    elif command -v opkg >/dev/null 2>&1; then
        PKG="opkg"
        PKG_I="opkg install"
        ok "Package manager: opkg"
    elif command -v apt-get >/dev/null 2>&1; then
        PKG="apt"
        PKG_I="apt-get install -y"
        ok "Package manager: apt"
    else
        PKG="none"
        warn "No package manager"
    fi
}

install_deps() {
    step "Installing dependencies..."
    NEED=""
    for cmd in curl wget tar gzip ip; do
        command -v "$cmd" >/dev/null 2>&1 || NEED="${NEED} ${cmd}"
    done
    command -v nft >/dev/null 2>&1 || command -v iptables >/dev/null 2>&1 || NEED="${NEED} nftables"
    # uhttpd for web panel
    command -v uhttpd >/dev/null 2>&1 || NEED="${NEED} uhttpd"

    if [ -n "${NEED}" ]; then
        warn "Missing:${NEED}"
        case "${PKG}" in
            apk)  ${PKG_I} curl wget tar gzip ip-full nftables uhttpd 2>/dev/null || true ;;
            opkg) ${PKG_I} curl wget tar gzip ip-full nftables iptables uhttpd 2>/dev/null || true ;;
            apt)  ${PKG_I} curl wget tar gzip iproute2 nftables uhttpd 2>/dev/null || true ;;
        esac
    fi
    ok "Dependencies ready"
}

install_binaries() {
    step "Installing binaries..."
    ARCH="$(uname -m)"
    mkdir -p "${DIR}/bin"

    if [ ! -f "${DIR}/bin/nfqws" ]; then
        step "[1/3] Downloading zapret..."
        dl "https://github.com/bol-van/zapret/releases/download/v72.12/zapret-v72.12.tar.gz" /tmp/zapret.tar.gz
        if [ -f /tmp/zapret.tar.gz ]; then
            tar -xzf /tmp/zapret.tar.gz -C /tmp/ 2>/dev/null
            ZDIR=$(ls -d /tmp/zapret* 2>/dev/null | head -1)

            # Map architecture to zapret directory name
            case "${ARCH}" in
                aarch64) ZARCH="arm64" ;;
                armv7l)  ZARCH="arm" ;;
                armv6l)  ZARCH="arm" ;;
                x86_64)  ZARCH="x86_64" ;;
                mips)    ZARCH="mips" ;;
                mipsel)  ZARCH="mipsel" ;;
                *)       ZARCH="x86_64" ;;
            esac

            # Try arch-specific path first, then fallback
            NFQWS=""
            [ -f "${ZDIR}/binaries/linux-${ZARCH}/nfqws" ] && NFQWS="${ZDIR}/binaries/linux-${ZARCH}/nfqws"
            [ -z "${NFQWS}" ] && NFQWS=$(ls ${ZDIR}/binaries/*/nfqws 2>/dev/null | head -1)

            TPWS=""
            [ -f "${ZDIR}/binaries/linux-${ZARCH}/tpws" ] && TPWS="${ZDIR}/binaries/linux-${ZARCH}/tpws"
            [ -z "${TPWS}" ] && TPWS=$(ls ${ZDIR}/binaries/*/tpws 2>/dev/null | head -1)

            if [ -n "${NFQWS}" ]; then
                cp "${NFQWS}" "${DIR}/bin/nfqws"
                [ -n "${TPWS}" ] && cp "${TPWS}" "${DIR}/bin/tpws" 2>/dev/null || true
                chmod +x "${DIR}/bin/nfqws" "${DIR}/bin/tpws" 2>/dev/null || true
                ok "zapret installed"
            else
                warn "nfqws not found in archive"
            fi
            rm -rf /tmp/zapret*
        fi
    else
        ok "zapret already installed"
    fi

    if [ ! -f "${DIR}/bin/hysteria2" ]; then
        case "${ARCH}" in
            x86_64)  HA="amd64" ;;
            aarch64) HA="arm64" ;;
            armv7l)  HA="armv7" ;;
            armv6l)  HA="armv6" ;;
            *)       HA="amd64" ;;
        esac
        step "[2/3] Downloading Hysteria2..."
        dl "https://github.com/apernet/hysteria/releases/download/app%2Fv2.9.3/hysteria-linux-${HA}" "${DIR}/bin/hysteria2"
        chmod +x "${DIR}/bin/hysteria2" 2>/dev/null || true
        ok "Hysteria2 installed"
    else
        ok "Hysteria2 already installed"
    fi

    if [ ! -f "${DIR}/bin/sing-box" ]; then
        case "${ARCH}" in
            x86_64)  SA="amd64" ;;
            aarch64) SA="arm64" ;;
            armv7l)  SA="armv7" ;;
            armv6l)  SA="armv6" ;;
            *)       SA="amd64" ;;
        esac
        step "[3/3] Downloading sing-box..."
        dl "https://github.com/SagerNet/sing-box/releases/download/v1.11.4/sing-box-1.11.4-linux-${SA}.tar.gz" /tmp/sb.tar.gz
        if [ -f /tmp/sb.tar.gz ]; then
            tar -xzf /tmp/sb.tar.gz -C /tmp/ 2>/dev/null
            cp /tmp/sing-box-*/sing-box "${DIR}/bin/" 2>/dev/null || true
            chmod +x "${DIR}/bin/sing-box" 2>/dev/null || true
            rm -rf /tmp/sing-box-* /tmp/sb.tar.gz
            ok "sing-box installed"
        fi
    else
        ok "sing-box already installed"
    fi
}

install_files() {
    step "Downloading project files..."
    TOTAL=65
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
        presets.json uninstall.sh
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
        warn "${FAIL} files failed"
    else
        ok "All files downloaded"
    fi
}

create_config() {
    step "Creating configuration..."
    mkdir -p "${CFG}"

    if [ ! -f "${CFG}/proboy.conf" ]; then
        cat > "${CFG}/proboy.conf" << 'CFGEOF'
# Proboy Configuration
# Version: 1.0.0 Phoenix ALPHA
enabled=1
log_level=info
zapret_enabled=1
zapret_strategy=auto
gamefilter_enabled=1
gamefilter_mode=universal
ps5_enabled=0
dns_enabled=1
dns_provider=cloudflare
youtube_enabled=1
ipv6_enabled=0
failover_enabled=1
subscription_url=
web_enabled=1
web_port=8080
CFGEOF
        ok "Config created"
    else
        ok "Config exists"
    fi
}

install_service() {
    step "Installing service..."

    if [ "${OS}" = "openwrt" ]; then
        cat > /etc/init.d/proboy << 'SVCEOF'
#!/bin/sh /etc/rc.common
# Proboy x FreeLink — OpenWrt Service
START=99
STOP=10

start() {
    [ -f /etc/proboy/proboy.conf ] && . /etc/proboy/proboy.conf
    if [ "${enabled}" != "1" ]; then
        echo "Proboy: disabled in config"
        return 0
    fi
    echo "Proboy: starting services..."
    /opt/proboy/scripts/proboy.sh start
}

stop() {
    echo "Proboy: stopping services..."
    /opt/proboy/scripts/proboy.sh stop
}

restart() {
    stop
    sleep 1
    start
}

status() {
    if [ -f /var/run/proboy/zapret.pid ]; then
        local pid=$(cat /var/run/proboy/zapret.pid 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            echo "Proboy: running (PID: $pid)"
            return 0
        fi
    fi
    echo "Proboy: stopped"
    return 1
}
SVCEOF
        chmod +x /etc/init.d/proboy
        /etc/init.d/proboy enable 2>/dev/null || true
        ok "OpenWrt service installed"
    else
        cat > /etc/systemd/system/proboy.service << 'SVCEOF'
[Unit]
Description=Proboy x FreeLink
After=network.target

[Service]
Type=simple
ExecStart=/opt/proboy/scripts/proboy.sh start
ExecStop=/opt/proboy/scripts/proboy.sh stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
SVCEOF
        systemctl daemon-reload 2>/dev/null || true
        systemctl enable proboy 2>/dev/null || true
        ok "systemd service installed"
    fi
}

install_uninstall() {
    step "Installing uninstall script..."
    mkdir -p "${DIR}"

    cat > "${DIR}/uninstall.sh" << 'UNEOF'
#!/bin/sh
echo "  ╔═══════════════════════════════════════╗"
echo "  ║  Proboy Uninstaller                   ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
echo "This will remove Proboy completely."
echo ""
printf "Are you sure? y/N: "
read ans
if [ "$ans" != "y" ] && [ "$ans" != "Y" ]; then
    echo "Cancelled"
    exit 0
fi

# Stop Proboy service
echo ""
echo "[>>] Stopping Proboy..."
if [ -f /etc/init.d/proboy ]; then
    /etc/init.d/proboy stop 2>/dev/null
    /etc/init.d/proboy disable 2>/dev/null
    rm -f /etc/init.d/proboy
fi
if command -v systemctl >/dev/null 2>&1; then
    systemctl stop proboy 2>/dev/null
    systemctl disable proboy 2>/dev/null
    rm -f /etc/systemd/system/proboy.service
    systemctl daemon-reload 2>/dev/null
fi

# Stop sing-box
echo "[>>] Stopping sing-box..."
if [ -f /opt/proboy/bin/sing-box ]; then
    # Kill any running sing-box processes
    pkill -f "sing-box" 2>/dev/null || true
fi

# Ask about sing-box removal
echo ""
printf "Remove sing-box binary? (for other projects) [y/N]: "
read sb_ans
if [ "$sb_ans" = "y" ] || [ "$sb_ans" = "Y" ]; then
    rm -f /opt/proboy/bin/sing-box
    echo "[OK] sing-box removed"
else
    echo "[OK] sing-box kept"
fi

# Flush only Proboy nftables tables (NOT the entire ruleset!)
echo "[>>] Flushing Proboy firewall rules..."
if command -v nft >/dev/null 2>&1; then
    nft delete table inet proboy_game 2>/dev/null || true
    nft delete table inet proboy_dns 2>/dev/null || true
    nft delete table inet proboy_ps5 2>/dev/null || true
    nft delete table inet proboy_youtube 2>/dev/null || true
    nft delete table inet proboy_ipv6 2>/dev/null || true
fi

# Remove all Proboy files
echo "[>>] Removing Proboy files..."
rm -rf /opt/proboy /etc/proboy /var/log/proboy /var/run/proboy /usr/local/bin/proboy

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║  Proboy removed completely            ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
UNEOF

    chmod +x "${DIR}/uninstall.sh"
    ok "Uninstall at ${DIR}/uninstall.sh"
}

set_permissions() {
    step "Setting permissions..."
    chmod -R 755 "${DIR}" 2>/dev/null || true
    chmod +x "${DIR}/bin/"* 2>/dev/null || true
    chmod +x "${DIR}/scripts/"*.sh 2>/dev/null || true
    chmod +x "${DIR}/uninstall.sh" 2>/dev/null || true
    ok "Permissions set"
}

install_luci() {
    step "Installing LuCI integration..."

    if [ ! -d /www/luci-static/resources ]; then
        warn "LuCI not found, skipping integration"
        return
    fi

    # Menu entry
    mkdir -p /usr/share/luci/menu.d
    dl "${REPO}/luci/root/usr/share/luci/menu.d/proboy.json" /usr/share/luci/menu.d/proboy.json 2>/dev/null || true

    # Views
    mkdir -p /www/luci-static/resources/view/proboy
    for f in status zapret games network subs settings; do
        dl "${REPO}/luci/view/proboy/${f}.js" "/www/luci-static/resources/view/proboy/${f}.js" 2>/dev/null || true
    done

    # ACL
    mkdir -p /usr/share/rpcd/acl.d
    dl "${REPO}/luci/root/usr/share/rpcd/acl.d/proboy.json" /usr/share/rpcd/acl.d/proboy.json 2>/dev/null || true

    # RPC handler
    mkdir -p /usr/libexec/rpcd
    dl "${REPO}/luci/root/usr/libexec/rpcd/luci.proboy" /usr/libexec/rpcd/luci.proboy 2>/dev/null || true
    chmod +x /usr/libexec/rpcd/luci.proboy 2>/dev/null || true

    # UCI config
    if [ ! -f /etc/config/proboy ]; then
        dl "${REPO}/luci/root/etc/config/proboy" /etc/config/proboy 2>/dev/null || true
    fi

    # Fix permissions
    chmod 644 /usr/share/luci/menu.d/proboy.json 2>/dev/null || true
    chmod 644 /www/luci-static/resources/view/proboy/*.js 2>/dev/null || true
    chmod 644 /usr/share/rpcd/acl.d/proboy.json 2>/dev/null || true

    # Restart rpcd
    /etc/init.d/rpcd restart 2>/dev/null || true

    ok "LuCI integration installed"
}

show_summary() {
    IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
    [ -z "${IP}" ] && IP="your-router-ip"

    echo ""
    echo "  ============================================"
    echo "  ${GRN}Installation Complete!${NC}"
    echo "  ${YEL}Version: ${VER} ${CODENAME} ${STATUS}${NC}"
    echo "  ============================================"
    echo ""
    echo "  ${B}System:${NC}   ${OS:-?} ${OS_VER:-}"
    echo "  ${B}Router:${NC}   ${BRAND} ${ROUTER:-?}"
    echo "  ${B}Arch:${NC}     ${OS_ARCH:-?}"
    echo "  ${B}CPU:${NC}      ${CPU:-?} - ${CORES} cores"
    echo "  ${B}RAM:${NC}      ${RAM} MB"
    echo "  ${B}Flash:${NC}    ${FLASH} MB free"
    echo ""
    echo "  ${B}Install:${NC}  ${DIR}"
    echo "  ${B}Config:${NC}   ${CFG}"
    echo "  ${B}Uninstall:${NC} ${DIR}/uninstall.sh"
    echo ""
    echo "  ${YEL}Web Panel:${NC}  ${CYN}http://${IP}:8080${NC}"
    echo "  ${YEL}LuCI:${NC}       Services → Proboy"
    echo "  ${YEL}CLI:${NC}        proboy start | stop | restart | status"
    echo "  ${YEL}Uninstall:${NC} ${DIR}/uninstall.sh"
    echo ""
    echo "  ============================================"
    echo "  ${GRN}Proboy x FreeLink${NC}"
    echo "  ${MAG}github.com/R3G1ST/Proboy${NC}"
    echo "  ${MAG}github.com/R3G1ST/FreeLink${NC}"
    echo "  ============================================"
    echo ""
}

main() {
    show_banner

    if [ "$(id -u)" -ne 0 ]; then
        err "Run as root"
        exit 1
    fi

    detect_system
    install_deps
    mkdir -p "${DIR}/bin" "${DIR}/scripts" /var/log/proboy
    install_binaries
    install_files
    create_config
    install_service
    install_luci
    install_uninstall
    set_permissions
    show_summary
}

main "$@"
