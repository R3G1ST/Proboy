"use strict";
"require form";

var STRATEGIES = [
    ["auto", _("Auto (recommended)")],
    ["general", _("General")],
    ["general-alt", _("General ALT")],
    ["fake-tls-auto", "FAKE TLS AUTO"],
    ["fake-tls-auto-alt", "FAKE TLS AUTO ALT"],
    ["simple-fake", "SIMPLE FAKE"],
    ["discord", "Discord"],
    ["youtube", "YouTube"],
    ["telegram", "Telegram"],
    ["gaming", _("Gaming")],
    ["fortnite", "Fortnite"],
    ["cs2", "CS2"],
    ["psn", "PlayStation Network"],
    ["steam", "Steam"],
    ["epic", "Epic Games"],
    ["alt1", "ALT 1"],
    ["alt2", "ALT 2"],
    ["alt3", "ALT 3"],
    ["alt4", "ALT 4"],
    ["alt5", "ALT 5"],
    ["alt6", "ALT 6"],
    ["alt7", "ALT 7"],
    ["alt8", "ALT 8"],
    ["alt9", "ALT 9"],
    ["alt10", "ALT 10"],
    ["alt11", "ALT 11"],
    ["alt12", "ALT 12"],
    ["aggressive", _("Aggressive")]
];

return {
    createContent: function(s) {
        var o = s.option(form.Flag, "zapret_enabled", _("Enable Zapret"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "zapret_strategy", _("Strategy"));
        STRATEGIES.forEach(function(st) {
            o.value(st[0], st[1]);
        });
        o.default = "auto";

        o = s.option(form.Flag, "failover_enabled", _("Failover"));
        o.default = "1";
        o.rmempty = false;

        return null;
    }
};
