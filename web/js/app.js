/* Proboy x FreeLink — Main App */

const COMBO_PRESETS = {
    gamer: {
        name: { ru: 'Геймер', en: 'Gamer' },
        desc: { ru: 'Оптимизация для игр', en: 'Optimized for gaming' },
        icon: '🎮',
        settings: { zapret_enabled: 1, zapret_strategy: 'gaming', gamefilter_enabled: 1, gamefilter_mode: 'universal', dns_enabled: 1, dns_provider: 'cloudflare', youtube_enabled: 0, ipv6_enabled: 0, failover_enabled: 1 }
    },
    max: {
        name: { ru: 'Максимум', en: 'Maximum' },
        desc: { ru: 'Максимальный обход блокировок', en: 'Maximum bypass' },
        icon: '🚀',
        settings: { zapret_enabled: 1, zapret_strategy: 'aggressive', gamefilter_enabled: 1, gamefilter_mode: 'universal', dns_enabled: 1, dns_provider: 'cloudflare', youtube_enabled: 1, ipv6_enabled: 1, failover_enabled: 1 }
    },
    min: {
        name: { ru: 'Минимум', en: 'Minimum' },
        desc: { ru: 'Минимальное потребление ресурсов', en: 'Minimal resource usage' },
        icon: '🔋',
        settings: { zapret_enabled: 1, zapret_strategy: 'general', gamefilter_enabled: 0, gamefilter_mode: 'universal', dns_enabled: 1, dns_provider: 'cloudflare', youtube_enabled: 0, ipv6_enabled: 0, failover_enabled: 0 }
    },
    stream: {
        name: { ru: 'Стриминг', en: 'Streaming' },
        desc: { ru: 'Оптимизация для YouTube/Straming', en: 'Optimized for YouTube/Streaming' },
        icon: '📺',
        settings: { zapret_enabled: 1, zapret_strategy: 'youtube', gamefilter_enabled: 0, gamefilter_mode: 'universal', dns_enabled: 1, dns_provider: 'cloudflare', youtube_enabled: 1, ipv6_enabled: 0, failover_enabled: 1 }
    },
    free: {
        name: { ru: 'Свобода', en: 'Freedom' },
        desc: { ru: 'Полная свобода интернета', en: 'Full internet freedom' },
        icon: '🏴',
        settings: { zapret_enabled: 1, zapret_strategy: 'aggressive', gamefilter_enabled: 1, gamefilter_mode: 'universal', dns_enabled: 1, dns_provider: 'cloudflare', youtube_enabled: 1, ipv6_enabled: 1, failover_enabled: 1 }
    }
};

function getPresetIcon(key) {
    return COMBO_PRESETS[key]?.icon || '⚡';
}

function getPresetName(key) {
    var p = COMBO_PRESETS[key];
    return p ? (p.name[currentLang] || p.name.en) : key;
}

function getPresetDesc(key) {
    var p = COMBO_PRESETS[key];
    return p ? (p.desc[currentLang] || p.desc.en) : '';
}

async function applyPreset(key) {
    var preset = COMBO_PRESETS[key];
    if (!preset) return;
    var name = getPresetName(key);
    if (!confirm(name + '?')) return;
    try {
        var resp = await fetch('/cgi-bin/proboy-api/config', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(preset.settings)
        });
        var data = await resp.json();
        alert(data.ok ? (name + ' OK') : ('Error: ' + (data.message || 'Unknown')));
    } catch (e) {
        alert('Error: ' + e.message);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    initNavigation();
    loadSystemInfo();
    checkStatus();
});

function initNavigation() {
    var navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(function(item) {
        item.addEventListener('click', function() {
            navItems.forEach(function(i) { i.classList.remove('active'); });
            item.classList.add('active');
            var page = item.dataset.page;
            document.querySelectorAll('.page').forEach(function(p) { p.style.display = 'none'; });
            var pageEl = document.getElementById('page-' + page);
            if (pageEl) {
                pageEl.style.display = 'block';
                loadPage(page);
            }
        });
    });
}

