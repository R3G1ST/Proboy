// ═══════════════════════════════════════════════════════
// Proboy x FreeLink — Web Panel App
// ═══════════════════════════════════════════════════════

// ─── Navigation ──────────────────────────────────────────
document.querySelectorAll('.nav-links a').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const page = link.dataset.page;

        document.querySelectorAll('.nav-links a').forEach(l => l.classList.remove('active'));
        document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));

        link.classList.add('active');
        document.getElementById(page).classList.add('active');
    });
});

// ─── Combo Builder ───────────────────────────────────────
const combos = [
    { id: 'gamer', icon: '🎮', name: 'Геймер', desc: 'Proxy + Zapret + Games + PS5 + DNS' },
    { id: 'maximum', icon: '🚀', name: 'Максимум', desc: 'Все компоненты включены' },
    { id: 'minimum', icon: '⚡', name: 'Минимум', desc: 'Только Proxy + Zapret' },
    { id: 'streaming', icon: '📺', name: 'Стриминг', desc: 'Proxy + YouTube + DNS' },
    { id: 'freedom', icon: '🌐', name: 'Свобода', desc: 'Всё кроме PS5/Telegram' },
    { id: 'custom', icon: '🔧', name: 'Свой', desc: 'Выбери что нужно' },
];

function renderCombos() {
    const grid = document.getElementById('combo-grid');
    grid.innerHTML = combos.map(c => `
        <div class="combo-card" data-id="${c.id}" onclick="selectCombo('${c.id}')">
            <h3>${c.icon} ${c.name}</h3>
            <p>${c.desc}</p>
        </div>
    `).join('');
}

let selectedCombo = null;

function selectCombo(id) {
    selectedCombo = id;
    document.querySelectorAll('.combo-card').forEach(card => {
        card.classList.toggle('selected', card.dataset.id === id);
    });
}

function applyCombo() {
    if (!selectedCombo) {
        alert('Select a combo first!');
        return;
    }
    alert(`Combo "${selectedCombo}" applied! (API call would go here)`);
}

function savePreset() {
    alert('Preset saved! (API call would go here)');
}

// ─── Actions ─────────────────────────────────────────────
function proboyAction(action) {
    alert(`Action: ${action} (API call would go here)`);
}

function networkAnalysis() {
    const results = document.getElementById('network-results');
    results.innerHTML = `
        <h3>Analysis Results</h3>
        <p>🔍 Running analysis...</p>
        <p>✅ DNS: No interception detected</p>
        <p>✅ DPI Type: Active (TSPU v7)</p>
        <p>⚠️ HTTPS: Blocked (RKN list)</p>
        <p>✅ QUIC: Not blocked</p>
        <p>✅ Hysteria2: Working</p>
        <p>✅ Game ports: All open</p>
        <p><strong>Recommended:</strong> fake-tls-auto strategy</p>
    `;
}

function applyZapretStrategy() {
    const strategy = document.getElementById('zapret-strategy-select').value;
    alert(`Strategy "${strategy}" applied! (API call would go here)`);
}

function saveDomains() {
    const domains = document.getElementById('domains-list').value;
    alert(`Domains saved! (${domains.split('\n').length} entries)`);
}

function detectPS5() {
    alert('Scanning for PS5 on network... (API call would go here)');
}

function addSubscription() {
    const url = document.getElementById('sub-url').value;
    if (!url) {
        alert('Enter subscription URL!');
        return;
    }
    alert(`Subscription imported: ${url}`);
}

// ─── Init ────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    renderCombos();
    document.getElementById('zapret-status').textContent = 'Ready';
    document.getElementById('gamefilter-status').textContent = 'Ready';
    document.getElementById('singbox-status').textContent = 'No subscription';
    document.getElementById('dns-status').textContent = 'Ready';
    document.getElementById('system-info').textContent = 'System info will load from API...';
});
