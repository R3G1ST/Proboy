"use strict";
"require view";
"require form";
"require fs";
"require uci";

/* ═══ HELPERS ═══ */
function getLang() {
    try { return uci.get("proboy", "main", "language") || "ru"; } catch(e) { return "ru"; }
}

function isRunning(name) {
    try {
        var pid = fs.read("/var/run/proboy/" + name + ".pid");
        if (pid && pid.trim()) {
            fs.exec("/bin/kill", ["-0", pid.trim()]);
            return true;
        }
    } catch(e) {}
    return false;
}

function b(ok) {
    return ok ? '<span style="color:#10b981;font-weight:bold">● Running</span>'
              : '<span style="color:#ef4444;font-weight:bold">● Stopped</span>';
}

function I() {
    var R = {};
    try { var m = fs.read("/proc/meminfo"); if (m) { var x = m.match(/MemTotal:\s+(\d+)/); if (x) R.ram = Math.round(parseInt(x[1])/1024)+" MB"; } } catch(e) {}
    try { var d = fs.exec("/bin/df",["-m","/"]); if (d.stdout) { var p = d.stdout.split("\n")[1].split(/\s+/); R.flash = p[3]+" MB free"; } } catch(e) {}
    try { var c = fs.read("/proc/cpuinfo"); if (c) { var x = c.match(/model name\s*:\s*(.+)/i)||c.match(/Processor\s*:\s*(.+)/i); if (x) R.cpu = x[1].trim(); } } catch(e) {}
    try { R.cores = fs.exec("/bin/nproc").stdout.trim(); } catch(e) { R.cores="1"; }
    try { R.arch = fs.exec("/bin/uname",["-m"]).stdout.trim(); } catch(e) {}
    try { var r = fs.read("/etc/openwrt_release"); if (r) { var d = r.match(/DISTRIB_RELEASE='([^']+)'/); R.os = "OpenWrt " + (d?d[1]:"?"); } } catch(e) {}
    try { var md = fs.read("/tmp/sysinfo/model"); if (md) R.model = md.trim(); } catch(e) {}
    try { R.ver = fs.read("/opt/proboy/VERSION").trim(); } catch(e) {}
    try { var ip = fs.exec("/bin/ip",["-4","addr","show","br-lan"]); if (ip.stdout) { var x = ip.stdout.match(/inet\s+([\d.]+)/); if (x) R.ip = x[1]; } } catch(e) {}
    try { var rt = fs.exec("/bin/ip",["route","show","default"]); if (rt.stdout) { var x = rt.stdout.match(/via\s+([\d.]+)/); if (x) R.gw = x[1]; } } catch(e) {}
    try { var rs = fs.read("/tmp/resolv.conf")||fs.read("/tmp/resolv.conf.d/resolv.conf.auto"); if (rs) { var s=[]; rs.split("\n").forEach(function(l){var m=l.match(/nameserver\s+([\d.]+)/);if(m)s.push(m[1]);}); R.dns=s.join(", "); } } catch(e) {}
    try { var u = fs.read("/proc/uptime"); if (u) { var s=parseFloat(u.split(" ")[0]); R.uptime=Math.floor(s/86400)+"d "+Math.floor((s%86400)/3600)+"h "+Math.floor((s%3600)/60)+"m"; } } catch(e) {}
    return R;
}

/* ═══ GLOBAL ACTIONS ═══ */
window.doAction = function(action) {
    var el = document.getElementById("proboy-r");
    if (el) { el.style.display = "block"; el.textContent = action + "..."; }
    fs.exec("/etc/init.d/proboy", [action]).then(function() {
        setTimeout(function() { window.location.reload(); }, 2000);
    }).catch(function(e) {
        if (el) el.textContent = "Error: " + e.message;
    });
};

window.doPreset = function(key) {
    var P = {
        gamer:{zapret_strategy:"gaming",gamefilter_enabled:"1"},
        max:{zapret_strategy:"aggressive",gamefilter_enabled:"1",youtube_enabled:"1",ipv6_enabled:"1",failover_enabled:"1"},
        min:{zapret_strategy:"general",gamefilter_enabled:"0",youtube_enabled:"0",ipv6_enabled:"0",failover_enabled:"0"},
        stream:{zapret_strategy:"youtube",gamefilter_enabled:"0",youtube_enabled:"1",failover_enabled:"1"},
        free:{zapret_strategy:"aggressive",gamefilter_enabled:"1",youtube_enabled:"1",ipv6_enabled:"1",failover_enabled:"1"}
    };
    var N = {gamer:"\u0413\u0435\u0439\u043C\u0435\u0440",max:"\u041C\u0430\u043A\u0441\u0438\u043C\u0443\u043C",min:"\u041C\u0438\u043D\u0438\u043C\u0443\u0441",stream:"\u0421\u0442\u0440\u0438\u043C\u0438\u043D\u0433",free:"\u0421\u0432\u043E\u0431\u043E\u0434\u0430"};
    if (!confirm("\u041F\u0440\u0438\u043C\u0435\u043D\u0438\u0442\u044C: " + (N[key]||key) + "?")) return;
    uci.load("proboy");
    var s = P[key]; for (var k in s) uci.set("proboy","main",k,s[k]);
    uci.commit("proboy");
    fs.exec("/etc/init.d/proboy",["restart"]);
    alert((N[key]||key) + " applied!");
    window.location.reload();
};

/* ═══ MAIN ═══ */
return view.extend({
    render: function() {
        var m = new form.Map("proboy", "\u041F\u0440\u043E\u0431\u043E\u0439", "Anti-censorship suite \u2014 DPI bypass, gaming, subscriptions");
        m.tabbed = true;
        var info = I();
        var lang = getLang();
        var zapret = isRunning("zapret"), singbox = isRunning("singbox");
        var gf = uci.get("proboy","main","gamefilter_enabled")==="1";
        var dn = uci.get("proboy","main","dns_enabled")==="1";
        var strat = uci.get("proboy","main","zapret_strategy")||"auto";

        /* ─── Dashboard ─── */
        var s = m.section(form.TypedSection, "proboy", "\u041F\u0430\u043D\u0435\u043B\u044C \u0443\u043F\u0440\u0430\u0432\u043B\u0435\u043D\u0438\u044F");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        // Status as form value (works with rawhtml)
        var o = s.option(form.Value, "_s", "\u0421\u0442\u0430\u0442\u0443\u0441 \u0441\u0435\u0440\u0432\u0438\u0441\u043E\u0432");
        o.readonly = true;
        o.cfgvalue = function() {
            return 'Zapret: ' + b(zapret) + ' <code>' + strat + '</code> | sing-box: ' + b(singbox) + ' | Game Filter: ' + b(gf) + ' | DNS: ' + b(dn);
        };

        // System info
        o = s.option(form.Value, "_sys", "\u0421\u0438\u0441\u0442\u0435\u043C\u0430");
        o.readonly = true;
        o.cfgvalue = function() {
            return (info.os||"?") + ' | ' + (info.model||"?") + ' | ' + (info.cpu||"?") + ' (' + info.cores + ') | RAM: ' + (info.ram||"?") + ' | Flash: ' + (info.flash||"?") + ' | v' + (info.ver||"?") + ' | ' + (info.uptime||"?");
        };

        // Control buttons
        o = s.option(form.Value, "_ctrl", "\u0423\u043F\u0440\u0430\u0432\u043B\u0435\u043D\u0438\u0435");
        o.readonly = true;
        o.cfgvalue = function() {
            return '<input type="button" class="cbi-button cbi-button-apply" value="\u0417\u0430\u043F\u0443\u0441\u0442\u0438\u0442\u044C" onclick="doAction(\'start\')" /> <input type="button" class="cbi-button cbi-button-reset" value="\u041E\u0441\u0442\u0430\u043D\u043E\u0432\u0438\u0442\u044C" onclick="doAction(\'stop\')" /> <input type="button" class="cbi-button cbi-button-apply" value="\u041F\u0435\u0440\u0435\u0437\u0430\u043F\u0443\u0441\u0442\u0438\u0442\u044C" onclick="doAction(\'restart\')" /><div id="proboy-r" style="margin-top:8px;display:none;padding:8px;border-radius:4px;background:#e8f5e9"></div>';
        };

        /* ─── Combo Builder ─── */
        s = m.section(form.TypedSection, "proboy", "\u041A\u043E\u043C\u0431\u043E \u0411\u0438\u043B\u0434\u0435\u0440");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        var presets = [
            {k:"gamer",i:"\uD83C\uDFAE",ru:"\u0413\u0435\u0439\u043C\u0435\u0440",en:"Gamer",d:"\u0418\u0433\u0440\u044B"},
            {k:"max",i:"\uD83D\uDE80",ru:"\u041C\u0430\u043A\u0441\u0438\u043C\u0443\u043C",en:"Maximum",d:"\u041C\u0430\u043A\u0441. \u043E\u0431\u0445\u043E\u0434"},
            {k:"min",i:"\uD83D\uDD0B",ru:"\u041C\u0438\u043D\u0438\u043C\u0443\u0441",en:"Minimum",d:"\u041C\u0430\u043B\u043E \u0440\u0435\u0441\u0443\u0440\u0441\u043E\u0432"},
            {k:"stream",i:"\uD83D\uDCFA",ru:"\u0421\u0442\u0440\u0438\u043C\u0438\u043D\u0433",en:"Streaming",d:"YouTube 4K"},
            {k:"free",i:"\uD83C\uDFF4",ru:"\u0421\u0432\u043E\u0431\u043E\u0434\u0430",en:"Freedom",d:"\u041F\u043E\u043B\u043D\u0430\u044F \u0441\u0432\u043E\u0431\u043E\u0434\u0430"}
        ];
        o = s.option(form.Value, "_combo", "\u041F\u0440\u0435\u0441\u0435\u0442\u044B");
        o.readonly = true;
        o.cfgvalue = function() {
            var h = '<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:8px">';
            presets.forEach(function(p) {
                var nm = lang==="ru"?p.ru:p.en;
                h += '<div style="border:1px solid #ddd;border-radius:8px;padding:12px;text-align:center;cursor:pointer" onclick="doPreset(\''+p.k+'\')">';
                h += '<div style="font-size:24px">'+p.i+'</div>';
                h += '<div style="font-weight:bold;font-size:13px">'+nm+'</div>';
                h += '<div style="color:#666;font-size:11px">'+p.d+'</div></div>';
            });
            return h + '</div>';
        };

        /* ─── Zapret ─── */
        s = m.section(form.TypedSection, "proboy", "Zapret (DPI Bypass)");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "zapret_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C Zapret");
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "zapret_strategy", "\u0421\u0442\u0440\u0430\u0442\u0435\u0433\u0438\u044F");
        [["auto","\u0410\u0432\u0442\u043E"],["general","\u041E\u0431\u0449\u0430\u044F"],["general-alt","\u041E\u0431\u0449\u0430\u044F ALT"],["fake-tls-auto","FAKE TLS AUTO"],["fake-tls-auto-alt","FAKE TLS AUTO ALT"],["simple-fake","SIMPLE FAKE"],["discord","Discord"],["youtube","YouTube"],["telegram","Telegram"],["gaming","\u0418\u0433\u0440\u044B"],["fortnite","Fortnite"],["cs2","CS2"],["psn","PlayStation Network"],["steam","Steam"],["epic","Epic Games"],["alt1","ALT 1"],["alt2","ALT 2"],["alt3","ALT 3"],["alt4","ALT 4"],["alt5","ALT 5"],["alt6","ALT 6"],["alt7","ALT 7"],["alt8","ALT 8"],["alt9","ALT 9"],["alt10","ALT 10"],["alt11","ALT 11"],["alt12","ALT 12"],["aggressive","\u0410\u0433\u0440\u0435\u0441\u0441\u0438\u0432\u043D\u0430\u044F"]].forEach(function(x){o.value(x[0],x[1]);});
        o.default = "auto";

        o = s.option(form.Flag, "failover_enabled", "Failover");
        o.default = "1"; o.rmempty = false;

        /* ─── Games ─── */
        s = m.section(form.TypedSection, "proboy", "\u0418\u0433\u0440\u043E\u0432\u043E\u0439 \u0444\u0438\u043B\u044C\u0442\u0440");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "gamefilter_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C Game Filter");
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "gamefilter_mode", "\u0420\u0435\u0436\u0438\u043C");
        o.value("universal", "\u0423\u043D\u0438\u0432\u0435\u0440\u0441\u0430\u043B\u044C\u043D\u044B\u0439 \u2014 \u0432\u0441\u0435 \u0438\u0433\u0440\u044B");
        o.value("custom", "\u041F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044C\u0441\u043A\u0438\u0439");
        o.default = "universal";

        o = s.option(form.Flag, "ps5_enabled", "PS5 \u0410\u0432\u0442\u043E\u043E\u043F\u0440\u0435\u0434\u0435\u043B\u0435\u043D\u0438\u0435");
        o.default = "0"; o.rmempty = false;

        /* ─── Network ─── */
        s = m.section(form.TypedSection, "proboy", "\u0421\u0435\u0442\u044C");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "dns_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C DNS Bypass");
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "dns_provider", "DNS \u041F\u0440\u043E\u0432\u0430\u0439\u0434\u0435\u0440");
        o.value("cloudflare", "Cloudflare (1.1.1.1)");
        o.value("google", "Google (8.8.8.8)");
        o.value("adguard", "AdGuard");
        o.default = "cloudflare";

        o = s.option(form.Flag, "youtube_enabled", "\u041E\u043F\u0442\u0438\u043C\u0438\u0437\u0430\u0442\u043E\u0440 YouTube");
        o.default = "1"; o.rmempty = false;

        o = s.option(form.Flag, "ipv6_enabled", "IPv6 Bypass");
        o.default = "0"; o.rmempty = false;

        o = s.option(form.Value, "_net", "\u0421\u0435\u0442\u0435\u0432\u0430\u044F \u0438\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F");
        o.readonly = true;
        o.cfgvalue = function() {
            return 'LAN: ' + (info.ip||"?") + ' | Gateway: ' + (info.gw||"?") + ' | DNS: ' + (info.dns||"?") + ' | Uptime: ' + (info.uptime||"?");
        };

        /* ─── Subscriptions ─── */
        s = m.section(form.TypedSection, "proboy", "\u041F\u043E\u0434\u043F\u0438\u0441\u043A\u0438");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Value, "subscription_url", "URL \u043F\u043E\u0434\u043F\u0438\u0441\u043A\u0438");
        o.placeholder = "https://...";
        o.rmempty = true;

        o = s.option(form.Value, "_subf", "\u0424\u043E\u0440\u043C\u0430\u0442\u044B");
        o.readonly = true;
        o.cfgvalue = function() {
            return 'hysteria2://, vless://, trojan://, ss://, clash, v2rayN';
        };

        /* ─── Settings ─── */
        s = m.section(form.TypedSection, "proboy", "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438");
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C Proboy");
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "language", "\u042F\u0437\u044B\u043A");
        o.value("ru", "\u0420\u0443\u0441\u0441\u043A\u0438\u0439");
        o.value("en", "English");
        o.default = "ru";

        o = s.option(form.Flag, "web_enabled", "\u0412\u043A\u043B\u044E\u0447\u0438\u0442\u044C \u0432\u0435\u0431-\u043F\u0430\u043D\u0435\u043B\u044C");
        o.default = "1"; o.rmempty = false;

        o = s.option(form.Value, "web_port", "\u041F\u043E\u0440\u0442");
        o.datatype = "port";
        o.default = "8080";

        return m.render();
    }
});
