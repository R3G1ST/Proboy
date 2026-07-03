#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy Strategy: YouTube optimized
# Handles YouTube, YouTube Music, Google Video CDN
# ═══════════════════════════════════════════════════════

NFWQS="${INSTALL_DIR}/bin/nfqws"

NFQWS_OPT="
--filter-tcp=443 --hostlist-domains=youtube,googlevideo,ggpht,ytimg --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=8 --dpi-desync-fooling=badseq --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com --new
--filter-tcp=80 --hostlist-domains=youtube,googlevideo,ggpht,ytimg --dpi-desync=fake,multisplit --dpi-desync-split-pos=method+2 --dpi-desync-fooling=md5sig --new
--filter-udp=443 --hostlist-domains=youtube,googlevideo --dpi-desync=fake --dpi-desync-repeats=8
"

NFQWS_PORTS_TCP="80,443"
NFQWS_PORTS_UDP="443"
DESYNC_MARK="0x40000000"

if [ -x "${NFWQS}" ]; then
    ${NFWQS} ${NFQWS_OPT} --qnum=0 &
    write_pid "zapret" $!
fi
