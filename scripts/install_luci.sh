#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy LuCI Full Integration Installer
# ═══════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/R3G1ST/Proboy/main"

echo "Installing Proboy LuCI integration..."

# 1. Menu entry
echo "  [1/5] Installing menu entry..."
mkdir -p /usr/share/luci/menu.d
curl -sL "${REPO}/luci/root/usr/share/luci/menu.d/proboy.json" -o /usr/share/luci/menu.d/proboy.json

# 2. Views (JS pages)
echo "  [2/5] Installing views..."
mkdir -p /www/luci-static/resources/view/proboy
for f in status zapret games network subs settings; do
    curl -sL "${REPO}/luci/view/proboy/${f}.js" -o /www/luci-static/resources/view/proboy/${f}.js
done

# 3. ACL
echo "  [3/5] Installing ACL..."
mkdir -p /usr/share/rpcd/acl.d
curl -sL "${REPO}/luci/root/usr/share/rpcd/acl.d/proboy.json" -o /usr/share/rpcd/acl.d/proboy.json

# 4. RPC handler
echo "  [4/5] Installing RPC handler..."
mkdir -p /usr/libexec/rpcd
curl -sL "${REPO}/luci/root/usr/libexec/rpcd/luci.proboy" -o /usr/libexec/rpcd/luci.proboy
chmod +x /usr/libexec/rpcd/luci.proboy

# 5. UCI config
echo "  [5/5] Installing UCI config..."
if [ ! -f /etc/config/proboy ]; then
    curl -sL "${REPO}/luci/root/etc/config/proboy" -o /etc/config/proboy
fi

# Fix permissions
chmod 644 /usr/share/luci/menu.d/proboy.json
chmod 644 /www/luci-static/resources/view/proboy/*.js
chmod 644 /usr/share/rpcd/acl.d/proboy.json
chmod 755 /usr/libexec/rpcd/luci.proboy

# Restart services
/etc/init.d/rpcd restart 2>/dev/null || true

echo ""
echo "Done! Refresh LuCI to see Proboy in Services menu."
echo ""
echo "Features:"
echo "  - Dashboard: status, start/stop/restart"
echo "  - Zapret: strategy selection"
echo "  - Games: game filter settings"
echo "  - Network: DNS, YouTube, IPv6"
echo "  - Subscriptions: manage subscriptions"
echo "  - Settings: general options"
echo ""
