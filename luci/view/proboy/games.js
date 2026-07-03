'use strict';
'require form';
'require view';

return view.extend({
    render: function() {
        var m = new form.Map('proboy', _('Game Filter'));

        var s = m.section(form.TypedSection, 'proboy', _('Game Filter Configuration'));
        s.anonymous = true;

        o = s.option(form.Flag, 'gamefilter_enabled', _('Enable Game Filter'));
        o.default = '1';
        o.rmempty = false;

        o = s.option(form.ListValue, 'gamefilter_mode', _('Mode'));
        o.value('universal', _('Universal — all games'));
        o.value('custom', _('Custom — select games'));
        o.default = 'universal';

        o = s.option(form.Flag, 'ps5_enabled', _('PS5 Auto-detect'));
        o.default = '0';
        o.rmempty = false;

        return m.render();
    }
});
