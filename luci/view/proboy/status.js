'use strict';
'require form';
'require rpc';
'require view';

var callStatus = rpc.declare({
    object: 'luci.proboy',
    method: 'status',
    expect: { '': {} }
});

var callStart = rpc.declare({
    object: 'luci.proboy',
    method: 'start',
    expect: { '': {} }
});

var callStop = rpc.declare({
    object: 'luci.proboy',
    method: 'stop',
    expect: { '': {} }
});

var callRestart = rpc.declare({
    object: 'luci.proboy',
    method: 'restart',
    expect: { '': {} }
});

return view.extend({
    load: function() {
        return L.resolveDefault(callStatus, {});
    },

    render: function(data) {
        var status, o;

        var m = new form.Map('proboy', _('Proboy'),
            _('Anti-censorship suite for OpenWrt — DPI bypass, gaming, subscriptions'));

        var s = m.section(form.TypedSection, 'proboy', _('Status'));
        s.anonymous = true;
        s.readonly = true;

        o = s.option(form.Value, '_status', _('Service Status'));
        o.readonly = true;
        o.rmempty = false;

        o = s.option(form.Value, '_zapret', _('Zapret (DPI Bypass)'));
        o.readonly = true;
        o.rmempty = false;

        o = s.option(form.Value, '_singbox', _('sing-box (Proxy)'));
        o.readonly = true;
        o.rmempty = false;

        o = s.option(form.Value, '_gamefilter', _('Game Filter'));
        o.readonly = true;
        o.rmempty = false;

        o = s.option(form.Value, '_dns', _('DNS Bypass'));
        o.readonly = true;
        o.rmempty = false;

        // Control buttons
        var s2 = m.section(form.NamedSection, '_actions', 'actions', _('Actions'));
        s2.anonymous = true;

        o = s2.option(form.Button, '_start', _('Start'));
        o.inputstyle = 'apply';
        o.onclick = function() {
            return callStart.then(function() {
                window.setTimeout(function() { window.location.reload(); }, 2000);
            });
        };

        o = s2.option(form.Button, '_stop', _('Stop'));
        o.inputstyle = 'reset';
        o.onclick = function() {
            return callStop.then(function() {
                window.setTimeout(function() { window.location.reload(); }, 2000);
            });
        };

        o = s2.option(form.Button, '_restart', _('Restart'));
        o.inputstyle = 'apply';
        o.onclick = function() {
            return callRestart.then(function() {
                window.setTimeout(function() { window.location.reload(); }, 2000);
            });
        };

        // Web panel link
        var s3 = m.section(form.NamedSection, '_link', 'link', _('Web Panel'));
        s3.anonymous = true;

        o = s3.option(form.Button, '_open', _('Open Web Panel'));
        o.inputstyle = 'apply';
        o.onclick = function() {
            window.open('http://' + window.location.hostname + ':8080/', '_blank');
        };

        return m.render();
    },

    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});
