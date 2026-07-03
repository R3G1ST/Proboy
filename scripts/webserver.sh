#!/bin/sh
# Proboy Web Server — busybox httpd + CGI API
# Serves web panel and handles API requests

WEB_DIR="/opt/proboy/web"
PID_DIR="/var/run/proboy"
LOG_DIR="/var/log/proboy"
CONFIG_DIR="/etc/proboy"
INSTALL_DIR="/opt/proboy"
PORT="${web_port:-8080}"
HTTPD_PID="${PID_DIR}/webserver.pid"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { printf "${GREEN}[✓]${NC} %s\n" "$1"; }
log_warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[✗]${NC} %s\n" "$1"; }
log_step()  { printf "${BLUE}[→]${NC} %s\n" "$1"; }

load_config() {
    if [ -f "${CONFIG_DIR}/proboy.conf" ]; then
        . "${CONFIG_DIR}/proboy.conf"
        PORT="${web_port:-8080}"
    fi
}

start_webserver() {
    if [ -f "${HTTPD_PID}" ]; then
        local pid=$(cat "${HTTPD_PID}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            log_info "Web server already running (PID: ${pid})"
            return
        fi
        rm -f "${HTTPD_PID}"
    fi

    load_config

    if [ ! -d "${WEB_DIR}" ]; then
        log_error "Web directory not found: ${WEB_DIR}"
        return 1
    fi

    log_step "Starting web server on port ${PORT}..."

    mkdir -p "${PID_DIR}" "${LOG_DIR}" "${WEB_DIR}/cgi-bin"

    # Ensure CGI script is executable
    chmod +x "${WEB_DIR}/cgi-bin/proboy-api" 2>/dev/null || true

    # Start busybox httpd
    # -p: port, -h: home directory (document root)
    httpd -p "${PORT}" -h "${WEB_DIR}" 2>/dev/null

    if [ $? -eq 0 ]; then
        # Save PID (httpd doesn't always write one, find it)
        local pid=$(pgrep -f "httpd.*-p.*${PORT}" 2>/dev/null | head -1)
        if [ -n "${pid}" ]; then
            echo "${pid}" > "${HTTPD_PID}"
        fi
        log_info "Web server started on port ${PORT}"
        log_info "URL: http://$(get_ip):${PORT}"
    else
        log_error "Failed to start web server"
        return 1
    fi
}

stop_webserver() {
    if [ -f "${HTTPD_PID}" ]; then
        local pid=$(cat "${HTTPD_PID}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}" 2>/dev/null || true
        fi
        rm -f "${HTTPD_PID}"
    fi

    # Also kill any orphan httpd on our port
    local pids=$(pgrep -f "httpd.*-p.*${PORT}" 2>/dev/null)
    if [ -n "${pids}" ]; then
        echo "${pids}" | while read p; do
            kill "${p}" 2>/dev/null || true
        done
    fi

    log_info "Web server stopped"
}

get_ip() {
    local ip=""
    # Try multiple methods to get LAN IP
    if command -v ip >/dev/null 2>&1; then
        ip=$(ip -4 addr show br-lan 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)
    fi
    if [ -z "${ip}" ] && command -v ifconfig >/dev/null 2>&1; then
        ip=$(ifconfig br-lan 2>/dev/null | grep -oP 'inet addr:\K[\d.]+' || true)
    fi
    if [ -z "${ip}" ]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    [ -z "${ip}" ] && ip="192.168.1.1"
    echo "${ip}"
}

case "${1}" in
    start)  start_webserver ;;
    stop)   stop_webserver ;;
    restart)
        stop_webserver
        sleep 1
        start_webserver
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
