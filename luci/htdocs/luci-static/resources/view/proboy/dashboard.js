"use strict";
"require form";
"require fs";
"require uci";

function statusBadge(ok) {
    return ok
        ? E("span", { "style": "color:#10b981;font-weight:bold" }, "● Running")
        : E("span", { "style": "color:#ef4444;font-weight:bold" }, "● Stopped");
}

function getPid(name) {
    try {
        var pid = fs.read("/var/run/proboy/" + name + ".pid");
        if (pid && pid.trim()) return pid.trim();
    } catch(e) {}
    return null;
}

function isRunning(name) {
    var pid = getPid(name);
    if (!pid) return false;
    try {
        fs.exec("/bin/kill", ["-0", pid]);
        return true;
    } catch(e) { return false; }
}

function getSystemInfo() {
    var info = {};
    try {
        var m = fs.read("/proc/meminfo");
        if (m) {
            var match = m.match(/MemTotal:\s+(\d+)/);
            if (match) info.ram = Math.round(parseInt(match[1]) / 1024) + " MB";
        }
    } catch(e) { info.ram = "?"; }

    try {
        var df = fs.exec("/bin/df", ["-m", "/"]);
        if (df && df.stdout) {
            var lines = df.stdout.split("\n");
            if (lines.length > 1) {
                var parts = lines[1].split(/\s+/);
                info.flash = parts[3] + " MB free";
            }
        }
    } catch(e) { info.flash = "?"; }

    try {
        var cpuinfo = fs.read("/proc/cpuinfo");
        if (cpuinfo) {
            var match = cpuinfo.match(/model name\s*:\s*(.+)/i) || cpuinfo.match(/Processor\s*:\s*(.+)/i);
            if (match) info.cpu = match[1].trim();
        }
    } catch(e) {}

    try {
        var nproc = fs.exec("/bin/nproc");
        if (nproc && nproc.stdout) info.cores = nproc.stdout.trim();
    } catch(e) { info.cores = "1"; }

    try {
        info.arch = fs.exec("/bin/uname", ["-m"]).stdout.trim();
    } catch(e) { info.arch = "?"; }

    try {
        var os = fs.read("/etc/openwrt_release");
        if (os) {
            var d = os.match(/DISTRIB_RELEASE='([^']+)'/);
            var t = os.match(/DISTRIB_TARGET='([^']+)'/);
            info.os = "OpenWrt " + (d ? d[1] : "?");
            info.target = t ? t[1] : "";
        }
    } catch(e) { info.os = "?"; }

    try {
        var model = fs.read("/tmp/sysinfo/model");
        if (model) info.model = model.trim();
    } catch(e) {}

    var ver = "?";
    try { ver = fs.read("/opt/proboy/VERSION").trim(); } catch(e) {}
    info.version = ver;

    return info;
}

return {
    createContent: function(s) {
        var info = getSystemInfo();

        // Status info
        var o = s.option(form.DummyValue, "_status", _("Service Status"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            var zapret = isRunning("zapret");
            var singbox = isRunning("singbox");
            var gf = uci.get("proboy", "main", "gamefilter_enabled") === "1";
            var dns = uci.get("proboy", "main", "dns_enabled") === "1";
            var strat = uci.get("proboy", "main", "zapret_strategy") || "auto";

            var html = '<table style="width:100%;border-collapse:collapse">';
            html += '<tr><td style="padding:6px"><b>Zapret</b></td><td>' + statusBadge(zapret) + ' — <code>' + strat + '</code></td></tr>';
            html += '<tr><td style="padding:6px"><b>sing-box</b></td><td>' + statusBadge(singbox) + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Game Filter</b></td><td>' + statusBadge(gf) + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>DNS Bypass</b></td><td>' + statusBadge(dns) + '</td></tr>';
            html += '</table>';
            return html;
        };

        // System info
        o = s.option(form.DummyValue, "_system", _("System Info"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            var html = '<table style="width:100%;border-collapse:collapse">';
            html += '<tr><td style="padding:6px"><b>OS</b></td><td>' + (info.os || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Router</b></td><td>' + (info.model || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>CPU</b></td><td>' + (info.cpu || "?") + ' (' + (info.cores || "?") + ' cores)</td></tr>';
            html += '<tr><td style="padding:6px"><b>RAM</b></td><td>' + (info.ram || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Flash</b></td><td>' + (info.flash || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Arch</b></td><td>' + (info.arch || "?") + '</td></tr>';
            html += '<tr><td style="padding:6px"><b>Version</b></td><td>' + (info.version || "?") + '</td></tr>';
            html += '</table>';
            return html;
        };

        // Control buttons
        o = s.option(form.DummyValue, "_control", _("Control"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            var html = '<div style="margin-top:8px">';
            html += '<input type="button" class="cbi-button cbi-button-apply" value="' + _('Start') + '" onclick="proboyAction(\'start\')" /> ';
            html += '<input type="button" class="cbi-button cbi-button-reset" value="' + _('Stop') + '" onclick="proboyAction(\'stop\')" /> ';
            html += '<input type="button" class="cbi-button cbi-button-apply" value="' + _('Restart') + '" onclick="proboyAction(\'restart\')" />';
            html += '<div id="proboy-result" style="margin-top:8px;display:none;padding:8px;border-radius:4px;background:#e8f5e9"></div>';
            html += '</div>';
            return html;
        };

        return null;
    }
};
