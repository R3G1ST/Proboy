#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy LuCI Integration Installer
# Installs Proboy into LuCI Services menu
# ═══════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/R3G1ST/Proboy/main"

echo "Installing Proboy LuCI integration..."

# Download and install menu entry
mkdir -p /usr/share/luci/menu.d
curl -sL "${REPO}/luci/root/usr/share/luci/menu.d/proboy.json" -o /usr/share/luci/menu.d/proboy.json

# Download and install views
mkdir -p /www/luci-static/resources/view/proboy
curl -sL "${REPO}/luci/view/proboy/status.js" -o /www/luci-static/resources/view/proboy/status.js
curl -sL "${REPO}/luci/view/proboy/settings.js" -o /www/luci-static/resources/view/proboy/settings.js

# Download and install ACL
mkdir -p /usr/share/rpcd/acl.d
curl -sL "${REPO}/luci/root/usr/share/rpcd/acl.d/proboy.json" -o /usr/share/rpcd/acl.d/proboy.json

# Create UCI config if not exists
if [ ! -f /etc/config/proboy ]; then
    cat > /etc/config/proboy << 'EOF'
config proboy 'main'
    option enabled '1'
    option zapret_enabled '1'
    option zapret_strategy 'auto'
    option gamefilter_enabled '1'
    option gamefilter_mode 'universal'
    option dns_enabled '1'
    option dns_provider 'cloudflare'
    option youtube_enabled '1'
    option ipv6_enabled '0'
    option failover_enabled '1'
    option subscription_url ''
    option web_enabled '1'
    option web_port '8080'
EOF
fi

# Create rpcd handler
mkdir -p /usr/libexec/rpcd
cat > /usr/libexec/rpcd/luci.proboy << 'RPCEOF'
#!/bin/sh

. /usr/libexec/luci-rpcd.sh

case "$1" in
    status)
        . /etc/proboy/proboy.conf 2>/dev/null
        running="false"
        zapret="false"
        singbox="false"
        gamefilter="false"
        dns="false"

        if [ -f /var/run/proboy/zapret.pid ]; then
            pid=$(cat /var/run/proboy/zapret.pid 2>/dev/null)
            [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && zapret="true" && running="true"
        fi
        if [ -f /var/run/proboy/singbox.pid ]; then
            pid=$(cat /var/run/proboy/singbox.pid 2>/dev/null)
            [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null && singbox="true" && running="true"
        fi
        [ "${gamefilter_enabled}" = "1" ] && gamefilter="true"
        [ "${dns_enabled}" = "1" ] && dns="true"

        cat << EOF
{
    "running": $running,
    "zapret": $zapret,
    "singbox": $singbox,
    "gamefilter": $gamefilter,
    "dns": $dns,
    "strategy": "${zapret_strategy:-auto}",
    "dns_provider": "${dns_provider:-cloudflare}"
}
EOF
        ;;
    start)
        /etc/init.d/proboy start 2>&1
        echo '{"ok":true}'
        ;;
    stop)
        /etc/init.d/proboy stop 2>&1
        echo '{"ok":true}'
        ;;
    restart)
        /etc/init.d/proboy restart 2>&1
        echo '{"ok":true}'
        ;;
    *)
        echo '{"error":"unknown method"}'
        exit 1
        ;;
esac
RPCEOF
chmod +x /usr/libexec/rpcd/luci.proboy

# Fix permissions
chmod 644 /usr/share/luci/menu.d/proboy.json
chmod 644 /www/luci-static/resources/view/proboy/*.js
chmod 644 /usr/share/rpcd/acl.d/proboy.json

# Restart LuCI rpcd to pick up new files
/etc/init.d/rpcd restart 2>/dev/null || true

echo ""
echo "Proboy LuCI integration installed!"
echo "Refresh LuCI page to see Proboy in Services menu."
echo ""
