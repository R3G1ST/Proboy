#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Gaming
# Universal gaming mode - low latency
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --dpi-desync=fake,splithttp --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-autottl=2 --new
--filter-tcp=80 --dpi-desync=fake --dpi-desync-fooling=md5sig --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-autottl=2 --new
--filter-udp=27015-27300 --dpi-desync=fake --dpi-desync-repeats=2 --new
--filter-udp=3478-3480 --dpi-desync=fake --dpi-desync-repeats=2 --new
--filter-udp=3074 --dpi-desync=fake --dpi-desync-repeats=2
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443,27015-27300,3478-3480,3074"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
