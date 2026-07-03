#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: General (default)
# Source: Flowseal general.bat
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=80 --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-tcp=443 --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-fooling=badseq,md5sig --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=6
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443"
DESYNC_MARK="0x40000000"

# Start nfqws if binary exists
if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
