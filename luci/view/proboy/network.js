'use strict';
'require form';
'require view';

return view.extend({
    render: function() {
        var m = new form.Map('proboy', _('Network'));

        var s = m.section(form.TypedSection, 'proboy', _('DNS Settings'));
        s.anonymous = true;

        o = s.option(form.Flag, 'dns_enabled', _('Enable DNS Bypass'));
        o.default = '1';
        o.rmempty = false;

        o = s.option(form.ListValue, 'dns_provider', _('DNS Provider'));
        o.value('cloudflare', _('Cloudflare (1.1.1.1)'));
        o.value('google', _('Google (8.8.8.8)'));
        o.value('adguard', _('AdGuard'));
        o.default = 'cloudflare';

        var s2 = m.section(form.TypedSection, 'proboy', _('YouTube & IPv6'));
        s2.anonymous = true;

        o = s2.option(form.Flag, 'youtube_enabled', _('YouTube Optimizer'));
        o.default = '1';
        o.rmempty = false;

        o = s2.option(form.Flag, 'ipv6_enabled', _('IPv6 Bypass'));
        o.default = '0';
        o.rmempty = false;

        return m.render();
    }
});
