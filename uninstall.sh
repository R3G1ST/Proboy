#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Uninstaller
# Proboy x FreeLink — Internet Freedom for People
# ═══════════════════════════════════════════════════════

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
for pid in $(ps | grep "[s]ing-box" | awk '{print $1}'); do
    kill "${pid}" 2>/dev/null || true
done

# Stop zapret
echo "[>>] Stopping zapret..."
for pid in $(ps | grep "[n]fqws" | awk '{print $1}'); do
    kill "${pid}" 2>/dev/null || true
done

# Stop web server
echo "[>>] Stopping web server..."
for pid in $(ps | grep "[u]httpd.*proboy\|[h]ttpd.*8080" | awk '{print $1}'); do
    kill "${pid}" 2>/dev/null || true
done

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

# Remove LuCI integration
echo "[>>] Removing LuCI integration..."
rm -f /usr/share/luci/menu.d/proboy.json
rm -rf /www/luci-static/resources/view/proboy
rm -f /usr/share/rpcd/acl.d/proboy.json
rm -f /usr/libexec/rpcd/luci.proboy
rm -f /etc/config/proboy

# Restart rpcd
/etc/init.d/rpcd restart 2>/dev/null || true

# Remove all Proboy files
echo "[>>] Removing Proboy files..."
rm -rf /opt/proboy /etc/proboy /var/log/proboy /var/run/proboy /usr/local/bin/proboy

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║  Proboy removed completely            ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
