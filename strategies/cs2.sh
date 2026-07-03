#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: CS2 (Counter-Strike 2) optimized
# Valve servers, Steam
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --hostlist-domains=steampowered,steamcommunity,steamgames,valve --dpi-desync=fake,multisplit --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=4 --dpi-desync-fooling=md5sig --new
--filter-tcp=27015-27300 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n2 --new
--filter-udp=27015-27300 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=3478-3480 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=4380 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1
"

NFQWS_PORTS_TCP="80,443,27015-27300"
NFQWS_PORTS_UDP="27015-27300,3478-3480,4380"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
