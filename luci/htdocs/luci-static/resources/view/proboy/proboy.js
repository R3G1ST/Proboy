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

function badge(ok) {
    return ok ? '<span style="color:#10b981;font-weight:bold">● Running</span>'
              : '<span style="color:#ef4444;font-weight:bold">● Stopped</span>';
}

function getInfo() {
    var I = {};
    try { var m = fs.read("/proc/meminfo"); if (m) { var x = m.match(/MemTotal:\s+(\d+)/); if (x) I.ram = Math.round(parseInt(x[1])/1024)+" MB"; } } catch(e) {}
    try { var d = fs.exec("/bin/df",["-m","/"]); if (d.stdout) { var p = d.stdout.split("\n")[1].split(/\s+/); I.flash = p[3]+" MB free"; } } catch(e) {}
    try { var c = fs.read("/proc/cpuinfo"); if (c) { var x = c.match(/model name\s*:\s*(.+)/i)||c.match(/Processor\s*:\s*(.+)/i); if (x) I.cpu = x[1].trim(); } } catch(e) {}
    try { I.cores = fs.exec("/bin/nproc").stdout.trim(); } catch(e) { I.cores="1"; }
    try { I.arch = fs.exec("/bin/uname",["-m"]).stdout.trim(); } catch(e) {}
    try { var r = fs.read("/etc/openwrt_release"); if (r) { var d = r.match(/DISTRIB_RELEASE='([^']+)'/); I.os = "OpenWrt " + (d?d[1]:"?"); } } catch(e) {}
    try { var md = fs.read("/tmp/sysinfo/model"); if (md) I.model = md.trim(); } catch(e) {}
    try { I.ver = fs.read("/opt/proboy/VERSION").trim(); } catch(e) {}
    try { var ip = fs.exec("/bin/ip",["-4","addr","show","br-lan"]); if (ip.stdout) { var x = ip.stdout.match(/inet\s+([\d.]+)/); if (x) I.ip = x[1]; } } catch(e) {}
    try { var rt = fs.exec("/bin/ip",["route","show","default"]); if (rt.stdout) { var x = rt.stdout.match(/via\s+([\d.]+)/); if (x) I.gw = x[1]; } } catch(e) {}
    try { var rs = fs.read("/tmp/resolv.conf")||fs.read("/tmp/resolv.conf.d/resolv.conf.auto"); if (rs) { var s=[]; rs.split("\n").forEach(function(l){var m=l.match(/nameserver\s+([\d.]+)/);if(m)s.push(m[1]);}); I.dns=s.join(", "); } } catch(e) {}
    try { var u = fs.read("/proc/uptime"); if (u) { var s=parseFloat(u.split(" ")[0]); I.uptime=Math.floor(s/86400)+"d "+Math.floor((s%86400)/3600)+"h "+Math.floor((s%3600)/60)+"m"; } } catch(e) {}
    return I;
}

function doAction(action) {
    var el = document.getElementById("proboy-r");
    if (el) { el.style.display = "block"; el.textContent = action + "..."; }
    fs.exec("/etc/init.d/proboy", [action]).then(function() {
        setTimeout(function() { window.location.reload(); }, 2000);
    }).catch(function(e) {
        if (el) el.textContent = "Error: " + e.message;
    });
}

function doPreset(key) {
    var P = {
        gamer:{zapret_strategy:"gaming",gamefilter_enabled:"1"},
        max:{zapret_strategy:"aggressive",gamefilter_enabled:"1",youtube_enabled:"1",ipv6_enabled:"1",failover_enabled:"1"},
        min:{zapret_strategy:"general",gamefilter_enabled:"0",youtube_enabled:"0",ipv6_enabled:"0",failover_enabled:"0"},
        stream:{zapret_strategy:"youtube",gamefilter_enabled:"0",youtube_enabled:"1",failover_enabled:"1"},
        free:{zapret_strategy:"aggressive",gamefilter_enabled:"1",youtube_enabled:"1",ipv6_enabled:"1",failover_enabled:"1"}
    };
    var N = {gamer:"Геймер",max:"Максимум",min:"Минимум",stream:"Стриминг",free:"Свобода"};
    if (!confirm(_("Apply") + ": " + (N[key]||key) + "?")) return;
    uci.load("proboy");
    var s = P[key]; for (var k in s) uci.set("proboy","main",k,s[k]);
    uci.commit("proboy");
    fs.exec("/etc/init.d/proboy",["restart"]);
    alert((N[key]||key) + " " + _("applied") + "!");
    window.location.reload();
}

/* ═══ MAIN ═══ */
return view.extend({
    render: function() {
        var m = new form.Map("proboy", _("Proboy"), _("Anti-censorship suite — DPI bypass, gaming, subscriptions"));
        m.tabbed = true;
        var I = getInfo();
        var lang = getLang();

        /* ─── Dashboard ─── */
        var s = m.section(form.TypedSection, "proboy", _("Dashboard"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        var o = s.option(form.DummyValue, "_dash", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            var z = isRunning("zapret"), sb = isRunning("singbox");
            var gf = uci.get("proboy","main","gamefilter_enabled")==="1";
            var dn = uci.get("proboy","main","dns_enabled")==="1";
            var st = uci.get("proboy","main","zapret_strategy")||"auto";
            var h = '<h3>'+_('Status')+'</h3><table style="width:100%"><tr><td style="padding:6px"><b>Zapret</b></td><td>'+badge(z)+' — <code>'+st+'</code></td></tr>';
            h += '<tr><td style="padding:6px"><b>sing-box</b></td><td>'+badge(sb)+'</td></tr>';
            h += '<tr><td style="padding:6px"><b>Game Filter</b></td><td>'+badge(gf)+'</td></tr>';
            h += '<tr><td style="padding:6px"><b>DNS Bypass</b></td><td>'+badge(dn)+'</td></tr></table>';
            h += '<h3>'+_('System')+'</h3><table style="width:100%">';
            h += '<tr><td style="padding:4px"><b>OS</b></td><td>'+(I.os||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Router</b></td><td>'+(I.model||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>CPU</b></td><td>'+(I.cpu||"?")+' ('+I.cores+' cores)</td></tr>';
            h += '<tr><td style="padding:4px"><b>RAM</b></td><td>'+(I.ram||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Flash</b></td><td>'+(I.flash||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Arch</b></td><td>'+(I.arch||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Version</b></td><td>'+(I.ver||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Uptime</b></td><td>'+(I.uptime||"?")+'</td></tr></table>';
            h += '<h3>'+_('Control')+'</h3>';
            h += '<input type="button" class="cbi-button cbi-button-apply" value="'+_('Start')+'" onclick="doAction(\'start\')" /> ';
            h += '<input type="button" class="cbi-button cbi-button-reset" value="'+_('Stop')+'" onclick="doAction(\'stop\')" /> ';
            h += '<input type="button" class="cbi-button cbi-button-apply" value="'+_('Restart')+'" onclick="doAction(\'restart\')" />';
            h += '<div id="proboy-r" style="margin-top:8px;display:none;padding:8px;border-radius:4px;background:#e8f5e9"></div>';
            return h;
        };

        /* ─── Combo Builder ─── */
        s = m.section(form.TypedSection, "proboy", _("Combo Builder"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        var presets = [
            {k:"gamer",i:"\uD83C\uDFAE",ru:"\u0413\u0435\u0439\u043C\u0435\u0440",en:"Gamer",d:"\u041E\u043F\u0442\u0438\u043C\u0438\u0437\u0430\u0446\u0438\u044F \u0434\u043B\u044F \u0438\u0433\u0440"},
            {k:"max",i:"\uD83D\uDE80",ru:"\u041C\u0430\u043A\u0441\u0438\u043C\u0443\u043C",en:"Maximum",d:"\u041C\u0430\u043A\u0441\u0438\u043C\u0430\u043B\u044C\u043D\u044B\u0439 \u043E\u0431\u0445\u043E\u0434"},
            {k:"min",i:"\uD83D\uDD0B",ru:"\u041C\u0438\u043D\u0438\u043C\u0443\u043C",en:"Minimum",d:"\u041C\u0430\u043B\u043E \u0440\u0435\u0441\u0443\u0440\u0441\u043E\u0432"},
            {k:"stream",i:"\uD83D\uDCFA",ru:"\u0421\u0442\u0440\u0438\u043C\u0438\u043D\u0433",en:"Streaming",d:"YouTube 4K"},
            {k:"free",i:"\uD83C\uDFF4",ru:"\u0421\u0432\u043E\u0431\u043E\u0434\u0430",en:"Freedom",d:"\u041F\u043E\u043B\u043D\u0430\u044F \u0441\u0432\u043E\u0431\u043E\u0434\u0430"}
        ];

        o = s.option(form.DummyValue, "_combo", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            var h = '<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:10px;margin-top:8px">';
            presets.forEach(function(p) {
                var nm = lang==="ru"?p.ru:p.en;
                h += '<div style="border:1px solid #ddd;border-radius:8px;padding:14px;text-align:center;cursor:pointer" onclick="doPreset(\''+p.k+'\')">';
                h += '<div style="font-size:28px">'+p.i+'</div>';
                h += '<div style="font-weight:bold;margin:4px 0">'+nm+'</div>';
                h += '<div style="color:#666;font-size:11px">'+p.d+'</div></div>';
            });
            return h + '</div>';
        };

        /* ─── Zapret ─── */
        s = m.section(form.TypedSection, "proboy", _("Zapret (DPI Bypass)"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "zapret_enabled", _("Enable Zapret"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "zapret_strategy", _("Strategy"));
        [["auto",_("Auto")],["general",_("General")],["general-alt",_("General ALT")],["fake-tls-auto","FAKE TLS AUTO"],["fake-tls-auto-alt","FAKE TLS AUTO ALT"],["simple-fake","SIMPLE FAKE"],["discord","Discord"],["youtube","YouTube"],["telegram","Telegram"],["gaming",_("Gaming")],["fortnite","Fortnite"],["cs2","CS2"],["psn","PlayStation Network"],["steam","Steam"],["epic","Epic Games"],["alt1","ALT 1"],["alt2","ALT 2"],["alt3","ALT 3"],["alt4","ALT 4"],["alt5","ALT 5"],["alt6","ALT 6"],["alt7","ALT 7"],["alt8","ALT 8"],["alt9","ALT 9"],["alt10","ALT 10"],["alt11","ALT 11"],["alt12","ALT 12"],["aggressive",_("Aggressive")]].forEach(function(s2){o.value(s2[0],s2[1]);});
        o.default = "auto";

        o = s.option(form.Flag, "failover_enabled", _("Failover"));
        o.default = "1"; o.rmempty = false;

        /* ─── Games ─── */
        s = m.section(form.TypedSection, "proboy", _("Game Filter"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "gamefilter_enabled", _("Enable Game Filter"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "gamefilter_mode", _("Mode"));
        o.value("universal", _("Universal — all games"));
        o.value("custom", _("Custom"));
        o.default = "universal";

        o = s.option(form.Flag, "ps5_enabled", _("PS5 Auto-detect"));
        o.default = "0"; o.rmempty = false;

        o = s.option(form.DummyValue, "_gp", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            return '<div style="color:#666;margin-top:4px"><b>'+_('Platforms')+':</b> Steam, Epic, Riot, Blizzard, EA, PlayStation, Xbox, Nintendo</div>';
        };

        /* ─── Network ─── */
        s = m.section(form.TypedSection, "proboy", _("Network"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "dns_enabled", _("Enable DNS Bypass"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "dns_provider", _("DNS Provider"));
        o.value("cloudflare", "Cloudflare (1.1.1.1)");
        o.value("google", "Google (8.8.8.8)");
        o.value("adguard", "AdGuard");
        o.default = "cloudflare";

        o = s.option(form.Flag, "youtube_enabled", _("YouTube Optimizer"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.Flag, "ipv6_enabled", _("IPv6 Bypass"));
        o.default = "0"; o.rmempty = false;

        o = s.option(form.DummyValue, "_ni", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            var h = '<h3>'+_('Network Info')+'</h3><table style="width:100%">';
            h += '<tr><td style="padding:4px"><b>LAN IP</b></td><td>'+(I.ip||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Gateway</b></td><td>'+(I.gw||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>DNS</b></td><td>'+(I.dns||"?")+'</td></tr>';
            h += '<tr><td style="padding:4px"><b>Uptime</b></td><td>'+(I.uptime||"?")+'</td></tr></table>';
            return h;
        };

        /* ─── Subscriptions ─── */
        s = m.section(form.TypedSection, "proboy", _("Subscriptions"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Value, "subscription_url", _("Subscription URL"));
        o.placeholder = "https://...";
        o.rmempty = true;

        o = s.option(form.DummyValue, "_si", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            return '<div style="color:#666;margin-top:4px"><b>'+_('Formats')+':</b> hysteria2://, vless://, trojan://, ss://, clash, v2rayN</div>';
        };

        /* ─── Settings ─── */
        s = m.section(form.TypedSection, "proboy", _("Settings"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "enabled", _("Enable Proboy"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "language", _("Language"));
        o.value("ru", "\u0420\u0443\u0441\u0441\u043A\u0438\u0439");
        o.value("en", "English");
        o.default = "ru";

        o = s.option(form.Flag, "web_enabled", _("Enable Web Panel"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.Value, "web_port", _("Web Panel Port"));
        o.datatype = "port";
        o.default = "8080";

        return m.render();
    }
});
