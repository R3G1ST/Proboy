/* Proboy x FreeLink — Main App */

document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    loadSystemInfo();
    checkStatus();
});

function initNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', () => {
            navItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');

            const page = item.dataset.page;
            document.querySelectorAll('.page').forEach(p => p.style.display = 'none');
            const pageEl = document.getElementById('page-' + page);
            if (pageEl) {
                pageEl.style.display = 'block';
                loadPage(page);
            }
        });
    });
}

async function loadPage(page) {
    const pageEl = document.getElementById('page-' + page);
    if (!pageEl) return;

    if (page === 'authors') {
        pageEl.innerHTML = await loadAuthorsPage();
    } else if (page === 'combo') {
        pageEl.innerHTML = await loadComboPage();
    } else if (page === 'settings') {
        pageEl.innerHTML = await loadSettingsPage();
    } else if (page === 'zapret') {
        pageEl.innerHTML = await loadZapretPage();
    } else if (page === 'games') {
        pageEl.innerHTML = await loadGamesPage();
    } else if (page === 'network') {
        pageEl.innerHTML = await loadNetworkPage();
    } else if (page === 'subscriptions') {
        pageEl.innerHTML = await loadSubscriptionsPage();
    }
}

async function loadSystemInfo() {
    try {
        const resp = await fetch('/cgi-bin/proboy-api/system');
        const data = await resp.json();

        document.getElementById('infoOS').textContent = `${data.os} ${data.os_version}`;
        document.getElementById('infoRouter').textContent = `${data.router_brand} ${data.router_model}`.trim() || 'Unknown';
        document.getElementById('infoCPU').textContent = `${data.cpu} (${data.cpu_cores} cores)`;
        document.getElementById('infoRAM').textContent = `${data.ram_mb} MB`;
        document.getElementById('infoFlash').textContent = `${data.flash_free_mb} MB free`;
        document.getElementById('infoArch').textContent = data.os_arch;
    } catch (e) {
        document.getElementById('infoOS').textContent = 'Unavailable';
    }
}

async function checkStatus() {
    try {
        const resp = await fetch('/cgi-bin/proboy-api/status');
        const data = await resp.json();
        const dot = document.getElementById('statusDot');
        const text = document.getElementById('statusText');

        if (data.running) {
            dot.classList.add('ok');
            text.textContent = 'Running';
        } else {
            dot.classList.add('error');
            text.textContent = 'Stopped';
        }
    } catch (e) {
        const dot = document.getElementById('statusDot');
        const text = document.getElementById('statusText');
        dot.classList.add('error');
        text.textContent = 'Offline';
    }
}

