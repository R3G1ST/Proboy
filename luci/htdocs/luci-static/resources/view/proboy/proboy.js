"use strict";
"require view";
"require form";
"require fs";
"require uci";
"require baseclass";

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

function statusBadge(ok) {
    return ok
        ? E("span", { "style": "color:#10b981;font-weight:bold" }, "● Running")
        : E("span", { "style": "color:#ef4444;font-weight:bold" }, "● Stopped");
}

function getSystemInfo() {
    var info = {};
    try { var m = fs.read("/proc/meminfo"); if (m) { var x = m.match(/MemTotal:\s+(\d+)/); if (x) info.ram = Math.round(parseInt(x[1])/1024)+" MB"; } } catch(e) { info.ram="?"; }
    try { var df = fs.exec("/bin/df",["-m","/"]); if (df.stdout) { var p = df.stdout.split("\n")[1].split(/\s+/); info.flash = p[3]+" MB free"; } } catch(e) { info.flash="?"; }
    try { var c = fs.read("/proc/cpuinfo"); if (c) { var x = c.match(/model name\s*:\s*(.+)/i) || c.match(/Processor\s*:\s*(.+)/i); if (x) info.cpu = x[1].trim(); } } catch(e) { info.cpu="?"; }
    try { info.cores = fs.exec("/bin/nproc").stdout.trim(); } catch(e) { info.cores="1"; }
    try { info.arch = fs.exec("/bin/uname",["-m"]).stdout.trim(); } catch(e) { info.arch="?"; }
    try { var r = fs.read("/etc/openwrt_release"); if (r) { var d = r.match(/DISTRIB_RELEASE='([^']+)'/); info.os = "OpenWrt " + (d?d[1]:"?"); } } catch(e) { info.os="?"; }
    try { var md = fs.read("/tmp/sysinfo/model"); if (md) info.model = md.trim(); } catch(e) { info.model="?"; }
    try { info.version = fs.read("/opt/proboy/VERSION").trim(); } catch(e) { info.version="?"; }
    try { var ip = fs.exec("/bin/ip",["-4","addr","show","br-lan"]); if (ip.stdout) { var x = ip.stdout.match(/inet\s+([\d.]+)/); if (x) info.ip = x[1]; } } catch(e) { info.ip="?"; }
    try { var rt = fs.exec("/bin/ip",["route","show","default"]); if (rt.stdout) { var x = rt.stdout.match(/via\s+([\d.]+)/); if (x) info.gateway = x[1]; } } catch(e) { info.gateway="?"; }
    try { var rs = fs.read("/tmp/resolv.conf") || fs.read("/tmp/resolv.conf.d/resolv.conf.auto"); if (rs) { var s = []; rs.split("\n").forEach(function(l){ var m=l.match(/nameserver\s+([\d.]+)/); if(m) s.push(m[1]); }); info.dns = s.join(", "); } } catch(e) { info.dns="?"; }
    try { var u = fs.read("/proc/uptime"); if (u) { var s=parseFloat(u.split(" ")[0]); info.uptime=Math.floor(s/86400)+"d "+Math.floor((s%86400)/3600)+"h "+Math.floor((s%3600)/60)+"m"; } } catch(e) { info.uptime="?"; }
    return info;
}

/* ═══ CONSTANTS ═══ */
var PRESETS = [
    { key:"gamer", icon:"🎮", ru:"Геймер", en:"Gamer", d_ru:"Оптимизация для игр", d_en:"Gaming", s:{zapret_strategy:"gaming",gamefilter_enabled:"1",dns_provider:"cloudflare"}},
    { key:"max", icon:"🚀", ru:"Максимум", en:"Maximum", d_ru:"Максимальный обход", d_en:"Max bypass", s:{zapret_strategy:"aggressive",gamefilter_enabled:"1",youtube_enabled:"1",ipv6_enabled:"1",failover_enabled:"1"}},
    { key:"min", icon:"🔋", ru:"Минимум", en:"Minimum", d_ru:"Мало ресурсов", d_en:"Low resources", s:{zapret_strategy:"general",gamefilter_enabled:"0",youtube_enabled:"0",ipv6_enabled:"0",failover_enabled:"0"}},
    { key:"stream", icon:"📺", ru:"Стриминг", en:"Streaming", d_ru:"YouTube 4K", d_en:"YouTube 4K", s:{zapret_strategy:"youtube",gamefilter_enabled:"0",youtube_enabled:"1",failover_enabled:"1"}},
    { key:"free", icon:"🏴", ru:"Свобода", en:"Freedom", d_ru:"Полная свобода", d_en:"Full freedom", s:{zapret_strategy:"aggressive",gamefilter_enabled:"1",youtube_enabled:"1",ipv6_enabled:"1",failover_enabled:"1"}}
];

var STRATEGIES = [
    ["auto",_("Auto")],["general",_("General")],["general-alt",_("General ALT")],
    ["fake-tls-auto","FAKE TLS AUTO"],["fake-tls-auto-alt","FAKE TLS AUTO ALT"],
    ["simple-fake","SIMPLE FAKE"],["discord","Discord"],["youtube","YouTube"],
    ["telegram","Telegram"],["gaming",_("Gaming")],["fortnite","Fortnite"],
    ["cs2","CS2"],["psn","PlayStation Network"],["steam","Steam"],["epic","Epic Games"],
    ["alt1","ALT 1"],["alt2","ALT 2"],["alt3","ALT 3"],["alt4","ALT 4"],
    ["alt5","ALT 5"],["alt6","ALT 6"],["alt7","ALT 7"],["alt8","ALT 8"],
    ["alt9","ALT 9"],["alt10","ALT 10"],["alt11","ALT 11"],["alt12","ALT 12"],
    ["aggressive",_("Aggressive")]
];

/* ═══ DASHBOARD TAB ═══ */
var DashboardTab = {
    render: function(info) {
        var lang = getLang();
        var zapret = isRunning("zapret"), singbox = isRunning("singbox");
        var gf = uci.get("proboy","main","gamefilter_enabled") === "1";
        var dns = uci.get("proboy","main","dns_enabled") === "1";
        var strat = uci.get("proboy","main","zapret_strategy") || "auto";

        var el = E("div", {});

        // Status
        el.appendChild(E("h3", {}, _("Status")));
        var st = E("table", { "style": "width:100%;border-collapse:collapse" });
        var rows = [
            ["Zapret", statusBadge(zapret), " — ", E("code", {}, strat)],
            ["sing-box", statusBadge(singbox)],
            ["Game Filter", statusBadge(gf)],
            ["DNS Bypass", statusBadge(dns)]
        ];
        rows.forEach(function(r) {
            var tr = E("tr", {});
            tr.appendChild(E("td", { "style": "padding:6px;font-weight:bold" }, r[0]));
            var td = E("td", { "style": "padding:6px" });
            r.slice(1).forEach(function(c) { td.appendChild(typeof c === "string" ? c : c); });
            tr.appendChild(td);
            st.appendChild(tr);
        });
        el.appendChild(st);

        // System
        el.appendChild(E("h3", {}, _("System")));
        var sys = E("table", { "style": "width:100%;border-collapse:collapse" });
        [["OS", info.os],["Router", info.model],["CPU", info.cpu+" ("+info.cores+" cores)"],["RAM", info.ram],["Flash", info.flash],["Arch", info.arch],["Version", info.version],["Uptime", info.uptime]].forEach(function(r) {
            var tr = E("tr", {});
            tr.appendChild(E("td", { "style": "padding:6px;font-weight:bold" }, r[0]));
            tr.appendChild(E("td", { "style": "padding:6px" }, r[1]));
            sys.appendChild(tr);
        });
        el.appendChild(sys);

        // Control
        el.appendChild(E("h3", {}, _("Control")));
        var btns = E("div", { "style": "margin-top:8px" });
        var startBtn = E("input", { "type": "button", "class": "cbi-button cbi-button-apply", "value": _("Start"), "onclick": function() { dashboardAction("start"); } });
        var stopBtn = E("input", { "type": "button", "class": "cbi-button cbi-button-reset", "value": _("Stop"), "onclick": function() { dashboardAction("stop"); } });
        var restartBtn = E("input", { "type": "button", "class": "cbi-button cbi-button-apply", "value": _("Restart"), "onclick": function() { dashboardAction("restart"); } });
        btns.appendChild(startBtn);
        btns.appendChild(E("span", {}, " "));
        btns.appendChild(stopBtn);
        btns.appendChild(E("span", {}, " "));
        btns.appendChild(restartBtn);
        el.appendChild(btns);

        var result = E("div", { "id": "proboy-result", "style": "margin-top:8px;display:none;padding:8px;border-radius:4px;background:#e8f5e9" });
        el.appendChild(result);

        return el;
    }
};

function dashboardAction(action) {
    var el = document.getElementById("proboy-result");
    if (el) { el.style.display = "block"; el.textContent = action + "..."; }
    try {
        fs.exec("/etc/init.d/proboy", [action]);
        setTimeout(function() { window.location.reload(); }, 2000);
    } catch(e) {
        if (el) el.textContent = "Error: " + e.message;
    }
}

/* ═══ COMBO TAB ═══ */
function applyPreset(key) {
    var names = {gamer:"Геймер",max:"Максимум",min:"Минимум",stream:"Стриминг",free:"Свобода"};
    var preset = null;
    PRESETS.forEach(function(p) { if (p.key === key) preset = p; });
    if (!preset) return;
    if (!confirm(_("Apply") + ": " + (names[key]||key) + "?")) return;
    uci.load("proboy");
    for (var k in preset.s) uci.set("proboy", "main", k, preset.s[k]);
    uci.commit("proboy");
    try { fs.exec("/etc/init.d/proboy", ["restart"]); } catch(e) {}
    alert((names[key]||key) + " " + _("applied") + "!");
    window.location.reload();
}

var ComboTab = {
    render: function() {
        var lang = getLang();
        var el = E("div", { "style": "display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:10px;margin-top:8px" });
        PRESETS.forEach(function(p) {
            var card = E("div", {
                "style": "border:1px solid #ddd;border-radius:8px;padding:14px;text-align:center;cursor:pointer",
                "onclick": function() { applyPreset(p.key); }
            });
            card.appendChild(E("div", { "style": "font-size:28px" }, p.icon));
            card.appendChild(E("div", { "style": "font-weight:bold;margin:4px 0" }, p[lang] || p.en));
            card.appendChild(E("div", { "style": "color:#666;font-size:11px" }, p["d_"+lang] || p.d_en));
            el.appendChild(card);
        });
        return el;
    }
};

/* ═══ MAIN ═══ */
return view.extend({
    render: function() {
        var m = new form.Map("proboy", _("Proboy"), _("Anti-censorship suite — DPI bypass, gaming, subscriptions"));
        m.tabbed = true;
        var info = getSystemInfo();

        /* ─── Dashboard ─── */
        var s = m.section(form.TypedSection, "proboy", _("Dashboard"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        var o = s.option(form.DummyValue, "_dash", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            // Create container and append rendered content
            var container = document.createElement("div");
            container.appendChild(DashboardTab.render(info));
            return container.innerHTML;
        };

        /* ─── Combo Builder ─── */
        s = m.section(form.TypedSection, "proboy", _("Combo Builder"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.DummyValue, "_combo", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            var container = document.createElement("div");
            container.appendChild(ComboTab.render());
            return container.innerHTML;
        };

        /* ─── Zapret ─── */
        s = m.section(form.TypedSection, "proboy", _("Zapret (DPI Bypass)"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "zapret_enabled", _("Enable Zapret"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "zapret_strategy", _("Strategy"));
        STRATEGIES.forEach(function(st) { o.value(st[0], st[1]); });
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

        o = s.option(form.DummyValue, "_net", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            var h = '<h3>' + _('Network Info') + '</h3><table style="width:100%">';
            h += '<tr><td style="padding:4px"><b>LAN IP</b></td><td>' + (info.ip||"?") + '</td></tr>';
            h += '<tr><td style="padding:4px"><b>Gateway</b></td><td>' + (info.gateway||"?") + '</td></tr>';
            h += '<tr><td style="padding:4px"><b>DNS</b></td><td>' + (info.dns||"?") + '</td></tr>';
            h += '<tr><td style="padding:4px"><b>Uptime</b></td><td>' + (info.uptime||"?") + '</td></tr></table>';
            return h;
        };

        /* ─── Subscriptions ─── */
        s = m.section(form.TypedSection, "proboy", _("Subscriptions"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Value, "subscription_url", _("Subscription URL"));
        o.placeholder = "https://...";
        o.rmempty = true;

        o = s.option(form.DummyValue, "_subinfo", "");
        o.rawhtml = true;
        o.cfgvalue = function() {
            return '<div style="color:#666;margin-top:4px"><b>' + _('Formats') + ':</b> hysteria2://, vless://, trojan://, ss://, clash, v2rayN</div>';
        };

        /* ─── Settings ─── */
        s = m.section(form.TypedSection, "proboy", _("Settings"));
        s.anonymous = true; s.addremove = false;
        s.cfgsections = function() { return ["main"]; };

        o = s.option(form.Flag, "enabled", _("Enable Proboy"));
        o.default = "1"; o.rmempty = false;

        o = s.option(form.ListValue, "language", _("Language"));
        o.value("ru", "Русский");
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
