#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy LuCI Integration (Lua controller)
# ═══════════════════════════════════════════════════════

REPO="https://raw.githubusercontent.com/R3G1ST/Proboy/main"

echo "Installing Proboy LuCI integration..."

# Remove old JSON files (if any)
rm -f /usr/share/luci/menu.d/proboy.json
rm -f /usr/share/rpcd/acl.d/proboy.json

# 1. Lua controller
echo "  [1/2] Installing Lua controller..."
mkdir -p /usr/lib/lua/luci/controller
curl -sL "${REPO}/luci/controller/proboy.lua" -o /usr/lib/lua/luci/controller/proboy.lua

# 2. HTM templates
echo "  [2/2] Installing templates..."
mkdir -p /usr/lib/lua/luci/view/proboy
for f in status zapret games network subs settings; do
    curl -sL "${REPO}/luci/view/proboy/${f}.htm" -o "/usr/lib/lua/luci/view/proboy/${f}.htm"
done

# Fix permissions
chmod 644 /usr/lib/lua/luci/controller/proboy.lua
chmod 644 /usr/lib/lua/luci/view/proboy/*.htm

# Clear LuCI cache
rm -f /tmp/luci-indexcache
rm -rf /tmp/luci-compilecache

echo ""
echo "Done! Refresh LuCI page."
echo ""
