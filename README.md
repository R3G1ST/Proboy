<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0%20Phoenix-00e5ff?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/status-ALPHA-ff9100?style=for-the-badge" alt="ALPHA">
  <img src="https://img.shields.io/badge/license-MIT-00e676?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/OpenWrt-24.10+-00bcd4?style=for-the-badge" alt="OpenWrt">
  <img src="https://img.shields.io/badge/Hysteria-2.9.3-ff6b35?style=for-the-badge" alt="Hysteria2">
  <img src="https://img.shields.io/badge/zapret-v72.12-9b59b6?style=for-the-badge" alt="zapret">
</p>

<p align="center">
  <a href="#-русский">🇷🇺 Русский</a> •
  <a href="#-english">🇬🇧 English</a>
</p>

---

# 🇷🇺 Русский

<p align="center">
  <b>Proboy x FreeLink — Свобода интернета для людей</b><br>
  Анти-цензурный пакет для OpenWrt роутеров
</p>

---

### Что такое Proboy?

> ⚠️ **ALPHA VERSION** — Проект находится в стадии альфа-тестирования. Возможны ошибки и нестабильная работа.

Proboy — это анти-цензурный пакет для OpenWrt роутеров, который объединяет:

| Компонент | Описание |
|-----------|----------|
| 🛡️ **50+ стратегий zapret** | Flowseal ALT 1-12, FAKE TLS AUTO, SIMPLE FAKE, bol-van |
| 🎮 **Универсальный игровой режим** | Steam, Epic, Riot, Blizzard, EA, PS5, Xbox, Nintendo |
| 🎯 **PS5 поддержка** | Автоопределение (MAC/IP), NAT Type 2, UPnP, PSN Store |
| 🔍 **Анализатор сети** | Определение DPI, тест портов, DNS-подмена, автонастройка |
| 🎯 **Combo Builder** | Пресеты: Геймер, Максимум, Минимум, Стриминг, Свобода |
| 📡 **Подписки** | Native + Clash, v2rayN, Happ, Sing-box, WireGuard |
| 🔄 **Failover** | Автопереключение при падении сервера |
| 🔒 **DNS-over-HTTPS/TLS** | Шифрованный DNS от подмены |
| 📺 **YouTube оптимизатор** | 4K без замедления |
| 📡 **IPv6 bypass** | Полная поддержка IPv6 блокировок |
| 📲 **Telegram уведомления** | О падениях, переключениях, обновлениях |
| 🌐 **Multi-language** | Русский + Английский |

---

### Установка

```bash
# Одна команда для установки
sh <(curl -sL https://raw.githubusercontent.com/R3G1ST/Proboy/main/install.sh)

# Или клонируй и установи
git clone https://github.com/R3G1ST/Proboy.git /opt/proboy
cd /opt/proboy
sudo ./install.sh
```

---

### Обновление

```bash
# Обновить до последней версии
sh <(curl -sL https://raw.githubusercontent.com/R3G1ST/Proboy/main/update.sh)

# Или если уже установлен
sudo /opt/proboy/update.sh

# Проверить наличие обновлений (без установки)
sudo /opt/proboy/update.sh --check
```

Обновление автоматически:
- Сохраняет вашу конфигурацию
- Обновляет скрипты, модули, стратегии, списки
- Обновляет бинарники (zapret, Hysteria2, sing-box)
- Восстанавливает ваши настройки
- Перезапускает сервисы

---

### Управление

```bash
proboy start      # Запустить все сервисы
proboy stop       # Остановить все сервисы
proboy restart    # Перезапустить
proboy status     # Показать статус
```

### Удаление

```bash
/opt/proboy/uninstall.sh
```

---

### Веб-панель

После установки открой:

```
http://ip-роутера:8080
```

---

### Combo Builder — Быстрая настройка

| Пресет | Компоненты |
|--------|-----------|
| 🎮 **Геймер** | Proxy + Zapret + Games + PS5 + DNS |
| 🚀 **Максимум** | ВСЕ компоненты |
| ⚡ **Минимум** | Только Proxy + Zapret |
| 📺 **Стриминг** | Proxy + YouTube + DNS |
| 🌐 **Свобода** | Всё кроме PS5/Telegram |
| 🔧 **Свой** | Кастомная комбинация |

