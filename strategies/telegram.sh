#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: Telegram optimized
# Telegram messaging, voice calls, media
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --hostlist-domains=telegram,tdlib,ton --dpi-desync=fake,multisplit --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=6 --dpi-desync-fooling=md5sig --new
--filter-tcp=80 --hostlist-domains=telegram --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-udp=443 --hostlist-domains=telegram --dpi-desync=fake --dpi-desync-repeats=6 --new
--filter-udp=1443 --hostlist-domains=telegram --dpi-desync=fake --dpi-desync-repeats=4 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n2
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443,1443"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
