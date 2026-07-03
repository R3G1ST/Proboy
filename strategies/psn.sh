#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: PSN
# Optimized for PlayStation Network
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --dpi-desync=fake,multisplit --dpi-desync-split-pos=1,midsld --dpi-desync-fooling=badseq,md5sig --dpi-desync-autottl=2 --new
--filter-tcp=80 --dpi-desync=fake --dpi-desync-fooling=md5sig --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-autottl=2 --new
--filter-udp=3478-3480 --dpi-desync=fake --dpi-desync-repeats=4 --new
--filter-udp=3658 --dpi-desync=fake --dpi-desync-repeats=4 --new
--filter-udp=1935 --dpi-desync=fake --dpi-desync-repeats=4 --new
--filter-udp=52000-59999 --dpi-desync=fake --dpi-desync-repeats=4
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443,3478-3480,3658,1935,52000-59999"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
