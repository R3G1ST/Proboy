# Proboy x FreeLink

**Anti-censorship suite for OpenWrt — Internet Freedom for People**

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-24.10+-blue)](https://openwrt.org)
[![Hysteria](https://img.shields.io/badge/Hysteria-2.9.3-ff6b35)](https://github.com/apernet/hysteria)
[![zapret](https://img.shields.io/badge/zapret-v72.12-9b59b6)](https://github.com/bol-van/zapret)

---

## What is Proboy?

Proboy is an anti-censorship package for OpenWrt routers that combines:

- **50+ zapret strategies** (Flowseal, bol-van, community-tested)
- **Hysteria2 proxy** (QUIC-based, anti-DPI)
- **Universal game mode** (Steam, Epic, Riot, Blizzard, EA, PS5, Xbox, Nintendo)
- **PS5 console support** (LAN + WiFi, NAT Type 2, PSN Store)
- **Network analyzer** (DPI detection, auto-configuration)
- **Combo Builder** (quick setup presets)
- **Subscription support** (native + Clash, v2rayN, Happ, Sing-box)
- **Failover engine** (auto-switch between servers)
- **DNS-over-HTTPS/TLS** (encrypted DNS)
- **YouTube optimizer** (4K without throttle)
- **IPv6 bypass** (full IPv6 DPI bypass)
- **Telegram notifications** (status, failover, updates)
- **Multi-language** (RU/EN)

## Works on ALL OpenWrt versions

Proboy auto-detects your system and router model:

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
| And more... | Auto-detect by model name |

## Quick Install

```bash
# One command install
sh <(curl -sL https://raw.githubusercontent.com/R3G1ST/Proboy/main/install.sh)

# Or clone and install
git clone https://github.com/R3G1ST/Proboy.git /opt/proboy
cd /opt/proboy
sudo ./install.sh
```

## Usage

```bash
proboy start      # Start all services
proboy stop       # Stop all services
proboy restart    # Restart all services
proboy status     # Show status
```

## Web Panel

After installation, access the web panel at:

```
http://your-router-ip:8080
```

## Subscription Links

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

## Combo Builder

Quick setup presets:

| Preset | Components |
|--------|-----------|
| **Геймер** | Proxy + Zapret + Games + PS5 + DNS |
| **Максимум** | ALL components |
| **Минимум** | Proxy + Zapret only |
| **Стриминг** | Proxy + YouTube + DNS |
| **Свобода** | Everything except PS5/Telegram |
| **Свой** | Custom combination |

---

## Authors & Credits

Proboy builds upon the work of these open-source authors and projects.

### Project Authors

| Author | Role | Repository |
|--------|------|-----------|
| **R3G1ST** | FreeLink + Proboy (author) | [github.com/R3G1ST](https://github.com/R3G1ST) |

### Core Dependencies

| Author | Project | Stars | What We Use |
|--------|---------|-------|-------------|
| **bol-van** | [zapret](https://github.com/bol-van/zapret) | 15.6k | DPI bypass engine (nfqws/tpws) |
| **Flowseal** | [zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) | 30.4k | Tested DPI strategies |
| **apernet** | [Hysteria 2](https://github.com/apernet/hysteria) | 22k | QUIC-based anti-censorship proxy |
| **SagerNet** | [sing-box](https://github.com/SagerNet/sing-box) | 16k | Universal proxy platform |
| **itdoginfo** | [podkop](https://github.com/itdoginfo/podkop) | 2k | Architecture inspiration |
| **OpenWrt** | [OpenWrt](https://github.com/openwrt/openwrt) | - | Router OS (APK package manager) |

### Strategy Authors

| Author | Contribution |
|--------|-------------|
| **bol-van** | Original zapret strategies (fake, multisplit, disorder, syndata, etc.) |
| **Flowseal** | Community-tested strategies (ALT 1-12, FAKE TLS AUTO, SIMPLE FAKE) |
| **Proboy community** | Gaming strategies (Fortnite, CS2, Discord, PSN, etc.) |

### Acknowledgments

- **bol-van** — for creating zapret, the foundation of DPI bypass on OpenWrt
- **Flowseal** — for testing and documenting strategies that work against Russian DPI
- **itdoginfo** — for podkop, which inspired Proboy's architecture
- **apernet** — for Hysteria2, the fastest QUIC-based proxy
- **SagerNet** — for sing-box, the universal proxy platform
- **OpenWrt community** — for the router OS that makes this possible
- **All contributors** — who test strategies, report issues, and improve the project

### Related Projects

| Project | Description |
|---------|-------------|
| [FreeLink](https://github.com/R3G1ST/FreeLink) | Multi-server VPN management panel |
| [zapret](https://github.com/bol-van/zapret) | DPI bypass multi-platform |
| [zapret-discord-youtube](https://github.com/Flowseal/zapret-discord-youtube) | Windows DPI bypass for Discord/YouTube |
| [Hysteria 2](https://github.com/apernet/hysteria) | QUIC-based proxy |
| [sing-box](https://github.com/SagerNet/sing-box) | Universal proxy platform |
| [podkop](https://github.com/itdoginfo/podkop) | OpenWrt proxy routing |

---

## License

MIT License — see [LICENSE](LICENSE) for details.

## Support

- GitHub Issues: [github.com/R3G1ST/Proboy/issues](https://github.com/R3G1ST/Proboy/issues)
- FreeLink: [github.com/R3G1ST/FreeLink](https://github.com/R3G1ST/FreeLink)

---

**Proboy x FreeLink — Internet Freedom for People**
