#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: ALT 9
# Source: Flowseal ALT 9
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --dpi-desync=fake,split2 --dpi-desync-split-seqovl=1 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-autottl=2 --dpi-desync-repeats=2 --new
--filter-tcp=80 --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-autottl=2
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