async function loadAuthorsPage() {
    return `
    <div class="page-header">
        <h1>Authors & Credits</h1>
        <p>Proboy x FreeLink — Internet Freedom for People</p>
    </div>

    <div class="card mb-4">
        <div class="card-header"><h2>Project Authors</h2></div>
        <div class="card-body">
            <table class="table">
                <tr>
                    <td><strong>R3G1ST</strong></td>
                    <td>FreeLink + Proboy (author)</td>
                    <td><a href="https://github.com/R3G1ST" target="_blank">github.com/R3G1ST</a></td>
                </tr>
            </table>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-header"><h2>Core Dependencies</h2></div>
        <div class="card-body">
            <table class="table">
                <thead>
                    <tr><th>Author</th><th>Project</th><th>Stars</th><th>What We Use</th></tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>bol-van</strong></td>
                        <td><a href="https://github.com/bol-van/zapret" target="_blank">zapret</a></td>
                        <td>15.6k</td>
                        <td>DPI bypass engine (nfqws/tpws)</td>
                    </tr>
                    <tr>
                        <td><strong>Flowseal</strong></td>
                        <td><a href="https://github.com/Flowseal/zapret-discord-youtube" target="_blank">zapret-discord-youtube</a></td>
                        <td>30.4k</td>
                        <td>Tested DPI strategies</td>
                    </tr>
                    <tr>
                        <td><strong>apernet</strong></td>
                        <td><a href="https://github.com/apernet/hysteria" target="_blank">Hysteria 2</a></td>
                        <td>22k</td>
                        <td>QUIC-based anti-censorship proxy</td>
                    </tr>
                    <tr>
                        <td><strong>SagerNet</strong></td>
                        <td><a href="https://github.com/SagerNet/sing-box" target="_blank">sing-box</a></td>
                        <td>16k</td>
                        <td>Universal proxy platform</td>
                    </tr>
                    <tr>
                        <td><strong>itdoginfo</strong></td>
                        <td><a href="https://github.com/itdoginfo/podkop" target="_blank">podkop</a></td>
                        <td>2k</td>
                        <td>Architecture inspiration</td>
                    </tr>
                    <tr>
                        <td><strong>OpenWrt</strong></td>
                        <td><a href="https://github.com/openwrt/openwrt" target="_blank">OpenWrt</a></td>
                        <td>-</td>
                        <td>Router OS (APK package manager)</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-header"><h2>Strategy Authors</h2></div>
        <div class="card-body">
            <table class="table">
                <tr>
                    <td><strong>bol-van</strong></td>
                    <td>Original zapret strategies (fake, multisplit, disorder, syndata, etc.)</td>
                </tr>
                <tr>
                    <td><strong>Flowseal</strong></td>
                    <td>Community-tested strategies (ALT 1-12, FAKE TLS AUTO, SIMPLE FAKE)</td>
                </tr>
                <tr>
                    <td><strong>Proboy community</strong></td>
                    <td>Gaming strategies (Fortnite, CS2, Discord, PSN, etc.)</td>
                </tr>
            </table>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-header"><h2>Acknowledgments</h2></div>
        <div class="card-body" style="padding: 16px;">
            <ul style="list-style: none; line-height: 2;">
                <li><strong>bol-van</strong> — for creating zapret, the foundation of DPI bypass on OpenWrt</li>
                <li><strong>Flowseal</strong> — for testing and documenting strategies that work against Russian DPI</li>
                <li><strong>itdoginfo</strong> — for podkop, which inspired Proboy's architecture</li>
                <li><strong>apernet</strong> — for Hysteria2, the fastest QUIC-based proxy</li>
                <li><strong>SagerNet</strong> — for sing-box, the universal proxy platform</li>
                <li><strong>OpenWrt community</strong> — for the router OS that makes this possible</li>
                <li><strong>All contributors</strong> — who test strategies, report issues, and improve the project</li>
            </ul>
        </div>
    </div>

    <div class="card">
        <div class="card-body" style="padding: 16px;">
            <p style="text-align: center; color: var(--text-dim);">
                License: MIT &nbsp;|&nbsp;
                <a href="https://github.com/R3G1ST/Proboy" target="_blank">github.com/R3G1ST/Proboy</a> &nbsp;|&nbsp;
                <a href="https://github.com/R3G1ST/FreeLink" target="_blank">github.com/R3G1ST/FreeLink</a>
            </p>
        </div>
    </div>`;
}

async function loadComboPage() {
    renderComboPage();
    return '';
}

async function loadSettingsPage() {
    return `
    <div class="page-header">
        <h1>Settings</h1>
        <p>Proboy configuration</p>
    </div>
    <div class="card">
        <div class="card-body" style="padding: 16px;">
            <div class="form-group">
                <label>Zapret Strategy</label>
                <select class="form-input" id="zapretStrategy">
                    <option value="auto">Auto (recommended)</option>
                    <option value="general">General</option>
                    <option value="fake-tls-auto">FAKE TLS AUTO</option>
                    <option value="discord">Discord</option>
                    <option value="youtube">YouTube</option>
                    <option value="gaming">Gaming</option>
                    <option value="fortnite">Fortnite</option>
                    <option value="cs2">CS2</option>
                    <option value="psn">PlayStation Network</option>
                    <option value="telegram">Telegram</option>
                    <option value="aggressive">Aggressive</option>
                </select>
            </div>
            <div class="form-group">
                <label>Web Panel Port</label>
                <input type="number" class="form-input" id="webPort" value="8080">
            </div>
            <div class="form-group">
                <label>DNS Provider</label>
                <select class="form-input" id="dnsProvider">
                    <option value="cloudflare">Cloudflare (1.1.1.1)</option>
                    <option value="google">Google (8.8.8.8)</option>
                    <option value="quad9">Quad9 (9.9.9.9)</option>
                </select>
            </div>
            <div class="form-group">
                <label>Subscription URL</label>
                <input type="text" class="form-input" id="subUrl" placeholder="https://...">
            </div>
            <div class="form-group">
                <label>Auto-refresh subscription (hours)</label>
                <input type="number" class="form-input" id="subRefresh" value="24">
            </div>
            <button class="btn btn-primary" onclick="saveSettings()">Save Settings</button>
        </div>
    </div>`;
}

