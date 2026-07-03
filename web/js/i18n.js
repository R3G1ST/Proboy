/* Proboy i18n — Multi-language support (RU/EN) */
const i18n = {
    ru: {
        // Sidebar
        dashboard: 'Панель',
        combo: 'Комбо',
        proxy: 'Прокси',
        zapret: 'Zapret',
        games: 'Игры',
        network: 'Сеть',
        subscriptions: 'Подписки',
        authors: 'Авторы',
        update: 'Обновление',
        settings: 'Настройки',
        // Status
        running: 'Работает',
        stopped: 'Остановлен',
        enabled: 'Включён',
        disabled: 'Отключён',
        not_configured: 'Не настроен',
        checking: 'Проверка...',
        // Dashboard
        dashboard_title: 'Панель управления',
        dashboard_desc: 'Proboy x FreeLink — Свобода интернета для людей',
        system_info: 'Информация о системе',
        os: 'ОС',
        router: 'Роутер',
        cpu: 'Процессор',
        ram: 'Оперативная память',
        flash: 'Флеш-память',
        arch: 'Архитектура',
        // Actions
        start: 'Запустить',
        stop: 'Остановить',
        restart: 'Перезапустить',
        save: 'Сохранить',
        cancel: 'Отмена',
        apply: 'Применить',
        // Combo
        combo_title: 'Комбо Builder',
        combo_desc: 'Быстрая настройка пресетов',
        preset_gamer: 'Геймер',
        preset_max: 'Максимум',
        preset_min: 'Минимум',
        preset_stream: 'Стриминг',
        preset_free: 'Свобода',
        // Zapret
        zapret_title: 'Настройки Zapret',
        strategy: 'Стратегия',
        strategy_auto: 'Авто',
        strategy_general: 'Общая',
        strategy_aggressive: 'Агрессивная',
        // Games
        games_title: 'Игровой фильтр',
        steam: 'Steam',
        epic: 'Epic Games',
        riot: 'Riot Games',
        blizzard: 'Blizzard',
        ea: 'EA',
        sony: 'PlayStation',
        microsoft: 'Xbox',
        nintendo: 'Nintendo',
        // Network
        network_title: 'Анализатор сети',
        dpi检测: 'Обнаружение DPI',
        port_test: 'Тест портов',
        dns_check: 'Проверка DNS',
        // Subscriptions
        sub_title: 'Подписки',
        sub_url: 'URL подписки',
        sub_add: 'Добавить',
        sub_remove: 'Удалить',
        // Settings
        settings_title: 'Настройки',
        dns_provider: 'DNS провайдер',
        dns_cloudflare: 'Cloudflare',
        dns_google: 'Google',
        dns_adguard: 'AdGuard',
        ipv6: 'IPv6',
        youtube_opt: 'Оптимизация YouTube',
        failover: 'Автопереключение',
        web_panel: 'Веб-панель',
        web_port: 'Порт панели',
        language: 'Язык',
        // Update
        update_title: 'Обновление',
        current_version: 'Текущая версия',
        latest_version: 'Последняя версия',
        check_update: 'Проверить обновления',
        do_update: 'Обновить',
        // Authors
        authors_title: 'Авторы',
        // Footer
        version: 'Версия',
        alpha: 'АЛЬФА'
    },
    en: {
        // Sidebar
        dashboard: 'Dashboard',
        combo: 'Combo Builder',
        proxy: 'Proxy',
        zapret: 'Zapret',
        games: 'Games',
        network: 'Network',
        subscriptions: 'Subscriptions',
        authors: 'Authors',
        update: 'Update',
        settings: 'Settings',
        // Status
        running: 'Running',
        stopped: 'Stopped',
        enabled: 'Enabled',
        disabled: 'Disabled',
        not_configured: 'Not configured',
        checking: 'Checking...',
        // Dashboard
        dashboard_title: 'Dashboard',
        dashboard_desc: 'Proboy x FreeLink — Internet Freedom for People',
        system_info: 'System Info',
        os: 'OS',
        router: 'Router',
        cpu: 'CPU',
        ram: 'RAM',
        flash: 'Flash',
        arch: 'Architecture',
        // Actions
        start: 'Start',
        stop: 'Stop',
        restart: 'Restart',
        save: 'Save',
        cancel: 'Cancel',
        apply: 'Apply',
        // Combo
        combo_title: 'Combo Builder',
        combo_desc: 'Quick preset configuration',
        preset_gamer: 'Gamer',
        preset_max: 'Maximum',
        preset_min: 'Minimum',
        preset_stream: 'Streaming',
        preset_free: 'Freedom',
        // Zapret
        zapret_title: 'Zapret Settings',
        strategy: 'Strategy',
        strategy_auto: 'Auto',
        strategy_general: 'General',
        strategy_aggressive: 'Aggressive',
        // Games
        games_title: 'Game Filter',
        steam: 'Steam',
        epic: 'Epic Games',
        riot: 'Riot Games',
        blizzard: 'Blizzard',
        ea: 'EA',
        sony: 'PlayStation',
        microsoft: 'Xbox',
        nintendo: 'Nintendo',
        // Network
        network_title: 'Network Analyzer',
        dpi检测: 'DPI Detection',
        port_test: 'Port Test',
        dns_check: 'DNS Check',
        // Subscriptions
        sub_title: 'Subscriptions',
        sub_url: 'Subscription URL',
        sub_add: 'Add',
        sub_remove: 'Remove',
        // Settings
        settings_title: 'Settings',
        dns_provider: 'DNS Provider',
        dns_cloudflare: 'Cloudflare',
        dns_google: 'Google',
        dns_adguard: 'AdGuard',
        ipv6: 'IPv6',
        youtube_opt: 'YouTube Optimizer',
        failover: 'Failover',
        web_panel: 'Web Panel',
        web_port: 'Panel Port',
        language: 'Language',
        // Update
        update_title: 'Update',
        current_version: 'Current Version',
        latest_version: 'Latest Version',
        check_update: 'Check for Updates',
        do_update: 'Update',
        // Authors
        authors_title: 'Authors',
        // Footer
        version: 'Version',
        alpha: 'ALPHA'
    }
};

// Current language
let currentLang = localStorage.getItem('proboy-lang') || 'ru';

function t(key) {
    return i18n[currentLang]?.[key] || i18n['en']?.[key] || key;
}

function setLang(lang) {
    currentLang = lang;
    localStorage.setItem('proboy-lang', lang);
    document.documentElement.lang = lang;
    updateAllTranslations();
}

function updateAllTranslations() {
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        el.textContent = t(key);
    });
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
        const key = el.getAttribute('data-i18n-placeholder');
        el.placeholder = t(key);
    });
}
