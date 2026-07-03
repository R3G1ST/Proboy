"use strict";
"require view";
"require form";
"require view.proboy.dashboard as dashboard";
"require view.proboy.combo as combo";
"require view.proboy.zapret as zapret";
"require view.proboy.games as games";
"require view.proboy.network as network";
"require view.proboy.subs as subs";
"require view.proboy.settings as settings";

return view.extend({
    render: function() {
        var m = new form.Map("proboy", _("Proboy"),
            _("Anti-censorship suite — DPI bypass, gaming, subscriptions"));
        m.tabbed = true;

        // Dashboard
        var s = m.section(form.TypedSection, "proboy", _("Dashboard"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        dashboard.createContent(s);

        // Combo Builder
        s = m.section(form.TypedSection, "proboy", _("Combo Builder"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        combo.createContent(s);

        // Zapret
        s = m.section(form.TypedSection, "proboy", _("Zapret"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        zapret.createContent(s);

        // Games
        s = m.section(form.TypedSection, "proboy", _("Games"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        games.createContent(s);

        // Network
        s = m.section(form.TypedSection, "proboy", _("Network"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        network.createContent(s);

        // Subscriptions
        s = m.section(form.TypedSection, "proboy", _("Subscriptions"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        subs.createContent(s);

        // Settings
        s = m.section(form.TypedSection, "proboy", _("Settings"));
        s.anonymous = true;
        s.addremove = false;
        s.cfgsections = function() { return ["main"]; };
        settings.createContent(s);

        return m.render();
    }
});
