#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Steam
# Optimized for Steam client and store
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --dpi-desync=fake,multisplit --dpi-desync-split-pos=1,midsld --dpi-desync-fooling=badseq,md5sig --dpi-desync-autottl=2 --new
--filter-tcp=80 --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-autottl=2 --new
--filter-udp=27015-27300 --dpi-desync=fake --dpi-desync-repeats=4 --new
--filter-udp=4380 --dpi-desync=fake --dpi-desync-repeats=4
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443,27015-27300,4380"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
