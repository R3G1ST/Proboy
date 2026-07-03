'use strict';
'require form';
'require rpc';
'require view';

var callStatus = rpc.declare({
    object: 'luci.proboy',
    method: 'status',
    expect: {}
});

var callStart = rpc.declare({
    object: 'luci.proboy',
    method: 'start',
    expect: {}
});

var callStop = rpc.declare({
    object: 'luci.proboy',
    method: 'stop',
    expect: {}
});

var callRestart = rpc.declare({
    object: 'luci.proboy',
    method: 'restart',
    expect: {}
});

var callUpdate = rpc.declare({
    object: 'luci.proboy',
    method: 'update',
    expect: {}
});

function statusBadge(ok) {
    return ok
        ? '<span style="color:#10b981;font-weight:bold">● Running</span>'
        : '<span style="color:#ef4444;font-weight:bold">● Stopped</span>';
}

return view.extend({
    load: function() {
        return L.resolveDefault(callStatus, {});
    },

    render: function(data) {
        var running = data.running || false;
        var zapret = data.zapret || false;
        var singbox = data.singbox || false;
        var gamefilter = data.gamefilter || false;
        var dns = data.dns || false;
        var strategy = data.strategy || 'auto';
        var dns_provider = data.dns_provider || 'cloudflare';
        var version = data.version || 'unknown';

        var html = '<div class="cbi-section">';

        // Status cards
        html += '<h2>' + _('Service Status') + '</h2>';
        html += '<div class="cbi-section-node">';

        html += '<table class="cbi-section-table" style="width:100%">';
        html += '<tr><td style="width:200px"><b>Proboy</b></td><td>' + statusBadge(running) + '</td></tr>';
        html += '<tr><td><b>Zapret (DPI Bypass)</b></td><td>' + statusBadge(zapret) + ' — Strategy: <code>' + strategy + '</code></td></tr>';
        html += '<tr><td><b>sing-box (Proxy)</b></td><td>' + statusBadge(singbox) + '</td></tr>';
        html += '<tr><td><b>Game Filter</b></td><td>' + statusBadge(gamefilter) + '</td></tr>';
        html += '<tr><td><b>DNS Bypass</b></td><td>' + statusBadge(dns) + ' — Provider: <code>' + dns_provider + '</code></td></tr>';
        html += '</table>';

        html += '</div></div>';

        // Control buttons
        html += '<div class="cbi-section">';
        html += '<h2>' + _('Control') + '</h2>';
        html += '<div class="cbi-section-node">';

        html += '<input type="button" class="cbi-button cbi-button-apply" value="' + _('Start All') + '" onclick="handleProboyAction(\'start\')" /> ';
        html += '<input type="button" class="cbi-button cbi-button-reset" value="' + _('Stop All') + '" onclick="handleProboyAction(\'stop\')" /> ';
        html += '<input type="button" class="cbi-button cbi-button-apply" value="' + _('Restart All') + '" onclick="handleProboyAction(\'restart\')" /> ';
        html += '<input type="button" class="cbi-button cbi-button-apply" value="' + _('Check Update') + '" onclick="handleProboyAction(\'update\')" />';

        html += '<br /><br /><div id="proboy-action-result" style="display:none;padding:8px;border-radius:4px;margin-top:8px;"></div>';

        html += '</div></div>';

        // Quick info
        html += '<div class="cbi-section">';
        html += '<h2>' + _('Quick Info') + '</h2>';
        html += '<div class="cbi-section-node">';
        html += '<table class="cbi-section-table" style="width:100%">';
        html += '<tr><td>' + _('Version') + '</td><td><code>' + version + '</code></td></tr>';
        html += '<tr><td>' + _('Web Panel') + '</td><td><a href="http://' + window.location.hostname + ':8080/" target="_blank">http://' + window.location.hostname + ':8080/</a></td></tr>';
        html += '</table>';
        html += '</div></div>';

        // JavaScript for actions
        html += '<script>';
        html += 'function handleProboyAction(action) {';
        html += '  var el = document.getElementById("proboy-action-result");';
        html += '  el.style.display = "block";';
        html += '  el.style.background = "#1e293b";';
        html += '  el.style.color = "#e2e8f0";';
        html += '  el.innerHTML = "Executing ' + _('") + ' + action + "' + _('...") + '";';
        html += '  callProboyRPC(action).then(function(d) {';
        html += '    el.innerHTML = "' + _('Done!') + ' Reloading...";';
        html += '    setTimeout(function() { window.location.reload(); }, 2000);';
        html += '  }).catch(function(e) {';
        html += '    el.style.background = "#7f1d1d";';
        html += '    el.innerHTML = "Error: " + e.message;';
        html += '  });';
        html += '}';
        html += '</script>';

        return L.dom.create('div', { 'class': 'cbi-section' }, L.dom.create('div', {}, E('div', {}, L.dom.parse(html))));
    },

    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});

function callProboyRPC(method) {
    return new Promise(function(resolve, reject) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '/cgi-bin/luci-proboy', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onload = function() {
            if (xhr.status === 200) {
                try { resolve(JSON.parse(xhr.responseText)); }
                catch(e) { resolve({ ok: true }); }
            } else {
                reject(new Error('HTTP ' + xhr.status));
            }
        };
        xhr.onerror = function() { reject(new Error('Network error')); };
        xhr.send(JSON.stringify({ method: method }));
    });
}
