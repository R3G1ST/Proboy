#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Manager — Core service controller
# Proboy x FreeLink — Internet Freedom for People
# ═══════════════════════════════════════════════════════

INSTALL_DIR="/opt/proboy"
CONFIG_DIR="/etc/proboy"
LOG_DIR="/var/log/proboy"
PID_DIR="/var/run/proboy"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { printf "${GREEN}[✓]${NC} %s\n" "$1"; }
log_warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[✗]${NC} %s\n" "$1"; }
log_step()  { printf "${BLUE}[→]${NC} %s\n" "$1"; }

# ─── Load config ──────────────────────────────────────────
load_config() {
    if [ -f "${CONFIG_DIR}/proboy.conf" ]; then
        . "${CONFIG_DIR}/proboy.conf"
    fi
}

# ─── Detect system ────────────────────────────────────────
detect_system() {
    if [ -f /etc/openwrt_release ]; then
        . /etc/openwrt_release
        OS="openwrt"
        OS_VERSION="${DISTRIB_RELEASE}"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="${ID:-linux}"
        OS_VERSION="${VERSION_ID}"
    else
        OS="linux"
        OS_VERSION="$(uname -r)"
    fi

    if [ -f /tmp/sysinfo/model ]; then
        ROUTER_MODEL="$(cat /tmp/sysinfo/model 2>/dev/null)"
    elif [ -f /proc/device-tree/model ]; then
        ROUTER_MODEL="$(cat /proc/device-tree/model 2>/dev/null | tr '\0' ' ')"
    fi
}

# ─── Check if running ─────────────────────────────────────
is_running() {
    local pidfile="${PID_DIR}/$1.pid"
    if [ -f "${pidfile}" ]; then
        local pid=$(cat "${pidfile}")
        if kill -0 "${pid}" 2>/dev/null; then
            return 0
        fi
        rm -f "${pidfile}"
    fi
    return 1
}

# ─── Write PID ────────────────────────────────────────────
write_pid() {
    mkdir -p "${PID_DIR}"
    echo "$2" > "${PID_DIR}/$1.pid"
}

# ─── Remove PID ───────────────────────────────────────────
remove_pid() {
    rm -f "${PID_DIR}/$1.pid"
}

# ─── Start zapret ─────────────────────────────────────────
start_zapret() {
    if [ "${zapret_enabled}" != "1" ]; then
        log_warn "Zapret disabled in config"
        return
    fi

    if is_running "zapret"; then
        log_info "Zapret already running"
        return
    fi

    log_step "Starting zapret..."

    if [ ! -f "${INSTALL_DIR}/bin/nfqws" ]; then
        log_error "nfqws not found"
        return
    fi

    STRATEGY="${zapret_strategy:-auto}"
    STRATEGY_FILE="${INSTALL_DIR}/strategies/${STRATEGY}.sh"

    if [ ! -f "${STRATEGY_FILE}" ]; then
        STRATEGY_FILE="${INSTALL_DIR}/strategies/general.sh"
    fi

    # Apply strategy
    if [ -f "${STRATEGY_FILE}" ]; then
        . "${STRATEGY_FILE}"
    fi

    # Apply nftables rules
    if command -v nft >/dev/null 2>&1; then
        for f in "${INSTALL_DIR}/nftables/"*.nft; do
            [ -f "$f" ] && nft -f "$f" 2>/dev/null || true
        done
    fi

    log_info "Zapret started (strategy: ${STRATEGY})"
}

# ─── Stop zapret ──────────────────────────────────────────
stop_zapret() {
    log_step "Stopping zapret..."
    if is_running "zapret"; then
        kill $(cat "${PID_DIR}/zapret.pid") 2>/dev/null || true
        remove_pid "zapret"
    fi

    # Flush only Proboy nftables tables (NOT the entire ruleset!)
    if command -v nft >/dev/null 2>&1; then
        nft delete table inet proboy_game 2>/dev/null || true
        nft delete table inet proboy_dns 2>/dev/null || true
        nft delete table inet proboy_ps5 2>/dev/null || true
        nft delete table inet proboy_youtube 2>/dev/null || true
        nft delete table inet proboy_ipv6 2>/dev/null || true
    fi

    log_info "Zapret stopped"
}

