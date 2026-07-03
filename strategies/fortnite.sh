#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Fortnite optimized
# Epic Games, Fortnite servers, EOS
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --hostlist-domains=epicgames,fortnite,unrealengine,eos --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --new
--filter-tcp=80 --hostlist-domains=epicgames,fortnite,unrealengine --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-udp=443 --hostlist-domains=epicgames,fortnite --dpi-desync=fake --dpi-desync-repeats=6 --new
--filter-udp=9000-9100 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1 --new
--filter-udp=27015-27300 --dpi-desync=fake --dpi-desync-repeats=2 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n1
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443,9000-9100,27015-27300"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