async function loadPage(page) {
    var pageEl = document.getElementById('page-' + page);
    if (!pageEl) return;

    if (page === 'combo') {
        pageEl.innerHTML = buildComboHTML();
    } else if (page === 'authors') {
        pageEl.innerHTML = buildAuthorsHTML();
    } else if (page === 'settings') {
        pageEl.innerHTML = buildSettingsHTML();
    } else if (page === 'zapret') {
        pageEl.innerHTML = buildZapretHTML();
    } else if (page === 'games') {
        pageEl.innerHTML = buildGamesHTML();
    } else if (page === 'network') {
        pageEl.innerHTML = buildNetworkHTML();
    } else if (page === 'subscriptions') {
        pageEl.innerHTML = buildSubsHTML();
    }
}

function buildComboHTML() {
    var h = '<div class="page-header"><h1>' + t('combo_title') + '</h1><p>' + t('combo_desc') + '</p></div><div class="combo-grid">';
    for (var key in COMBO_PRESETS) {
        h += '<div class="combo-card" onclick="applyPreset(\'' + key + '\')">';
        h += '<div class="combo-icon">' + getPresetIcon(key) + '</div>';
        h += '<h3>' + getPresetName(key) + '</h3>';
        h += '<p>' + getPresetDesc(key) + '</p>';
        h += '<button class="btn btn-accent">' + t('apply') + '</button>';
        h += '</div>';
    }
    h += '</div>';
    return h;
}

function buildAuthorsHTML() {
    return '<div class="page-header"><h1>Authors</h1></div><div class="card"><div class="card-body"><p>R3G1ST — FreeLink + Proboy</p><p>bol-van — zapret</p><p>Flowseal — zapret-discord-youtube</p><p>apernet — Hysteria2</p><p>SagerNet — sing-box</p></div></div>';
}

function buildSettingsHTML() {
    return '<div class="page-header"><h1>' + t('settings_title') + '</h1></div><div class="card"><div class="card-body"><p>' + t('settings') + '</p></div></div>';
}

function buildZapretHTML() {
    return '<div class="page-header"><h1>Zapret</h1></div><div class="card"><div class="card-body"><p>DPI Bypass — 50+ strategies</p></div></div>';
}

function buildGamesHTML() {
    return '<div class="page-header"><h1>' + t('games_title') + '</h1></div><div class="card"><div class="card-body"><p>Universal game mode</p></div></div>';
}

function buildNetworkHTML() {
    return '<div class="page-header"><h1>' + t('network_title') + '</h1></div><div class="card"><div class="card-body"><p>Network analyzer</p></div></div>';
}

function buildSubsHTML() {
    return '<div class="page-header"><h1>' + t('sub_title') + '</h1></div><div class="card"><div class="card-body"><p>Subscriptions</p></div></div>';
}

async function loadSystemInfo() {
    try {
        var resp = await fetch('/cgi-bin/proboy-api/system');
        var data = await resp.json();
        document.getElementById('infoOS').textContent = data.os + ' ' + data.os_version;
        document.getElementById('infoRouter').textContent = (data.router_brand + ' ' + data.router_model).trim() || 'Unknown';
        document.getElementById('infoCPU').textContent = data.cpu + ' (' + data.cpu_cores + ' cores)';
        document.getElementById('infoRAM').textContent = data.ram_mb + ' MB';
        document.getElementById('infoFlash').textContent = data.flash_free_mb + ' MB free';
        document.getElementById('infoArch').textContent = data.os_arch;
    } catch (e) {
        document.getElementById('infoOS').textContent = 'Unavailable';
    }
}

async function checkStatus() {
    try {
        var resp = await fetch('/cgi-bin/proboy-api/status');
        var data = await resp.json();
        var dot = document.getElementById('statusDot');
        var text = document.getElementById('statusText');
        if (data.running) {
            dot.classList.add('ok');
            text.textContent = t('running');
        } else {
            dot.classList.add('error');
            text.textContent = t('stopped');
        }
    } catch (e) {
        document.getElementById('statusDot').classList.add('error');
        document.getElementById('statusText').textContent = 'Offline';
    }
}

function saveSettings() {
    alert('Settings saved!');
}