# ─── Start sing-box ───────────────────────────────────────
start_singbox() {
    if is_running "singbox"; then
        log_info "sing-box already running"
        return
    fi

    log_step "Starting sing-box..."

    if [ ! -f "${INSTALL_DIR}/bin/sing-box" ]; then
        log_warn "sing-box not found"
        return
    fi

    if [ -n "${subscription_url}" ] && [ "${subscription_url}" != "" ]; then
        ${INSTALL_DIR}/bin/sing-box run -c "${CONFIG_DIR}/singbox.json" &
        write_pid "singbox" $!
        log_info "sing-box started"
    else
        log_warn "No subscription configured, skipping sing-box"
    fi
}

# ─── Stop sing-box ────────────────────────────────────────
stop_singbox() {
    log_step "Stopping sing-box..."
    if is_running "singbox"; then
        kill $(cat "${PID_DIR}/singbox.pid") 2>/dev/null || true
        remove_pid "singbox"
    fi
    log_info "sing-box stopped"
}

# ─── Start game filter ────────────────────────────────────
start_gamefilter() {
    if [ "${gamefilter_enabled}" != "1" ]; then
        return
    fi

    log_step "Starting game filter..."

    # Apply game filter nftables rules
    if [ -f "${INSTALL_DIR}/nftables/nftables-game.nft" ]; then
        if command -v nft >/dev/null 2>&1; then
            nft -f "${INSTALL_DIR}/nftables/nftables-game.nft" 2>/dev/null || true
        fi
    fi

    log_info "Game filter started"
}

# ─── Start DNS ────────────────────────────────────────────
start_dns() {
    if [ "${dns_enabled}" != "1" ]; then
        return
    fi

    log_step "Starting DNS bypass..."

    if [ -f "${INSTALL_DIR}/nftables/dns-bypass.nft" ]; then
        if command -v nft >/dev/null 2>&1; then
            nft -f "${INSTALL_DIR}/nftables/dns-bypass.nft" 2>/dev/null || true
        fi
    fi

    log_info "DNS bypass started"
}

# ─── Start web server ────────────────────────────────────
start_web() {
    if [ "${web_enabled}" != "1" ]; then
        log_warn "Web panel disabled in config"
        return
    fi

    log_step "Starting web server..."
    if [ -x "${INSTALL_DIR}/scripts/webserver.sh" ]; then
        "${INSTALL_DIR}/scripts/webserver.sh" start
    else
        log_warn "Web server script not found"
    fi
}

# ─── Stop web server ──────────────────────────────────────
stop_web() {
    log_step "Stopping web server..."
    if [ -x "${INSTALL_DIR}/scripts/webserver.sh" ]; then
        "${INSTALL_DIR}/scripts/webserver.sh" stop
    fi
}

# ─── Start all ────────────────────────────────────────────
start_all() {
    load_config
    detect_system

    echo ""
    printf "${CYAN}  ╔═══════════════════════════════════════╗${NC}\n"
    printf "${CYAN}  ║${NC}  ${GREEN}${BOLD}Starting Proboy...${NC}                    ${CYAN}║${NC}\n"
    printf "${CYAN}  ║${NC}  ${NC}System: ${OS} ${OS_VERSION}               ${CYAN}║${NC}\n"
    [ -n "${ROUTER_MODEL}" ] && printf "${CYAN}  ║${NC}  ${NC}Router: ${ROUTER_MODEL}                  ${CYAN}║${NC}\n"
    printf "${CYAN}  ╚═══════════════════════════════════════╝${NC}\n"
    echo ""

    mkdir -p "${PID_DIR}" "${LOG_DIR}"

    start_zapret
    start_gamefilter
    start_dns
    start_singbox
    start_web

    echo ""
    log_info "Proboy started successfully!"
    echo ""
}

