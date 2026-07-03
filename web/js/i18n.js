/* Proboy i18n — Multi-language support */
const i18n = {
    ru: {
        dashboard: 'Dashboard',
        combo: 'Combo Builder',
        proxy: 'Proxy',
        zapret: 'Zapret',
        games: 'Games',
        network: 'Network',
        subscriptions: 'Subscriptions',
        authors: 'Authors',
        settings: 'Settings',
        running: 'Running',
        stopped: 'Stopped',
        enabled: 'Enabled',
        disabled: 'Disabled'
    },
    en: {
        dashboard: 'Dashboard',
        combo: 'Combo Builder',
        proxy: 'Proxy',
        zapret: 'Zapret',
        games: 'Games',
        network: 'Network',
        subscriptions: 'Subscriptions',
        authors: 'Authors',
        settings: 'Settings',
        running: 'Running',
        stopped: 'Stopped',
        enabled: 'Enabled',
        disabled: 'Disabled'
    }
};

function t(key, lang = 'ru') {
    return i18n[lang]?.[key] || i18n['en']?.[key] || key;
}
