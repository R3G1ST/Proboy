'use strict';
'require form';
'require view';

return view.extend({
    render: function() {
        var m = new form.Map('proboy', _('Subscriptions'));

        var s = m.section(form.TypedSection, 'proboy', _('Subscription Settings'));
        s.anonymous = true;

        o = s.option(form.Value, 'subscription_url', _('Subscription URL'));
        o.placeholder = 'https://...';
        o.rmempty = true;
        o.description = _('Supported: hysteria2://, vless://, trojan://, ss://, clash, v2rayN');

        return m.render();
    }
});
