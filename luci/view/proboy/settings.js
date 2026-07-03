'use strict';
'require form';
'require view';

return view.extend({
    render: function() {
        var m = new form.Map('proboy', _('Proboy Settings'));

        var s = m.section(form.TypedSection, 'proboy', _('General'));
        s.anonymous = true;

        o = s.option(form.ListValue, 'enabled', _('Enable Proboy'));
        o.value('1', _('Enabled'));
        o.value('0', _('Disabled'));
        o.default = '1';

        var s2 = m.section(form.TypedSection, 'proboy', _('Web Panel'));
        s2.anonymous = true;

        o = s2.option(form.Flag, 'web_enabled', _('Enable Web Panel'));
        o.default = '1';
        o.rmempty = false;

        o = s2.option(form.Value, 'web_port', _('Web Panel Port'));
        o.datatype = 'port';
        o.default = '8080';

        return m.render();
    }
});