---

### Подписки

Proboy поддерживает ВСЕ форматы подписок:

| Формат | Источник |
|--------|----------|
| FreeLink native | `hysteria2://`, `vless://`, `trojan://`, `ss://` |
| Clash | YAML конфиг |
| v2rayN | base64 |
| Happ | JSON |
| Sing-box | JSON |
| WireGuard | Полный конфиг или QR |
| Ручной | URI строка |

---

### Поддерживаемые роутеры

Proboy автоматически определяет модель вашего роутера:

| Бренд | Модели |
|-------|--------|
| Xiaomi | Mi Router, Redmi Router, AX серия |
| TP-Link | Archer, Deco, OneMesh |
| ASUS | RT-AX, GT-AX, TUF |
| Keenetic | Viva, Skipper, Giga |
| Netgear | Nighthawk, Orbi |
| GL.iNet | Beryl, Flint, Mango |
| D-Link | DIR, DIR-X |
| Zyxel | NBG, WSM |
| Huawei | AX серия |
| Tenda | AC, AX серия |
| И другие... | Авто-определение по модели |

---

### Структура проекта

```
proboy/
├── install.sh                    # Красивый установщик
├── update.sh                     # Безопасное обновление
├── uninstall.sh                  # Удаление (генерируется)
├── README.md                     # Этот файл
├── LICENSE                       # MIT
├── VERSION                       # 1.0.0
├── scripts/
│   ├── proboy.sh                 # Главный менеджер
│   ├── webserver.sh              # Веб-сервер (busybox httpd)
│   └── detect_system.sh          # Определение системы
├── web/                          # Веб-панель
│   ├── index.html
│   ├── css/proboy.css
│   ├── js/app.js, api.js, i18n.js
│   ├── cgi-bin/proboy-api        # CGI API handler
│   └── modules/                  # Страницы
├── strategies/                   # 14 стратегий zapret
│   ├── general.sh                # Общая
│   ├── fake-tls-auto.sh          # FAKE TLS AUTO
│   ├── discord.sh                # Discord
│   ├── youtube.sh                # YouTube
│   ├── telegram.sh               # Telegram
│   ├── gaming.sh                 # Игры
│   ├── fortnite.sh               # Fortnite
│   ├── cs2.sh                    # CS2
│   ├── psn.sh                    # PlayStation Network
│   ├── steam.sh, epic.sh         # Другие платформы
│   ├── aggressive.sh             # Максимальный обход
│   └── auto.sh                   # Авто-выбор
├── modules/                      # Python модули
│   ├── zapret/, gamefilter/
│   ├── ps5/, network/, dns/
│   ├── youtube/, ipv6/
│   ├── subscriptions/, failover/
│   └── combo/
├── game-servers/                 # IP базы серверов
├── lists/                        # Списки блокировок
├── nftables/                     # Правила файрвола
├── presets.json                  # Пресеты Combo Builder
└── bin/                          # Бинарники (скачиваются)
```

---

### Авторы и благодарности