# ─── Stop all ─────────────────────────────────────────────
stop_all() {
    load_config

    echo ""
    log_step "Stopping Proboy..."
    echo ""

    stop_web
    stop_singbox
    stop_zapret

    # Flush only Proboy nftables tables (NOT the entire ruleset!)
    if command -v nft >/dev/null 2>&1; then
        nft delete table inet proboy_game 2>/dev/null || true
        nft delete table inet proboy_dns 2>/dev/null || true
        nft delete table inet proboy_ps5 2>/dev/null || true
        nft delete table inet proboy_youtube 2>/dev/null || true
        nft delete table inet proboy_ipv6 2>/dev/null || true
    fi

    rm -rf "${PID_DIR}"

    echo ""
    log_info "Proboy stopped"
    echo ""
}

# ─── Restart ──────────────────────────────────────────────
restart_all() {
    stop_all
    sleep 2
    start_all
}

# ─── Status ───────────────────────────────────────────────
show_status() {
    load_config
    detect_system

    echo ""
    printf "${CYAN}  ╔═══════════════════════════════════════╗${NC}\n"
    printf "${CYAN}  ║${NC}  ${BOLD}Proboy Status${NC}                         ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════╣${NC}\n"
    printf "${CYAN}  ║${NC}  System: ${OS} ${OS_VERSION}                ${CYAN}║${NC}\n"
    [ -n "${ROUTER_MODEL}" ] && printf "${CYAN}  ║${NC}  Router: ${ROUTER_MODEL}                   ${CYAN}║${NC}\n"
    printf "${CYAN}  ╠═══════════════════════════════════════╣${NC}\n"

    # Zapret status
    if is_running "zapret"; then
        printf "${CYAN}  ║${NC}  Zapret:      ${GREEN}● Running${NC}               ${CYAN}║${NC}\n"
    else
        printf "${CYAN}  ║${NC}  Zapret:      ${RED}● Stopped${NC}               ${CYAN}║${NC}\n"
    fi

    # sing-box status
    if is_running "singbox"; then
        printf "${CYAN}  ║${NC}  sing-box:    ${GREEN}● Running${NC}               ${CYAN}║${NC}\n"
    else
        printf "${CYAN}  ║${NC}  sing-box:    ${RED}● Stopped${NC}               ${CYAN}║${NC}\n"
    fi

    # Game filter
    if [ "${gamefilter_enabled}" = "1" ]; then
        printf "${CYAN}  ║${NC}  Game Filter: ${GREEN}● Enabled${NC}               ${CYAN}║${NC}\n"
    else
        printf "${CYAN}  ║${NC}  Game Filter: ${YELLOW}● Disabled${NC}              ${CYAN}║${NC}\n"
    fi

    # DNS
    if [ "${dns_enabled}" = "1" ]; then
        printf "${CYAN}  ║${NC}  DNS Bypass:  ${GREEN}● Enabled${NC}               ${CYAN}║${NC}\n"
    else
        printf "${CYAN}  ║${NC}  DNS Bypass:  ${YELLOW}● Disabled${NC}              ${CYAN}║${NC}\n"
    fi

    # Web panel
    if [ "${web_enabled}" = "1" ]; then
        printf "${CYAN}  ║${NC}  Web Panel:   ${GREEN}● Enabled${NC}               ${CYAN}║${NC}\n"
    else
        printf "${CYAN}  ║${NC}  Web Panel:   ${YELLOW}● Disabled${NC}              ${CYAN}║${NC}\n"
    fi

    printf "${CYAN}  ╚═══════════════════════════════════════╝${NC}\n"
    echo ""
}

# ─── Main ─────────────────────────────────────────────────
case "${1}" in
    start)   start_all ;;
    stop)    stop_all ;;
    restart) restart_all ;;
    status)  show_status ;;
    *)
        echo "Proboy x FreeLink — Internet Freedom for People"
        echo ""
        echo "Usage: $0 {start|stop|restart|status}"
        echo ""
        echo "  start   - Start all services"
        echo "  stop    - Stop all services"
        echo "  restart - Restart all services"
        echo "  status  - Show status"
        echo ""
        ;;
esac
