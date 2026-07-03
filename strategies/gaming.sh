#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Universal Gaming
# Low-latency DPI bypass for game traffic
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --dpi-desync=fake,multisplit --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=4 --dpi-desync-fooling=md5sig --dpi-desync-cutoff=n3 --new
--filter-tcp=80 --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --dpi-desync-cutoff=n3 --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-cutoff=n2 --new
--filter-udp=27000-28000 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=3478-3480 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=50000-65535 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443,27000-28000,3478-3480,50000-65535"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
