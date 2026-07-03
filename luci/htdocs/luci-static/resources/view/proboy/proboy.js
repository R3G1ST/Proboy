"use strict";
"require view";
"require form";
"require fs";
"require uci";

function isRunning(name) {
    try {
        var pid = fs.read("/var/run/proboy/" + name + ".pid");
        if (pid && pid.trim()) { fs.exec("/bin/kill", ["-0", pid.trim()]); return true; }
    } catch(e) {}
    return false;
}

async function sysInfo() {
    var R = {};
    try { var m = await fs.read("/proc/meminfo"); if (m) { var x = m.match(/MemTotal:\s+(\d+)/); if (x) R.ram = Math.round(parseInt(x[1])/1024)+" MB"; } } catch(e) {}
    try { var d = await fs.exec("/bin/df",["-m","/"]); if (d && d.stdout) { var p = d.stdout.split("\n")[1].split(/\s+/); R.flash = p[3]+" MB free"; } } catch(e) {}
    try { var c = await fs.read("/proc/cpuinfo"); if (c) { var x = c.match(/model name\s*:\s*(.+)/i)||c.match(/Processor\s*:\s*(.+)/i)||c.match(/Hardware\s*:\s*(.+)/i)||c.match(/CPU implementer\s*:\s*(.+)/i); if (x) R.cpu = x[1].trim(); } } catch(e) {}
    try { var n = await fs.exec("/bin/nproc"); if (n && n.stdout) R.cores = n.stdout.trim(); } catch(e) { R.cores="1"; }
    try { var u = await fs.exec("/bin/uname",["-m"]); if (u && u.stdout) R.arch = u.stdout.trim(); } catch(e) {}
    try { var r = await fs.read("/etc/openwrt_release"); if (r) { var d = r.match(/DISTRIB_RELEASE='([^']+)'/); R.os = "OpenWrt " + (d?d[1]:"?"); } } catch(e) {}
    try { var md = await fs.read("/tmp/sysinfo/model"); if (md) R.model = md.trim(); } catch(e) {}
    try { R.ver = (await fs.trimmed("/opt/proboy/VERSION")); } catch(e) {}
    if (!R.ver) try { R.ver = (await fs.trimmed("/etc/proboy/VERSION")); } catch(e) {}
    if (!R.ver) try { var v = await fs.exec("/bin/cat", ["/opt/proboy/VERSION"]); if (v && v.stdout) R.ver = v.stdout.trim(); } catch(e) {}
    try { var ip = await fs.exec("/bin/ip",["-4","addr","show","br-lan"]); if (ip && ip.stdout) { var x = ip.stdout.match(/inet\s+([\d.]+)/); if (x) R.ip = x[1]; } } catch(e) {}
    try { var rt = await fs.exec("/bin/ip",["route","show","default"]); if (rt && rt.stdout) { var x = rt.stdout.match(/via\s+([\d.]+)/); if (x) R.gw = x[1]; } } catch(e) {}
    try { var rs = await fs.read("/tmp/resolv.conf") || await fs.read("/tmp/resolv.conf.d/resolv.conf.auto"); if (rs) { var s=[]; rs.split("\n").forEach(function(l){var m=l.match(/nameserver\s+([\d.]+)/);if(m)s.push(m[1]);}); R.dns=s.join(", "); } } catch(e) {}
    try { var up = await fs.read("/proc/uptime"); if (up) { var s=parseFloat(up.split(" ")[0]); R.uptime=Math.floor(s/86400)+"d "+Math.floor((s%86400)/3600)+"h "+Math.floor((s%3600)/60)+"m"; } } catch(e) {}
    return R;
}

return view.extend({
    render: async function() {
        var m = new form.Map("proboy", "\u041F\u0440\u043E\u0431\u043E\u0439", "Anti-censorship suite");
        m.tabbed = true;
        var info = await sysInfo();

        var s = m.section(form.TypedSection, "proboy", "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438 Proboy");
        s.anonymous = true;
        s.addremove = false;

        /* ═══ Dashboard ═══ */
        s.tab("dashboard", "\u041F\u0430\u043D\u0435\u043B\u044C");

        var o = s.taboption("dashboard", form.Value, "_status", "\u0421\u0442\u0430\u0442\u0443\u0441");
        o.readonly = true;
        o.cfgvalue = function() {
            var z = isRunning("zapret") ? "Running" : "Stopped";
            var sb = isRunning("singbox") ? "Running" : "Stopped";
            var gf = uci.get("proboy","main","gamefilter_enabled")==="1";
            var dn = uci.get("proboy","main","dns_enabled")==="1";
            var st = uci.get("proboy","main","zapret_strategy")||"auto";
            return "Zapret: "+z+" ("+st+") | sing-box: "+sb+" | Game: "+(gf?"On":"Off")+" | DNS: "+(dn?"On":"Off");
        };

        o = s.taboption("dashboard", form.Value, "_os", "\u041E\u0421");
        o.readonly = true;
        o.cfgvalue = function() { return info.os || "?"; };

        o = s.taboption("dashboard", form.Value, "_model", "\u0420\u043E\u0443\u0442\u0435\u0440");
        o.readonly = true;
        o.cfgvalue = function() { return info.model || "?"; };

        o = s.taboption("dashboard", form.Value, "_cpu", "CPU");
        o.readonly = true;
        o.cfgvalue = function() { return (info.cpu||"?") + " (" + info.cores + " cores)"; };

        o = s.taboption("dashboard", form.Value, "_ram", "RAM");
        o.readonly = true;
        o.cfgvalue = function() { return info.ram || "?"; };

        o = s.taboption("dashboard", form.Value, "_flash", "Flash");
        o.readonly = true;
        o.cfgvalue = function() { return info.flash || "?"; };

        o = s.taboption("dashboard", form.Value, "_arch", "Arch");
        o.readonly = true;
        o.cfgvalue = function() { return info.arch || "?"; };

        o = s.taboption("dashboard", form.Value, "_ver", "\u0412\u0435\u0440\u0441\u0438\u044F");
        o.readonly = true;
        o.cfgvalue = function() { return info.ver || "?"; };

        o = s.taboption("dashboard", form.Value, "_uptime", "Uptime");
        o.readonly = true;
        o.cfgvalue = function() { return info.uptime || "?"; };

        /* ═══ Zapret ═══ */
        s.tab("zapret", "Zapret");

        o = s.taboption("zapret", form.Flag, "zapret_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C Zapret");
        o.default = "1"; o.rmempty = false;

        o = s.taboption("zapret", form.ListValue, "zapret_strategy", "\u0421\u0442\u0440\u0430\u0442\u0435\u0433\u0438\u044F");
        [["auto","\u0410\u0432\u0442\u043E"],["general","\u041E\u0431\u0449\u0430\u044F"],["general-alt","\u041E\u0431\u0449\u0430\u044F ALT"],["fake-tls-auto","FAKE TLS AUTO"],["fake-tls-auto-alt","FAKE TLS AUTO ALT"],["simple-fake","SIMPLE FAKE"],["discord","Discord"],["youtube","YouTube"],["telegram","Telegram"],["gaming","\u0418\u0433\u0440\u044B"],["fortnite","Fortnite"],["cs2","CS2"],["psn","PlayStation Network"],["steam","Steam"],["epic","Epic Games"],["alt1","ALT 1"],["alt2","ALT 2"],["alt3","ALT 3"],["alt4","ALT 4"],["alt5","ALT 5"],["alt6","ALT 6"],["alt7","ALT 7"],["alt8","ALT 8"],["alt9","ALT 9"],["alt10","ALT 10"],["alt11","ALT 11"],["alt12","ALT 12"],["aggressive","\u0410\u0433\u0440\u0435\u0441\u0441\u0438\u0432\u043D\u0430\u044F"]].forEach(function(x){o.value(x[0],x[1]);});
        o.default = "auto";

        o = s.taboption("zapret", form.Flag, "failover_enabled", "Failover");
        o.default = "1"; o.rmempty = false;

        /* ═══ Games ═══ */
        s.tab("games", "\u0418\u0433\u0440\u044B");

        o = s.taboption("games", form.Flag, "gamefilter_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C Game Filter");
        o.default = "1"; o.rmempty = false;

        o = s.taboption("games", form.ListValue, "gamefilter_mode", "\u0420\u0435\u0436\u0438\u043C");
        o.value("universal", "\u0423\u043D\u0438\u0432\u0435\u0440\u0441\u0430\u043B\u044C\u043D\u044B\u0439");
        o.value("custom", "\u041F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044C\u0441\u043A\u0438\u0439");
        o.default = "universal";

        o = s.taboption("games", form.Flag, "ps5_enabled", "PS5");
        o.default = "0"; o.rmempty = false;

        /* ═══ Network ═══ */
        s.tab("network", "\u0421\u0435\u0442\u044C");

        o = s.taboption("network", form.Flag, "dns_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C DNS");
        o.default = "1"; o.rmempty = false;

        o = s.taboption("network", form.ListValue, "dns_provider", "DNS");
        o.value("cloudflare", "Cloudflare (1.1.1.1)");
        o.value("google", "Google (8.8.8.8)");
        o.value("adguard", "AdGuard");
        o.default = "cloudflare";

        o = s.taboption("network", form.Flag, "youtube_enabled", "YouTube");
        o.default = "1"; o.rmempty = false;

        o = s.taboption("network", form.Flag, "ipv6_enabled", "IPv6");
        o.default = "0"; o.rmempty = false;

        o = s.taboption("network", form.Value, "_ip", "LAN IP");
        o.readonly = true;
        o.cfgvalue = function() { return info.ip||"?"; };

        o = s.taboption("network", form.Value, "_gw", "Gateway");
        o.readonly = true;
        o.cfgvalue = function() { return info.gw||"?"; };

        o = s.taboption("network", form.Value, "_dns", "DNS");
        o.readonly = true;
        o.cfgvalue = function() { return info.dns||"?"; };

        /* ═══ Subscriptions ═══ */
        s.tab("subs", "\u041F\u043E\u0434\u043F\u0438\u0441\u043A\u0438");

        o = s.taboption("subs", form.Value, "subscription_url", "URL");
        o.placeholder = "https://..."; o.rmempty = true;

        /* ═══ Settings ═══ */
        s.tab("settings", "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438");

        o = s.taboption("settings", form.Flag, "enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C Proboy");
        o.default = "1"; o.rmempty = false;

        o = s.taboption("settings", form.ListValue, "language", "\u042F\u0437\u044B\u043A");
        o.value("ru", "\u0420\u0443\u0441\u0441\u043A\u0438\u0439");
        o.value("en", "English");
        o.default = "ru";

        o = s.taboption("settings", form.Flag, "web_enabled", "\u0412\u0435\u0431-\u043F\u0430\u043D\u0435\u043B\u044C");
        o.default = "1"; o.rmempty = false;

        o = s.taboption("settings", form.Value, "web_port", "\u041F\u043E\u0440\u0442");
        o.datatype = "port"; o.default = "8080";

        return m.render();
    }
});
