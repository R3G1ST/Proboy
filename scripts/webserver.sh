#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Web Server — uhttpd (OpenWrt) + CGI API
# ═══════════════════════════════════════════════════════

WEB_DIR="/opt/proboy/web"
CGI_DIR="/opt/proboy/web/cgi-bin"
PID_DIR="/var/run/proboy"
LOG_DIR="/var/log/proboy"
CONFIG_DIR="/etc/proboy"
PORT="${web_port:-8080}"
HTTPD_PID="${PID_DIR}/webserver.pid"
UCI_CONF="/etc/config/uhttpd"
SECTION="proboy"

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
    # Kill by PID file
    if [ -f "${HTTPD_PID}" ]; then
        local pid=$(cat "${HTTPD_PID}" 2>/dev/null)
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            kill "${pid}" 2>/dev/null || true
            sleep 1
        fi
        rm -f "${HTTPD_PID}"
    fi
    # Kill uhttpd proboy instances
    for pid in $(ps 2>/dev/null | grep "[u]httpd" | awk '{print $1}'); do
        local cmdline=$(cat /proc/${pid}/cmdline 2>/dev/null | tr '\0' ' ')
        case "${cmdline}" in
            *${UCI_CONF}*|*proboy*) kill "${pid}" 2>/dev/null || true ;;
        esac
    done
    # Kill simple server
    for pid in $(ps 2>/dev/null | grep "[p]roboy-httpd" | awk '{print $1}'); do
        kill "${pid}" 2>/dev/null || true
    done
    sleep 1
}

# Add Proboy section to uhttpd UCI config
configure_uhttpd() {
    if [ ! -f "${UCI_CONF}" ]; then
        return 1
    fi

    # Check if proboy section already exists
    if uci get uhttpd.${SECTION} >/dev/null 2>&1; then
        # Update existing section
        uci set uhttpd.${SECTION}.listen_http="0.0.0.0:${PORT}"
        uci set uhttpd.${SECTION}.home="${WEB_DIR}"
        uci set uhttpd.${SECTION}.cgi_prefix="/cgi-bin"
        uci set uhttpd.${SECTION}.cgi_handler="/bin/sh"
        uhttpd.index_page="index.html"
    else
        # Create new section
        uci set uhttpd.${SECTION}=uhttpd
        uci set uhttpd.${SECTION}.listen_http="0.0.0.0:${PORT}"
        uci set uhttpd.${SECTION}.home="${WEB_DIR}"
        uci set uhttpd.${SECTION}.cgi_prefix="/cgi-bin"
        uci set uhttpd.${SECTION}.cgi_handler="/bin/sh"
        uci set uhttpd.${SECTION}.index_page="index.html"
    fi
    uci commit uhttpd 2>/dev/null
    return 0
}

start_uhttpd() {
    if ! command -v uhttpd >/dev/null 2>&1; then
        return 1
    fi

    log_step "Starting uhttpd on port ${PORT}..."

    # Configure via UCI
    if configure_uhttpd; then
        # Restart uhttpd to apply config
        /etc/init.d/uhttpd restart 2>/dev/null || true
        sleep 2

        # Check if port is listening
        if netstat -tlnp 2>/dev/null | grep -q ":${PORT} "; then
            log_info "uhttpd started via UCI"
            log_info "URL: http://$(get_ip):${PORT}"
            return 0
        fi
    fi

    # Fallback: direct CLI
    log_warn "UCI method failed, trying direct start..."
    uhttpd -f -p "${PORT}" -h "${WEB_DIR}" -r "${CGI_DIR}" 2>/dev/null &
    local pid=$!
    sleep 2

    if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "uhttpd started directly (PID: ${pid})"
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

    # BusyBox httpd - try with CGI
    httpd -f -p "${PORT}" -h "${WEB_DIR}" 2>/dev/null &
    local pid=$!
    sleep 2

    if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "httpd started (PID: ${pid})"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi

    return 1
}

start_simple_server() {
    log_warn "Using simple fallback server (no CGI)"

    cat > "${PID_DIR}/proboy-httpd.sh" << 'SEOF'
#!/bin/sh
PORT="$1"
WEB_DIR="$2"
while true; do
    REQ=$(nc -l -p "${PORT}" -q 1 2>/dev/null)
    # Extract path from request
    PATH_REQ=$(echo "${REQ}" | head -1 | awk '{print $2}')

    if echo "${PATH_REQ}" | grep -q "/api/"; then
        # CGI API request - execute proboy-api
        export REQUEST_METHOD="GET"
        export REQUEST_URI="${PATH_REQ}"
        export PATH_INFO="${PATH_REQ}"
        RESP=$("${WEB_DIR}/cgi-bin/proboy-api" 2>/dev/null)
        {
            echo "HTTP/1.0 200 OK"
            echo "Content-Type: application/json"
            echo "Access-Control-Allow-Origin: *"
            echo "Connection: close"
            echo ""
            echo "${RESP}"
        } | nc -l -p "${PORT}" -q 1 2>/dev/null
    else
        # Static file request
        FILE="${WEB_DIR}${PATH_REQ}"
        [ "${PATH_REQ}" = "/" ] && FILE="${WEB_DIR}/index.html"
        if [ -f "${FILE}" ]; then
            {
                echo "HTTP/1.0 200 OK"
                echo "Content-Type: text/html"
                echo "Connection: close"
                echo ""
                cat "${FILE}"
            } | nc -l -p "${PORT}" -q 1 2>/dev/null
        else
            {
                echo "HTTP/1.0 404 Not Found"
                echo "Content-Type: text/html"
                echo "Connection: close"
                echo ""
                echo "<h1>404 Not Found</h1>"
            } | nc -l -p "${PORT}" -q 1 2>/dev/null
        fi
    fi
done
SEOF
    chmod +x "${PID_DIR}/proboy-httpd.sh"

    "${PID_DIR}/proboy-httpd.sh" "${PORT}" "${WEB_DIR}" &
    local pid=$!
    if [ -n "${pid}" ]; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "Server started with CGI support (PID: ${pid})"
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
    stop_existing
    rm -f "${PID_DIR}/proboy-httpd.sh"
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
