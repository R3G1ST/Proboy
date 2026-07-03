#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Aggressive
# Maximum DPI bypass — may break some sites
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=80 --dpi-desync=fake,disorder2 --dpi-desync-repeats=6 --dpi-desync-fooling=md5sig --new
--filter-tcp=443 --dpi-desync=fake,disorder2 --dpi-desync-repeats=8 --dpi-desync-fooling=badseq,md5sig --new
--filter-udp=443 --dpi-desync=fake --dpi-desync-repeats=8 --new
--filter-udp=1-65535 --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="1-65535"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
