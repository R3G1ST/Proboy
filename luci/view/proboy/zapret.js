'use strict';
'require form';
'require view';

return view.extend({
    render: function() {
        var m = new form.Map('proboy', _('Zapret Settings'));

        var s = m.section(form.TypedSection, 'proboy', _('Zapret Configuration'));
        s.anonymous = true;

        o = s.option(form.Flag, 'zapret_enabled', _('Enable Zapret'));
        o.default = '1';
        o.rmempty = false;

        o = s.option(form.ListValue, 'zapret_strategy', _('Strategy'));
        o.value('auto', _('Auto (recommended)'));
        o.value('general', _('General'));
        o.value('general-alt', _('General ALT'));
        o.value('fake-tls-auto', _('FAKE TLS AUTO'));
        o.value('fake-tls-auto-alt', _('FAKE TLS AUTO ALT'));
        o.value('discord', _('Discord'));
        o.value('youtube', _('YouTube'));
        o.value('telegram', _('Telegram'));
        o.value('gaming', _('Gaming'));
        o.value('fortnite', _('Fortnite'));
        o.value('cs2', _('CS2'));
        o.value('psn', _('PlayStation Network'));
        o.value('steam', _('Steam'));
        o.value('epic', _('Epic Games'));
        o.value('aggressive', _('Aggressive'));
        o.default = 'auto';

        o = s.option(form.Flag, 'failover_enabled', _('Failover'));
        o.default = '1';
        o.rmempty = false;

        return m.render();
    }
});
