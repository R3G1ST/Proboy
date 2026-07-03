'use strict';
'require form';
'require rpc';
'require view';

var callSave = rpc.declare({
    object: 'luci.proboy',
    method: 'save',
    expect: { '': {} }
});

return view.extend({
    render: function() {
        var m = new form.Map('proboy', _('Proboy Settings'),
            _('Configure Proboy anti-censorship suite'));

        var s = m.section(form.TypedSection, 'proboy', _('General'));
        s.anonymous = true;

        o = s.option(form.ListValue, 'enabled', _('Enable Proboy'));
        o.value('1', _('Enabled'));
        o.value('0', _('Disabled'));
        o.default = '1';

        o = s.option(form.ListValue, 'zapret_strategy', _('Zapret Strategy'));
        o.value('auto', _('Auto (recommended)'));
        o.value('general', _('General'));
        o.value('aggressive', _('Aggressive'));
        o.value('gaming', _('Gaming'));
        o.value('youtube', _('YouTube'));
        o.value('discord', _('Discord'));
        o.value('telegram', _('Telegram'));
        o.default = 'auto';

        o = s.option(form.ListValue, 'dns_provider', _('DNS Provider'));
        o.value('cloudflare', _('Cloudflare (1.1.1.1)'));
        o.value('google', _('Google (8.8.8.8)'));
        o.value('adguard', _('AdGuard'));
        o.default = 'cloudflare';

        o = s.option(form.ListValue, 'gamefilter_mode', _('Game Filter Mode'));
        o.value('universal', _('Universal'));
        o.value('custom', _('Custom'));
        o.default = 'universal';

        var s2 = m.section(form.TypedSection, 'proboy', _('Features'));
        s2.anonymous = true;

        o = s2.option(form.Flag, 'zapret_enabled', _('Enable Zapret'));
        o.default = '1';
        o.rmempty = false;

        o = s2.option(form.Flag, 'gamefilter_enabled', _('Enable Game Filter'));
        o.default = '1';
        o.rmempty = false;

        o = s2.option(form.Flag, 'dns_enabled', _('Enable DNS Bypass'));
        o.default = '1';
        o.rmempty = false;

        o = s2.option(form.Flag, 'youtube_enabled', _('YouTube Optimizer'));
        o.default = '1';
        o.rmempty = false;

        o = s2.option(form.Flag, 'ipv6_enabled', _('IPv6 Bypass'));
        o.default = '0';
        o.rmempty = false;

        o = s2.option(form.Flag, 'failover_enabled', _('Failover'));
        o.default = '1';
        o.rmempty = false;

        var s3 = m.section(form.TypedSection, 'proboy', _('Subscription'));
        s3.anonymous = true;

        o = s3.option(form.Value, 'subscription_url', _('Subscription URL'));
        o.placeholder = 'https://...';
        o.rmempty = true;

        var s4 = m.section(form.TypedSection, 'proboy', _('Web Panel'));
        s4.anonymous = true;

        o = s4.option(form.Flag, 'web_enabled', _('Enable Web Panel'));
        o.default = '1';
        o.rmempty = false;

        o = s4.option(form.Value, 'web_port', _('Web Panel Port'));
        o.datatype = 'port';
        o.default = '8080';

        return m.render();
    },

    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});
