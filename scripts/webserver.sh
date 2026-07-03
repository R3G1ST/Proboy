#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Web Server — uhttpd or CGI-capable server
# ═══════════════════════════════════════════════════════

WEB_DIR="/opt/proboy/web"
CGI_DIR="/opt/proboy/web/cgi-bin"
PID_DIR="/var/run/proboy"
LOG_DIR="/var/log/proboy"
CONFIG_DIR="/etc/proboy"
PORT="${web_port:-8080}"
HTTPD_PID="${PID_DIR}/webserver.pid"
UCI_CONF="/etc/config/uhttpd"

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
            sleep 1
        fi
        rm -f "${HTTPD_PID}"
    fi
    # Kill any uhttpd on our port
    for pid in $(ps 2>/dev/null | awk '/[u]httpd/ {print $1}'); do
        kill "${pid}" 2>/dev/null || true
    done
    # Kill simple servers
    for pid in $(ps 2>/dev/null | awk '/[p]roboy.*serve\|[s]imple.*http/ {print $1}'); do
        kill "${pid}" 2>/dev/null || true
    done
    sleep 1
}

start_uhttpd() {
    if ! command -v uhttpd >/dev/null 2>&1; then
        return 1
    fi
    if [ ! -f "${UCI_CONF}" ]; then
        return 1
    fi

    log_step "Starting uhttpd on port ${PORT}..."

    # Check if proboy section exists, if not add it
    if ! uci get uhttpd.proboy >/dev/null 2>&1; then
        uci set uhttpd.proboy=uhttpd
        uci set uhttpd.proboy.listen_http="0.0.0.0:${PORT}"
        uci set uhttpd.proboy.home="${WEB_DIR}"
        uci set uhttpd.proboy.cgi_prefix="/cgi-bin"
        uci set uhttpd.proboy.cgi_handler="/bin/sh"
        uci set uhttpd.proboy.index_page="index.html"
        uci commit uhttpd 2>/dev/null
    fi

    # Restart uhttpd
    /etc/init.d/uhttpd restart 2>/dev/null || true
    sleep 2

    # Verify port is listening
    if netstat -tlnp 2>/dev/null | grep -q ":${PORT} "; then
        log_info "uhttpd started on port ${PORT}"
        log_info "URL: http://$(get_ip):${PORT}"
        return 0
    fi

    return 1
}

start_httpd_with_cgi() {
    if ! command -v httpd >/dev/null 2>&1; then
        return 1
    fi

    log_step "Starting httpd on port ${PORT}..."

    # Create httpd CGI config
    mkdir -p "${CONFIG_DIR}"
    echo "/cgi-bin:${CGI_DIR}" > "${CONFIG_DIR}/httpd-cgi.conf"

    httpd -f -p "${PORT}" -h "${WEB_DIR}" -c "${CONFIG_DIR}/httpd-cgi.conf" 2>/dev/null &
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

start_cgi_server() {
    log_step "Starting CGI server on port ${PORT}..."

    # Write CGI-capable server script
    cat > "${PID_DIR}/proboy-server.sh" << 'SRVEOF'
#!/bin/sh
PORT="$1"
WEB_DIR="$2"
CGI_DIR="$3"

send_response() {
    local code="$1"
    local ctype="$2"
    local body="$3"
    printf "HTTP/1.0 %s\r\nContent-Type: %s\r\nConnection: close\r\nAccess-Control-Allow-Origin: *\r\n\r\n%s" "$code" "$ctype" "$body"
}

while true; do
    # Read request line
    REQUEST=$(nc -l -p "${PORT}" -q 0 -w 5 2>/dev/null)
    [ -z "${REQUEST}" ] && continue

    # Parse method and path
    METHOD=$(echo "${REQUEST}" | head -1 | awk '{print $1}')
    PATH_REQ=$(echo "${REQUEST}" | head -1 | awk '{print $2}')

    # Handle /api/* requests via CGI
    case "${PATH_REQ}" in
        /api/*)
            ENDPOINT="${PATH_REQ#/api/}"
            export REQUEST_METHOD="${METHOD}"
            export REQUEST_URI="${PATH_REQ}"
            export PATH_INFO="${ENDPOINT}"
            export CONTENT_LENGTH=0

            RESP=$("${CGI_DIR}/proboy-api" 2>/dev/null)
            if [ -n "${RESP}" ]; then
                send_response "200 OK" "application/json" "${RESP}"
            else
                send_response "500 Error" "application/json" '{"error":"CGI failed"}'
            fi
            ;;
        /cgi-bin/*)
            SCRIPT="${PATH_REQ#/cgi-bin/}"
            export REQUEST_METHOD="${METHOD}"
            export REQUEST_URI="${PATH_REQ}"
            export PATH_INFO="${SCRIPT}"
            export CONTENT_LENGTH=0

            RESP=$("${CGI_DIR}/${SCRIPT}" 2>/dev/null)
            if [ -n "${RESP}" ]; then
                send_response "200 OK" "application/json" "${RESP}"
            else
                send_response "500 Error" "application/json" '{"error":"CGI failed"}'
            fi
            ;;
        *)
            # Serve static files
            FILE="${WEB_DIR}${PATH_REQ}"
            [ "${PATH_REQ}" = "/" ] && FILE="${WEB_DIR}/index.html"

            if [ -f "${FILE}" ]; then
                # Detect content type
                CT="text/html"
                case "${FILE}" in
                    *.css) CT="text/css" ;;
                    *.js) CT="application/javascript" ;;
                    *.json) CT="application/json" ;;
                    *.png) CT="image/png" ;;
                    *.jpg|*.jpeg) CT="image/jpeg" ;;
                    *.svg) CT="image/svg+xml" ;;
                esac
                BODY=$(cat "${FILE}" 2>/dev/null)
                send_response "200 OK" "${CT}" "${BODY}"
            else
                send_response "404 Not Found" "text/html" "<h1>404 Not Found</h1>"
            fi
            ;;
    esac
done
SRVEOF
    chmod +x "${PID_DIR}/proboy-server.sh"

    "${PID_DIR}/proboy-server.sh" "${PORT}" "${WEB_DIR}" "${CGI_DIR}" &
    local pid=$!
    if [ -n "${pid}" ]; then
        echo "${pid}" > "${HTTPD_PID}"
        log_info "CGI server started (PID: ${pid})"
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

    # Try servers in order
    if start_uhttpd; then
        return 0
    fi

    if start_httpd_with_cgi; then
        return 0
    fi

    if start_cgi_server; then
        return 0
    fi

    log_error "No web server available"
    return 1
}

stop_webserver() {
    stop_existing
    rm -f "${PID_DIR}/proboy-server.sh"
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
