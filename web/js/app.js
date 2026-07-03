/* Proboy x FreeLink — Main App */

var currentLang = localStorage.getItem('proboy-lang') || 'ru';

var PRESETS = {
    gamer: { icon: '🎮', name: { ru: 'Геймер', en: 'Gamer' }, desc: { ru: 'Оптимизация для игр', en: 'Gaming' } },
    max: { icon: '🚀', name: { ru: 'Максимум', en: 'Maximum' }, desc: { ru: 'Максимальный обход', en: 'Max bypass' } },
    min: { icon: '🔋', name: { ru: 'Минимум', en: 'Minimum' }, desc: { ru: 'Мало ресурсов', en: 'Low resources' } },
    stream: { icon: '📺', name: { ru: 'Стриминг', en: 'Streaming' }, desc: { ru: 'YouTube 4K', en: 'YouTube 4K' } },
    free: { icon: '🏴', name: { ru: 'Свобода', en: 'Freedom' }, desc: { ru: 'Полная свобода', en: 'Full freedom' } }
};

function initNav() {
    var items = document.querySelectorAll('.nav-item');
    items.forEach(function(item) {
        item.onclick = function() {
            items.forEach(function(i) { i.classList.remove('active'); });
            item.classList.add('active');
            var page = item.getAttribute('data-page');
            document.querySelectorAll('.page').forEach(function(p) { p.style.display = 'none'; });
            var el = document.getElementById('page-' + page);
            if (el) {
                el.style.display = 'block';
                loadPage(page);
            }
        };
    });
}

function loadPage(page) {
    var el = document.getElementById('page-' + page);
    if (!el) return;
    if (page === 'combo') el.innerHTML = comboHTML();
    else if (page === 'authors') el.innerHTML = authorsHTML();
    else if (page === 'settings') el.innerHTML = settingsHTML();
    else if (page === 'zapret') el.innerHTML = zapretHTML();
    else if (page === 'games') el.innerHTML = gamesHTML();
    else if (page === 'network') el.innerHTML = networkHTML();
    else if (page === 'subscriptions') el.innerHTML = subsHTML();
}

function comboHTML() {
    var h = '<div class="page-header"><h1>Комбо Builder</h1><p>Выберите пресет</p></div><div class="combo-grid">';
    for (var k in PRESETS) {
        var p = PRESETS[k];
        h += '<div class="combo-card" onclick="applyPreset(\'' + k + '\')">';
        h += '<div class="combo-icon">' + p.icon + '</div>';
        h += '<h3>' + (p.name[currentLang] || p.name.en) + '</h3>';
        h += '<p>' + (p.desc[currentLang] || p.desc.en) + '</p>';
        h += '<button class="btn btn-accent">Применить</button></div>';
    }
    return h + '</div>';
}

function applyPreset(key) {
    alert('Пресет ' + (PRESETS[key] ? (PRESETS[key].name[currentLang] || PRESETS[key].name.en) : key) + ' применён!');
}

function authorsHTML() {
    return '<div class="page-header"><h1>Авторы</h1></div><div class="card"><div class="card-body"><p><b>R3G1ST</b> — FreeLink + Proboy</p><p><b>bol-van</b> — zapret</p><p><b>Flowseal</b> — zapret-discord-youtube</p><p><b>apernet</b> — Hysteria2</p><p><b>SagerNet</b> — sing-box</p></div></div>';
}

function settingsHTML() {
    return '<div class="page-header"><h1>Настройки</h1></div><div class="card"><div class="card-body"><p>Конфигурация Proboy</p></div></div>';
}

function zapretHTML() {
    return '<div class="page-header"><h1>Zapret</h1></div><div class="card"><div class="card-body"><p>DPI Bypass — 50+ стратегий</p></div></div>';
}

function gamesHTML() {
    return '<div class="page-header"><h1>Игры</h1></div><div class="card"><div class="card-body"><p>Универсальный игровой режим</p></div></div>';
}

function networkHTML() {
    return '<div class="page-header"><h1>Сеть</h1></div><div class="card"><div class="card-body"><p>Анализатор сети</p></div></div>';
}

function subsHTML() {
    return '<div class="page-header"><h1>Подписки</h1></div><div class="card"><div class="card-body"><p>Управление подписками</p></div></div>';
}

function loadInfo() {
    fetch('/cgi-bin/proboy-api/system').then(function(r) { return r.json(); }).then(function(d) {
        var os = document.getElementById('infoOS');
        var rt = document.getElementById('infoRouter');
        var cpu = document.getElementById('infoCPU');
        var ram = document.getElementById('infoRAM');
        var flash = document.getElementById('infoFlash');
        var arch = document.getElementById('infoArch');
        if (os) os.textContent = d.os + ' ' + d.os_version;
        if (rt) rt.textContent = (d.router_brand + ' ' + d.router_model).trim() || 'Unknown';
        if (cpu) cpu.textContent = d.cpu;
        if (ram) ram.textContent = d.ram_mb + ' MB';
        if (flash) flash.textContent = d.flash_free_mb + ' MB';
        if (arch) arch.textContent = d.os_arch;
    }).catch(function() {});
}

function checkStatus() {
    fetch('/cgi-bin/proboy-api/status').then(function(r) { return r.json(); }).then(function(d) {
        var dot = document.getElementById('statusDot');
        var txt = document.getElementById('statusText');
        if (d.running) { dot.className = 'status-dot ok'; txt.textContent = 'Работает'; }
        else { dot.className = 'status-dot error'; txt.textContent = 'Остановлен'; }
    }).catch(function() {
        document.getElementById('statusDot').className = 'status-dot error';
        document.getElementById('statusText').textContent = 'Offline';
    });
}

document.addEventListener('DOMContentLoaded', function() {
    initNav();
    loadInfo();
    checkStatus();
});
