"use strict";
"require form";
"require fs";

function getNetworkInfo() {
    var info = {};

    // IP addresses
    try {
        var ip = fs.exec("/bin/ip", ["-4", "addr", "show", "br-lan"]);
        if (ip && ip.stdout) {
            var match = ip.stdout.match(/inet\s+([\d.]+)\/(\d+)/);
            if (match) info.ip = match[1];
        }
    } catch(e) {}

    // Gateway
    try {
        var route = fs.exec("/bin/ip", ["route", "show", "default"]);
        if (route && route.stdout) {
            var match = route.stdout.match(/via\s+([\d.]+)/);
            if (match) info.gateway = match[1];
        }
    } catch(e) {}

    // DNS servers
    try {
        var resolv = fs.read("/tmp/resolv.conf.d/resolv.conf.auto");
        if (!resolv) resolv = fs.read("/tmp/resolv.conf");
        if (resolv) {
            var servers = [];
            var lines = resolv.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var m = lines[i].match(/nameserver\s+([\d.]+)/);
                if (m) servers.push(m[1]);
            }
            info.dns = servers.join(", ");
        }
    } catch(e) {}

    // WAN IP
    try {
        var wan = fs.exec("/bin/ip", ["-4", "addr", "show", "wan"]);
        if (wan && wan.stdout) {
            var match = wan.stdout.match(/inet\s+([\d.]+)\/(\d+)/);
            if (match) info.wan_ip = match[1];
        }
    } catch(e) {}

    // Interface status
    try {
        var ifaces = fs.exec("/bin/ip", ["-o", "link", "show"]);
        if (ifaces && ifaces.stdout) {
            var up = [];
            var lines = ifaces.stdout.split("\n");
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].match(/state UP/)) {
                    var m = lines[i].match(/^\d+:\s+(\S+)/);
                    if (m) up.push(m[1]);
                }
            }
            info.interfaces = up.join(", ");
        }
    } catch(e) {}

    // Uptime
    try {
        var up = fs.read("/proc/uptime");
        if (up) {
            var secs = parseFloat(up.split(" ")[0]);
            var days = Math.floor(secs / 86400);
            var hours = Math.floor((secs % 86400) / 3600);
            var mins = Math.floor((secs % 3600) / 60);
            info.uptime = days + "d " + hours + "h " + mins + "m";
        }
    } catch(e) {}

    return info;
}

return {
    createContent: function(s) {
        var info = getNetworkInfo();

        // DNS settings
        var o = s.option(form.Flag, "dns_enabled", _("Enable DNS Bypass"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "dns_provider", _("DNS Provider"));
        o.value("cloudflare", "Cloudflare (1.1.1.1)");
        o.value("google", "Google (8.8.8.8)");
        o.value("adguard", "AdGuard");
        o.default = "cloudflare";

        o = s.option(form.Flag, "youtube_enabled", _("YouTube Optimizer"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.Flag, "ipv6_enabled", _("IPv6 Bypass"));
        o.default = "0";
        o.rmempty = false;

        // Network info display
        o = s.option(form.DummyValue, "_netinfo", _("Network Info"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            var html = '<table style="width:100%;border-collapse:collapse;margin-top:8px">';
            html += '<tr><td style="padding:6px"><b>LAN IP</b></td><td>' + (info.ip || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Gateway</b></td><td>' + (info.gateway || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>DNS</b></td><td>' + (info.dns || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>WAN IP</b></td><td>' + (info.wan_ip || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Interfaces</b></td><td>' + (info.interfaces || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Uptime</b></td><td>' + (info.uptime || "?") + '</td></tr>';
            html += '</table>';
            return html;
        };

        return null;
    }
};
