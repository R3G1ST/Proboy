"use strict";
"require form";

return {
    createContent: function(s) {
        var o = s.option(form.Flag, "gamefilter_enabled", _("Enable Game Filter"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "gamefilter_mode", _("Mode"));
        o.value("universal", _("Universal — all games"));
        o.value("custom", _("Custom — select games"));
        o.default = "universal";

        o = s.option(form.Flag, "ps5_enabled", _("PS5 Auto-detect"));
        o.default = "0";
        o.rmempty = false;

        // Supported platforms info
        o = s.option(form.DummyValue, "_info", _("Supported Platforms"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            return '<div style="margin-top:8px;color:#666">' +
                '<p>Steam, Epic Games, Riot Games, Blizzard, EA, PlayStation, Xbox, Nintendo</p>' +
                '<p style="font-size:12px">Ports: 27015-27300 (Steam), 9000-9100 (Epic), 3478-3480 (PSN), 3074 (Xbox)</p>' +
                '</div>';
        };

        return null;
    }
};
