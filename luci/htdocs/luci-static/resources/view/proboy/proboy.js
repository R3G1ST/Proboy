"use strict";
"require view";
"require form";

return view.extend({
    render: function() {
        var m, s, o;

        m = new form.Map("proboy", _("Proboy"),
            _("Anti-censorship suite for OpenWrt — DPI bypass, gaming, subscriptions"));

        // === General Settings ===
        s = m.section(form.TypedSection, "proboy", _("General Settings"));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "enabled", _("Enable Proboy"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "language", _("Language"));
        o.value("ru", "Русский");
        o.value("en", "English");
        o.default = "ru";

        // === Zapret Settings ===
        s = m.section(form.TypedSection, "proboy", _("Zapret (DPI Bypass)"));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "zapret_enabled", _("Enable Zapret"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "zapret_strategy", _("Strategy"));
        o.value("auto", _("Auto (recommended)"));
        o.value("general", _("General"));
        o.value("general-alt", _("General ALT"));
        o.value("fake-tls-auto", _("FAKE TLS AUTO"));
        o.value("fake-tls-auto-alt", _("FAKE TLS AUTO ALT"));
        o.value("simple-fake", _("SIMPLE FAKE"));
        o.value("discord", _("Discord"));
        o.value("youtube", _("YouTube"));
        o.value("telegram", _("Telegram"));
        o.value("gaming", _("Gaming"));
        o.value("fortnite", _("Fortnite"));
        o.value("cs2", _("CS2"));
        o.value("psn", _("PlayStation Network"));
        o.value("steam", _("Steam"));
        o.value("epic", _("Epic Games"));
        o.value("alt1", "ALT 1");
        o.value("alt2", "ALT 2");
        o.value("alt3", "ALT 3");
        o.value("alt4", "ALT 4");
        o.value("alt5", "ALT 5");
        o.value("alt6", "ALT 6");
        o.value("alt7", "ALT 7");
        o.value("alt8", "ALT 8");
        o.value("alt9", "ALT 9");
        o.value("alt10", "ALT 10");
        o.value("alt11", "ALT 11");
        o.value("alt12", "ALT 12");
        o.value("aggressive", _("Aggressive"));
        o.default = "auto";

        o = s.option(form.Flag, "failover_enabled", _("Failover"));
        o.default = "1";
        o.rmempty = false;

        // === Game Filter ===
        s = m.section(form.TypedSection, "proboy", _("Game Filter"));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "gamefilter_enabled", _("Enable Game Filter"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "gamefilter_mode", _("Mode"));
        o.value("universal", _("Universal — all games"));
        o.value("custom", _("Custom"));
        o.default = "universal";

        o = s.option(form.Flag, "ps5_enabled", _("PS5 Auto-detect"));
        o.default = "0";
        o.rmempty = false;

        // === Network ===
        s = m.section(form.TypedSection, "proboy", _("Network"));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "dns_enabled", _("Enable DNS Bypass"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.ListValue, "dns_provider", _("DNS Provider"));
        o.value("cloudflare", "Cloudflare (1.1.1.1)");
        o.value("google", "Google (8.8.8.8)");
        o.value("adguard", "AdGuard");
        o.default = "cloudflare";

        o = s.option(form.Flag, "youtube_enabled", _("YouTube Optimizer"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.Flag, "ipv6_enabled", _("IPv6 Bypass"));
        o.default = "0";
        o.rmempty = false;

        // === Subscriptions ===
        s = m.section(form.TypedSection, "proboy", _("Subscriptions"));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Value, "subscription_url", _("Subscription URL"));
        o.placeholder = "https://...";
        o.rmempty = true;
        o.description = "hysteria2://, vless://, trojan://, ss://, clash, v2rayN";

        // === Web Panel ===
        s = m.section(form.TypedSection, "proboy", _("Web Panel"));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, "web_enabled", _("Enable Web Panel"));
        o.default = "1";
        o.rmempty = false;

        o = s.option(form.Value, "web_port", _("Port"));
        o.datatype = "port";
        o.default = "8080";

        return m.render();
    }
});
