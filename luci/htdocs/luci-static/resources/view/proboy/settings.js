"use strict";
"require form";

return {
    createContent: function(s) {
        var o = s.option(form.Flag, "enabled", _("Enable Proboy"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "language", _("Language"));
        o.value("ru", "Русский");
        o.value("en", "English");
        o.default = "ru";

        // Web panel
        o = s.option(form.Flag, "web_enabled", _("Enable Web Panel"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.Value, "web_port", _("Web Panel Port"));
        o.datatype = "port";
        o.default = "8080";

        return null;
    }
};
