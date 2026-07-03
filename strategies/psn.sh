#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: PlayStation Network (PS5/PS4)
# PSN Store, Voice Chat, Online Play
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --hostlist-domains=playstation,sony,playstationnetwork --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --new
--filter-tcp=80 --hostlist-domains=playstation,sony --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-tcp=3478-3480 --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n2 --new
--filter-udp=3478-3480 --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=3658 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=1935 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=52000-59999 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1
"

NFQWS_PORTS_TCP="80,443,3478-3480"
NFQWS_PORTS_UDP="3478-3480,3658,1935,52000-59999"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
