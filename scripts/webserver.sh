#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Web Server — uhttpd or busybox httpd + CGI API
# Serves web panel and handles API requests
# ═══════════════════════════════════════════════════════

WEB_DIR="/opt/proboy/web"
PID_DIR="/var/run/proboy"
LOG_DIR="/var/log/proboy"
CONFIG_DIR="/etc/proboy"
INSTALL_DIR="/opt/proboy"
PORT="${web_port:-8080}"
HTTPD_PID="${PID_DIR}/webserver.pid"
HTTPD_CONF="${CONFIG_DIR}/httpd.conf"

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

get_ip() {
    local ip=""
    if command -v ip >/dev/null 2>&1; then
        ip=$(ip -4 addr show br-lan 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -1)
    fi
    if [ -z "${ip}" ]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    [ -z "${ip}" ] && ip="192.168.1.1"
    echo "${ip}"
}

stop_existing() {
    # Kill any existing proboy httpd processes
    if [ -f "${HTTPD_PID}" ]; then
        local pid=$(cat "${HTTPD_PID}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}" 2>/dev/null || true
        fi
        rm -f "${HTTPD_PID}"
    fi

    # Kill orphan processes
    pkill -f "uhttpd.*-p.*${PORT}" 2>/dev/null || true
    pkill -f "httpd.*-p.*${PORT}" 2>/dev/null || true
    sleep 1
}

start_uhttpd() {
    # Try uhttpd first (standard OpenWrt web server)
    if ! command -v uhttpd >/dev/null 2>&1; then
        return 1
    fi

    log_step "Starting uhttpd on port ${PORT}..."

    # Create uhttpd config
    cat > "${HTTPD_CONF}" << UEOFCFG
config uhttpd 'proboy'
    list listen_http '0.0.0.0:${PORT}'
    list listen_https '0.0.0.0:$((PORT+1))'

    option home '${WEB_DIR}'
    option cgi '/cgi-bin'

    list interpreter '.sh=/bin/sh'
    list interpreter '.py=/usr/bin/python3'

    option index_page 'index.html'
    option error_page '404=/index.html'
UEOFCFG

    # Start uhttpd with our config
    uhttpd -f -c "${HTTPD_CONF}" &
    local pid=$!
    if [ -n "${pid}" ]; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "uhttpd started (PID: ${pid})"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi
    return 1
}

start_busybox_httpd() {
    if ! command -v httpd >/dev/null 2>&1; then
        return 1
    fi

    log_step "Starting busybox httpd on port ${PORT}..."

    # Create httpd config for CGI
    mkdir -p "${CONFIG_DIR}"
    cat > "${CONFIG_DIR}/busybox-httpd.conf" << 'BBCFG'
# BusyBox httpd configuration
# CGI scripts location
/cgi-bin:/opt/proboy/web/cgi-bin
BBCFG

    # Start httpd with CGI support
    httpd -p "${PORT}" -h "${WEB_DIR}" -c "${CONFIG_DIR}/busybox-httpd.conf" -f &
    local pid=$!
    if [ -n "${pid}" ]; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "httpd started (PID: ${pid})"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi
    return 1
}

start_simple_server() {
    # Fallback: simple netcat-based server (very basic, no CGI)
    log_warn "Using simple fallback server (no CGI API)"

    # Create a simple shell script server
    cat > "${PID_DIR}/simple-server.sh" << 'SEOF'
#!/bin/sh
PORT="$1"
WEB_DIR="$2"
while true; do
    echo -e "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n$(cat ${WEB_DIR}/index.html)" | nc -l -p ${PORT} -q 1 2>/dev/null
done
SEOF
    chmod +x "${PID_DIR}/simple-server.sh"

    "${PID_DIR}/simple-server.sh" "${PORT}" "${WEB_DIR}" &
    local pid=$!
    if [ -n "${pid}" ]; then
        echo "${pid}" > "${HTTPD_PID}"
        log_warn "Simple server started (PID: ${pid}) - limited functionality"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi
    return 1
}

start_webserver() {
    load_config
    stop_existing

    if [ ! -d "${WEB_DIR}" ]; then
        log_error "Web directory not found: ${WEB_DIR}"
        return 1
    fi

    mkdir -p "${PID_DIR}" "${LOG_DIR}" "${WEB_DIR}/cgi-bin"
    chmod +x "${WEB_DIR}/cgi-bin/proboy-api" 2>/dev/null || true

    # Try servers in order of preference
    if start_uhttpd; then
        return 0
    fi

    if start_busybox_httpd; then
        return 0
    fi

    if start_simple_server; then
        return 0
    fi

    log_error "No web server available (install uhttpd or busybox httpd)"
    return 1
}

stop_webserver() {
    if [ -f "${HTTPD_PID}" ]; then
        local pid=$(cat "${HTTPD_PID}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}" 2>/dev/null || true
        fi
        rm -f "${HTTPD_PID}"
    fi

    pkill -f "uhttpd.*proboy" 2>/dev/null || true
    pkill -f "httpd.*${PORT}" 2>/dev/null || true
    pkill -f "simple-server.sh" 2>/dev/null || true

    log_info "Web server stopped"
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
