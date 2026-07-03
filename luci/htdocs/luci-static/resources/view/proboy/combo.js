"use strict";
"require form";
"require uci";

var PRESETS = {
    gamer: {
        icon: "🎮",
        name: { ru: "Геймер", en: "Gamer" },
        desc: { ru: "Оптимизация для игр", en: "Gaming optimized" },
        settings: {
            zapret_enabled: "1", zapret_strategy: "gaming",
            gamefilter_enabled: "1", gamefilter_mode: "universal",
            dns_enabled: "1", dns_provider: "cloudflare",
            youtube_enabled: "0", ipv6_enabled: "0", failover_enabled: "1"
        }
    },
    max: {
        icon: "🚀",
        name: { ru: "Максимум", en: "Maximum" },
        desc: { ru: "Максимальный обход блокировок", en: "Maximum bypass" },
        settings: {
            zapret_enabled: "1", zapret_strategy: "aggressive",
            gamefilter_enabled: "1", gamefilter_mode: "universal",
            dns_enabled: "1", dns_provider: "cloudflare",
            youtube_enabled: "1", ipv6_enabled: "1", failover_enabled: "1"
        }
    },
    min: {
        icon: "🔋",
        name: { ru: "Минимум", en: "Minimum" },
        desc: { ru: "Мало ресурсов", en: "Low resources" },
        settings: {
            zapret_enabled: "1", zapret_strategy: "general",
            gamefilter_enabled: "0", gamefilter_mode: "universal",
            dns_enabled: "1", dns_provider: "cloudflare",
            youtube_enabled: "0", ipv6_enabled: "0", failover_enabled: "0"
        }
    },
    stream: {
        icon: "📺",
        name: { ru: "Стриминг", en: "Streaming" },
        desc: { ru: "YouTube 4K без замедления", en: "YouTube 4K" },
        settings: {
            zapret_enabled: "1", zapret_strategy: "youtube",
            gamefilter_enabled: "0", gamefilter_mode: "universal",
            dns_enabled: "1", dns_provider: "cloudflare",
            youtube_enabled: "1", ipv6_enabled: "0", failover_enabled: "1"
        }
    },
    free: {
        icon: "🏴",
        name: { ru: "Свобода", en: "Freedom" },
        desc: { ru: "Полная свобода интернета", en: "Full freedom" },
        settings: {
            zapret_enabled: "1", zapret_strategy: "aggressive",
            gamefilter_enabled: "1", gamefilter_mode: "universal",
            dns_enabled: "1", dns_provider: "cloudflare",
            youtube_enabled: "1", ipv6_enabled: "1", failover_enabled: "1"
        }
    }
};

function getLang() {
    try {
        var lang = uci.get("proboy", "main", "language");
        return lang || "ru";
    } catch(e) { return "ru"; }
}

function applyPreset(key) {
    var preset = PRESETS[key];
    if (!preset) return;
    var lang = getLang();
    var name = preset.name[lang] || preset.name.en;

    if (!confirm(_("Apply") + ": " + name + "?")) return;

    uci.load("proboy");
    for (var k in preset.settings) {
        uci.set("proboy", "main", k, preset.settings[k]);
    }
    uci.commit("proboy");

    // Restart service
    try {
        fs.exec("/etc/init.d/proboy", ["restart"]);
    } catch(e) {}

    alert(name + " " + _("applied") + "!");
    window.location.reload();
}

return {
    createContent: function(s) {
        var lang = getLang();

        var o = s.option(form.DummyValue, "_presets", _("Choose a preset"));
        o.rawhtml = true;
        o.cfgvalue = function() {
            var html = '<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:12px;margin-top:8px">';
            for (var k in PRESETS) {
                var p = PRESETS[k];
                var name = p.name[lang] || p.name.en;
                var desc = p.desc[lang] || p.desc.en;
                html += '<div style="border:1px solid #ddd;border-radius:8px;padding:16px;text-align:center;cursor:pointer" onclick="applyPreset(\'' + k + '\')">';
                html += '<div style="font-size:32px;margin-bottom:8px">' + p.icon + '</div>';
                html += '<div style="font-weight:bold;margin-bottom:4px">' + name + '</div>';
                html += '<div style="color:#666;font-size:12px;margin-bottom:8px">' + desc + '</div>';
                html += '<input type="button" class="cbi-button cbi-button-apply" value="' + _('Apply') + '" />';
                html += '</div>';
            }
            html += '</div>';
            return html;
        };

        return null;
    }
};