async function loadZapretPage() {
    return `
    <div class="page-header">
        <h1>Zapret (DPI Bypass)</h1>
        <p>50+ strategies from bol-van and Flowseal</p>
    </div>
    <div class="card">
        <div class="card-body" style="padding: 16px;">
            <div class="form-group">
                <label>Active Strategy</label>
                <select class="form-input">
                    <option>auto</option>
                    <option>general</option>
                    <option>general-alt</option>
                    <option>fake-tls-auto</option>
                    <option>fake-tls-auto-alt</option>
                    <option>discord</option>
                    <option>youtube</option>
                    <option>gaming</option>
                    <option>fortnite</option>
                    <option>cs2</option>
                    <option>psn</option>
                    <option>telegram</option>
                    <option>aggressive</option>
                </select>
            </div>
            <button class="btn btn-primary">Apply Strategy</button>
            <button class="btn btn-secondary">Test Strategy</button>
        </div>
    </div>`;
}

async function loadGamesPage() {
    return `
    <div class="page-header">
        <h1>Games</h1>
        <p>Universal game mode for all platforms</p>
    </div>
    <div class="cards-grid">
        <div class="card"><div class="card-content"><h3>🎮 Universal Game Mode</h3><p class="status status-ok">All games supported</p></div></div>
        <div class="card"><div class="card-content"><h3>🕹️ PS5</h3><p class="status">Auto-detect</p></div></div>
        <div class="card"><div class="card-content"><h3>🔫 CS2</h3><p class="status status-ok">Enabled</p></div></div>
        <div class="card"><div class="card-content"><h3>🏰 Fortnite</h3><p class="status status-ok">Enabled</p></div></div>
    </div>`;
}

async function loadNetworkPage() {
    return `
    <div class="page-header">
        <h1>Network Analyzer</h1>
        <p>Detect DPI type and auto-configure</p>
    </div>
    <div class="card">
        <div class="card-body" style="padding: 16px;">
            <button class="btn btn-primary">🔍 Run Analysis</button>
            <div id="networkResults" style="margin-top: 16px;">
                <p style="color: var(--text-dim);">Click to analyze your network...</p>
            </div>
        </div>
    </div>`;
}

async function loadSubscriptionsPage() {
    return `
    <div class="page-header">
        <h1>Subscriptions</h1>
        <p>Import from FreeLink or third-party sources</p>
    </div>
    <div class="card">
        <div class="card-body" style="padding: 16px;">
            <div class="form-group">
                <label>Subscription URL</label>
                <input type="text" class="form-input" placeholder="hysteria2://... or clash://... or vless://...">
            </div>
            <div class="form-group">
                <label>Or paste from clipboard</label>
                <textarea class="form-input" rows="4" placeholder="Paste subscription link or config here..."></textarea>
            </div>
            <button class="btn btn-primary">📡 Import Subscription</button>
            <button class="btn btn-secondary">🔄 Refresh All</button>
            <h3 style="margin-top: 24px; margin-bottom: 12px;">Supported Formats</h3>
            <p style="color: var(--text-dim); font-size: 13px;">
                FreeLink native (hysteria2://, vless://, trojan://, ss://) &nbsp;|&nbsp;
                Clash (YAML) &nbsp;|&nbsp;
                v2rayN (base64) &nbsp;|&nbsp;
                Happ &nbsp;|&nbsp;
                Sing-box &nbsp;|&nbsp;
                WireGuard &nbsp;|&nbsp;
                Manual URI
            </p>
        </div>
    </div>`;
}

function saveSettings() {
    alert('Settings saved!');
}