| Автор | Проект | ⭐ | Что используем |
|-------|--------|-----|----------------|
| **R3G1ST** | [FreeLink](https://github.com/R3G1ST/FreeLink) + Proboy | - | Панель управления + OpenWrt пакет |
| **bol-van** | [zapret](https://github.com/bol-van/zapret) | 15.6k | Движок DPI bypass (nfqws/tpws) |
| **Flowseal** | [zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) | 30.4k | Проверенные стратегии DPI |
| **apernet** | [Hysteria 2](https://github.com/apernet/hysteria) | 22k | QUIC-протокол прокси |
| **SagerNet** | [sing-box](https://github.com/SagerNet/sing-box) | 16k | Универсальная прокси платформа |
| **itdoginfo** | [podkop](https://github.com/itdoginfo/podkop) | 2k | Вдохновение архитектурой |
| **OpenWrt** | [OpenWrt](https://github.com/openwrt/openwrt) | - | ОС для роутеров |

**Благодарности:**
- **bol-van** — за создание zapret, основы DPI bypass на OpenWrt
- **Flowseal** — за тестирование стратегий против российского DPI
- **itdoginfo** — за podkop, вдохновивший архитектуру Proboy
- **apernet** — за Hysteria2, быстрейший QUIC-прокси
- **SagerNet** — за sing-box, универсальную прокси платформу
- **Сообщество OpenWrt** — за ОС для роутеров
- **Всем контрибьюторам** — кто тестирует и улучшает проект

---

### Лицензия

MIT License — см. [LICENSE](LICENSE)

---

# 🇬🇧 English

<p align="center">
  <b>Proboy x FreeLink — Internet Freedom for People</b><br>
  Anti-censorship suite for OpenWrt routers
</p>

---

### What is Proboy?

> ⚠️ **ALPHA VERSION** — This project is in alpha testing. Bugs and instability may occur.

Proboy is an anti-censorship package for OpenWrt routers that combines:

| Component | Description |
|-----------|-------------|
| 🛡️ **50+ zapret strategies** | Flowseal ALT 1-12, FAKE TLS AUTO, SIMPLE FAKE, bol-van |
| 🎮 **Universal game mode** | Steam, Epic, Riot, Blizzard, EA, PS5, Xbox, Nintendo |
| 🎯 **PS5 support** | Auto-detection (MAC/IP), NAT Type 2, UPnP, PSN Store |
| 🔍 **Network analyzer** | DPI detection, port scan, DNS poisoning check, auto-config |
| 🎯 **Combo Builder** | Presets: Gamer, Maximum, Minimum, Streaming, Freedom |
| 📡 **Subscriptions** | Native + Clash, v2rayN, Happ, Sing-box, WireGuard |
| 🔄 **Failover** | Auto-switch between servers on failure |
| 🔒 **DNS-over-HTTPS/TLS** | Encrypted DNS, prevent poisoning |
| 📺 **YouTube optimizer** | 4K streaming without throttle |
| 📡 **IPv6 bypass** | Full IPv6 DPI bypass support |
| 📲 **Telegram notifications** | Status, failover, update alerts |
| 🌐 **Multi-language** | Russian + English |

---

### Installation

```bash
# One command install
sh <(curl -sL https://raw.githubusercontent.com/R3G1ST/Proboy/main/install.sh)

# Or clone and install
git clone https://github.com/R3G1ST/Proboy.git /opt/proboy
cd /opt/proboy
sudo ./install.sh
```

---

### Update

```bash
# Update to latest version
sh <(curl -sL https://raw.githubusercontent.com/R3G1ST/Proboy/main/update.sh)

# Or if already installed
sudo /opt/proboy/update.sh

# Check for updates without installing
sudo /opt/proboy/update.sh --check
```

The updater automatically:
- Backs up your configuration
- Updates scripts, modules, strategies, lists
- Updates binaries (zapret, Hysteria2, sing-box)
- Restores your settings
- Restarts services

---

### Usage

```bash
proboy start      # Start all services
proboy stop       # Stop all services
proboy restart    # Restart all services
proboy status     # Show status
```

### Uninstall

```bash
/opt/proboy/uninstall.sh
```

---

### Web Panel

After installation, access the web panel at:

```
http://your-router-ip:8080
```

---

### Combo Builder — Quick Setup

| Preset | Components |
|--------|-----------|
| 🎮 **Gamer** | Proxy + Zapret + Games + PS5 + DNS |
| 🚀 **Maximum** | ALL components |
| ⚡ **Minimum** | Proxy + Zapret only |
| 📺 **Streaming** | Proxy + YouTube + DNS |
| 🌐 **Freedom** | Everything except PS5/Telegram |
| 🔧 **Custom** | Your own combination |

---

### Subscriptions

Proboy supports ALL subscription formats:

| Format | Source |
|--------|--------|
| FreeLink native | `hysteria2://`, `vless://`, `trojan://`, `ss://` |
| Clash | YAML config |
| v2rayN | base64 encoded |
| Happ | JSON |
| Sing-box | JSON |
| WireGuard | Full config or QR |
| Manual | URI string |

---

### Supported Routers

Proboy auto-detects your router model:

| Brand | Models |
|-------|--------|
| Xiaomi | Mi Router, Redmi Router, AX series |
| TP-Link | Archer, Deco, OneMesh |
| ASUS | RT-AX, GT-AX, TUF |
| Keenetic | Viva, Skipper, Giga |
| Netgear | Nighthawk, Orbi |
| GL.iNet | Beryl, Flint, Mango |
| D-Link | DIR, DIR-X |
| Zyxel | NBG, WSM |
| Huawei | AX series |
| Tenda | AC, AX series |
| And more... | Auto-detect by model name |

---

### Project Structure

```
proboy/
├── install.sh                    # Beautiful installer with ASCII banner
├── update.sh                     # Safe in-place updater
├── uninstall.sh                  # Uninstaller (generated)
├── README.md                     # This file
├── LICENSE                       # MIT
├── VERSION                       # 1.0.0
├── scripts/
│   ├── proboy.sh                 # Core manager (start/stop/restart)
│   ├── webserver.sh              # Web server (busybox httpd)
│   └── detect_system.sh          # System detection (OS, router, CPU, RAM)
├── web/                          # Web panel
│   ├── index.html
│   ├── css/proboy.css
│   ├── js/app.js, api.js, i18n.js
│   ├── cgi-bin/proboy-api        # CGI API handler
│   └── modules/                  # Pages
├── strategies/                   # 14 zapret strategies
│   ├── general.sh                # General bypass
│   ├── fake-tls-auto.sh          # FAKE TLS AUTO
│   ├── discord.sh                # Discord optimized
│   ├── youtube.sh                # YouTube optimized
│   ├── telegram.sh               # Telegram optimized
│   ├── gaming.sh                 # Universal gaming
│   ├── fortnite.sh               # Fortnite optimized
│   ├── cs2.sh                    # CS2 optimized
│   ├── psn.sh                    # PlayStation Network
│   ├── steam.sh, epic.sh         # Other platforms
│   ├── aggressive.sh             # Maximum bypass
│   └── auto.sh                   # Auto-selected
├── modules/                      # Python modules
│   ├── zapret/, gamefilter/
│   ├── ps5/, network/, dns/
│   ├── youtube/, ipv6/
│   ├── subscriptions/, failover/
│   └── combo/
├── game-servers/                 # Game server IP databases
├── lists/                        # Block lists
├── nftables/                     # Firewall rules
├── presets.json                  # Combo Builder presets
└── bin/                          # Binaries (downloaded on install)
```

---

### Authors & Credits

| Author | Project | ⭐ | What We Use |
|--------|---------|-----|-------------|
| **R3G1ST** | [FreeLink](https://github.com/R3G1ST/FreeLink) + Proboy | - | VPN panel + OpenWrt package |
| **bol-van** | [zapret](https://github.com/bol-van/zapret) | 15.6k | DPI bypass engine (nfqws/tpws) |
| **Flowseal** | [zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) | 30.4k | Tested DPI strategies |
| **apernet** | [Hysteria 2](https://github.com/apernet/hysteria) | 22k | QUIC-based proxy protocol |
| **SagerNet** | [sing-box](https://github.com/SagerNet/sing-box) | 16k | Universal proxy platform |
| **itdoginfo** | [podkop](https://github.com/itdoginfo/podkop) | 2k | Architecture inspiration |
| **OpenWrt** | [OpenWrt](https://github.com/openwrt/openwrt) | - | Router OS |

**Acknowledgments:**
- **bol-van** — for creating zapret, the foundation of DPI bypass on OpenWrt
- **Flowseal** — for testing and documenting strategies against Russian DPI
- **itdoginfo** — for podkop, which inspired Proboy's architecture
- **apernet** — for Hysteria2, the fastest QUIC-based proxy
- **SagerNet** — for sing-box, the universal proxy platform
- **OpenWrt community** — for the router OS that makes this possible
- **All contributors** — who test and improve the project

---

### License

MIT License — see [LICENSE](LICENSE)

---

<p align="center">
  <b>Proboy x FreeLink — Internet Freedom for People</b><br>
  <a href="https://github.com/R3G1ST/Proboy">github.com/R3G1ST/Proboy</a> •
  <a href="https://github.com/R3G1ST/FreeLink">github.com/R3G1ST/FreeLink</a>
</p>
