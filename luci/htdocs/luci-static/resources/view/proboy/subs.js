"use strict";
"require form";

return {
    createContent: function(s) {
        var o = s.option(form.Value, "subscription_url", _("Subscription URL"));
        o.placeholder = "https://...";
        o.rmempty = true;

        o = s.option(form.DummyValue, "_info", _("Supported Formats"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            return '<div style="margin-top:8px;color:#666;font-size:13px">' +
                '<p><b>Native:</b> hysteria2://, vless://, trojan://, ss://</p>' +
                '<p><b>External:</b> Clash (YAML), v2rayN (base64), Sing-box, WireGuard</p>' +
                '</div>';
        };

        return null;
    }
};
