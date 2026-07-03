/* Proboy Combo Builder */

const COMBO_PRESETS = {
    gamer: {
        name: { ru: 'Геймер', en: 'Gamer' },
        desc: { ru: 'Оптимизация для игр', en: 'Optimized for gaming' },
        settings: {
            zapret_enabled: 1,
            zapret_strategy: 'gaming',
            gamefilter_enabled: 1,
            gamefilter_mode: 'universal',
            dns_enabled: 1,
            dns_provider: 'cloudflare',
            youtube_enabled: 0,
            ipv6_enabled: 0,
            failover_enabled: 1
        }
    },
    max: {
        name: { ru: 'Максимум', en: 'Maximum' },
        desc: { ru: 'Максимальный обход блокировок', en: 'Maximum bypass' },
        settings: {
            zapret_enabled: 1,
            zapret_strategy: 'aggressive',
            gamefilter_enabled: 1,
            gamefilter_mode: 'universal',
            dns_enabled: 1,
            dns_provider: 'cloudflare',
            youtube_enabled: 1,
            ipv6_enabled: 1,
            failover_enabled: 1
        }
    },
    min: {
        name: { ru: 'Минимум', en: 'Minimum' },
        desc: { ru: 'Минимальное потребление ресурсов', en: 'Minimal resource usage' },
        settings: {
            zapret_enabled: 1,
            zapret_strategy: 'general',
            gamefilter_enabled: 0,
            gamefilter_mode: 'universal',
            dns_enabled: 1,
            dns_provider: 'cloudflare',
            youtube_enabled: 0,
            ipv6_enabled: 0,
            failover_enabled: 0
        }
    },
    stream: {
        name: { ru: 'Стриминг', en: 'Streaming' },
        desc: { ru: 'Оптимизация для YouTube/Straming', en: 'Optimized for YouTube/Streaming' },
        settings: {
            zapret_enabled: 1,
            zapret_strategy: 'youtube',
            gamefilter_enabled: 0,
            gamefilter_mode: 'universal',
            dns_enabled: 1,
            dns_provider: 'cloudflare',
            youtube_enabled: 1,
            ipv6_enabled: 0,
            failover_enabled: 1
        }
    },
    free: {
        name: { ru: 'Свобода', en: 'Freedom' },
        desc: { ru: 'Полная свобода интернета', en: 'Full internet freedom' },
        settings: {
            zapret_enabled: 1,
            zapret_strategy: 'aggressive',
            gamefilter_enabled: 1,
            gamefilter_mode: 'universal',
            dns_enabled: 1,
            dns_provider: 'cloudflare',
            youtube_enabled: 1,
            ipv6_enabled: 1,
            failover_enabled: 1
        }
    }
};

function renderComboPage() {
    const page = document.getElementById('page-combo');
    if (!page) return;

    let html = `
        <div class="page-header">
            <h1 data-i18n="combo_title">${t('combo_title')}</h1>
            <p data-i18n="combo_desc">${t('combo_desc')}</p>
        </div>
        <div class="combo-grid">
    `;

    for (const [key, preset] of Object.entries(COMBO_PRESETS)) {
        const name = preset.name[currentLang] || preset.name.en;
        const desc = preset.desc[currentLang] || preset.desc.en;
        html += `
            <div class="combo-card" onclick="applyPreset('${key}')">
                <div class="combo-icon">${getPresetIcon(key)}</div>
                <h3>${name}</h3>
                <p>${desc}</p>
                <button class="btn btn-accent">${t('apply')}</button>
            </div>
        `;
    }

    html += '</div>';
    page.innerHTML = html;
}

function getPresetIcon(key) {
    const icons = {
        gamer: '🎮',
        max: '🚀',
        min: '🔋',
        stream: '📺',
        free: '🏴'
    };
    return icons[key] || '⚡';
}

async function applyPreset(key) {
    const preset = COMBO_PRESETS[key];
    if (!preset) return;

    const name = preset.name[currentLang] || preset.name.en;
    if (!confirm(`${t('apply')}: ${name}?`)) return;

    try {
        const resp = await fetch('/cgi-bin/proboy-api/config', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(preset.settings)
        });
        const data = await resp.json();
        if (data.ok) {
            alert(`${name} ${t('apply')} ✓`);
        } else {
            alert('Error: ' + (data.message || 'Unknown'));
        }
    } catch (e) {
        alert('Error: ' + e.message);
    }
}

// Initialize combo page when navigated to
document.addEventListener('DOMContentLoaded', function() {
    // Will be called by app.js when combo page is shown
});
