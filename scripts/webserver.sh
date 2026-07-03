#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Web Server — uhttpd or busybox httpd + CGI API
# Serves web panel and handles API requests
# ═══════════════════════════════════════════════════════

WEB_DIR="/opt/proboy/web"
CGI_DIR="/opt/proboy/web/cgi-bin"
PID_DIR="/var/run/proboy"
LOG_DIR="/var/log/proboy"
CONFIG_DIR="/etc/proboy"
INSTALL_DIR="/opt/proboy"
PORT="${web_port:-8080}"
HTTPD_PID="${PID_DIR}/webserver.pid"

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
    if [ -f "${HTTPD_PID}" ]; then
        local pid=$(cat "${HTTPD_PID}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}" 2>/dev/null || true
        fi
        rm -f "${HTTPD_PID}"
    fi
    pkill -f "uhttpd.*-p.*${PORT}" 2>/dev/null || true
    pkill -f "httpd.*-p.*${PORT}" 2>/dev/null || true
    sleep 1
}

start_uhttpd() {
    if ! command -v uhttpd >/dev/null 2>&1; then
        return 1
    fi

    log_step "Starting uhttpd on port ${PORT}..."

    # uhttpd with CGI support via command line flags
    uhttpd \
        -f \
        -p "${PORT}" \
        -h "${WEB_DIR}" \
        -r "${CGI_DIR}" \
        -i "index.html" \
        -t "text/html" \
        -M "text/html" \
        2>/dev/null &

    local pid=$!
    sleep 1

    if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "uhttpd started (PID: ${pid})"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi

    # Try adding to existing uhttpd via UCI
    log_warn "Direct start failed, trying UCI method..."
    if [ -f /etc/config/uhttpd ]; then
        # Add proboy instance to uhttpd config
        if ! grep -q "proboy" /etc/config/uhttpd 2>/dev/null; then
            cat >> /etc/config/uhttpd << UEOF

config uhttpd 'proboy'
    list listen_http '0.0.0.0:${PORT}'
    option home '${WEB_DIR}'
    option cgi_prefix '/cgi-bin'
    option cgi_handler '/bin/sh'
    option index_page 'index.html'
UEOF
            # Restart uhttpd to apply
            /etc/init.d/uhttpd restart 2>/dev/null || true
            sleep 2

            # Check if it's listening
            if netstat -tlnp 2>/dev/null | grep -q ":${PORT}"; then
                log_info "uhttpd configured via UCI"
                log_info "URL: http://$(get_ip):${PORT}"
                return 0
            fi
        fi
    fi

    return 1
}

start_busybox_httpd() {
    if ! command -v httpd >/dev/null 2>&1; then
        return 1
    fi

    log_step "Starting busybox httpd on port ${PORT}..."

    # Try with CGI support
    httpd -f -p "${PORT}" -h "${WEB_DIR}" -c /etc/passwd 2>/dev/null &
    local pid=$!
    sleep 1

    if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "httpd started (PID: ${pid})"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi

    return 1
}

start_simple_server() {
    log_warn "Using simple fallback server (limited functionality)"

    cat > "${PID_DIR}/proboy-httpd.sh" << 'SEOF'
#!/bin/sh
PORT="$1"
WEB_DIR="$2"
while true; do
    {
        echo "HTTP/1.0 200 OK"
        echo "Content-Type: text/html"
        echo "Connection: close"
        echo ""
        cat "${WEB_DIR}/index.html" 2>/dev/null || echo "<h1>Proboy</h1>"
    } | nc -l -p "${PORT}" -q 0 2>/dev/null
done
SEOF
    chmod +x "${PID_DIR}/proboy-httpd.sh"

    "${PID_DIR}/proboy-httpd.sh" "${PORT}" "${WEB_DIR}" &
    local pid=$!
    if [ -n "${pid}" ]; then
        echo "${pid}" > "${HTTPD_PID}"
        log_warn "Simple server started (PID: ${pid})"
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

    if start_uhttpd; then
        return 0
    fi

    if start_busybox_httpd; then
        return 0
    fi

    if start_simple_server; then
        return 0
    fi

    log_error "No web server available"
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
    pkill -f "uhttpd.*-p.*${PORT}" 2>/dev/null || true
    pkill -f "httpd.*-p.*${PORT}" 2>/dev/null || true
    pkill -f "proboy-httpd.sh" 2>/dev/null || true
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
