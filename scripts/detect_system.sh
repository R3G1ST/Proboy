#!/bin/sh
# ═══════════════════════════════════════════════════════
# Proboy System Detector
# Detects OS, router model, CPU, RAM, architecture
# ═══════════════════════════════════════════════════════

detect_all() {
    # OS
    if [ -f /etc/openwrt_release ]; then
        . /etc/openwrt_release
        OS="openwrt"
        OS_VERSION="${DISTRIB_RELEASE}"
        OS_TARGET="${DISTRIB_TARGET}"
        OS_ARCH="${DISTRIB_ARCH}"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="${ID:-linux}"
        OS_VERSION="${VERSION_ID}"
        OS_ARCH="$(uname -m)"
    else
        OS="linux"
        OS_VERSION="$(uname -r)"
        OS_ARCH="$(uname -m)"
    fi

    # Router model
    ROUTER_MODEL=""
    [ -f /tmp/sysinfo/model ] && ROUTER_MODEL="$(cat /tmp/sysinfo/model 2>/dev/null)"
    [ -z "${ROUTER_MODEL}" ] && [ -f /proc/device-tree/model ] && ROUTER_MODEL="$(cat /proc/device-tree/model 2>/dev/null | tr '\0' ' ')"
    [ -z "${ROUTER_MODEL}" ] && [ -f /sys/class/dmi/id/product_name ] && ROUTER_MODEL="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"

    # Board
    BOARD=""
    [ -f /tmp/sysinfo/board_name ] && BOARD="$(cat /tmp/sysinfo/board_name 2>/dev/null)"

    # Brand
    BRAND="Unknown"
    case "${ROUTER_MODEL}" in
        *Xiaomi*|*Mi*)     BRAND="Xiaomi" ;;
        *TP-Link*|*TPINK*) BRAND="TP-Link" ;;
        *Netgear*)         BRAND="Netgear" ;;
        *ASUS*|*Asus*)     BRAND="ASUS" ;;
        *Keenetic*)        BRAND="Keenetic" ;;
        *GL.iNet*)         BRAND="GL.iNet" ;;
        *Zyxel*)           BRAND="Zyxel" ;;
        *Linksys*)         BRAND="Linksys" ;;
        *Ubiquiti*)        BRAND="Ubiquiti" ;;
        *MikroTik*)        BRAND="MikroTik" ;;
        *D-Link*)          BRAND="D-Link" ;;
        *Huawei*)          BRAND="Huawei" ;;
        *Tenda*)           BRAND="Tenda" ;;
        *Phicomm*)         BRAND="Phicomm" ;;
        *Realtek*)         BRAND="Realtek" ;;
    esac

    # CPU
    CPU="$(cat /proc/cpuinfo 2>/dev/null | grep -m1 'model name' | cut -d: -f2 | xargs)"
    CORES="$(nproc 2>/dev/null || echo 1)"

    # RAM
    RAM="$(free -m 2>/dev/null | awk '/Mem:/{print $2}' || echo 0)"

    # Flash
    FLASH_TOTAL="$(df -m / 2>/dev/null | tail -1 | awk '{print $2}' || echo 0)"
    FLASH_FREE="$(df -m / 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)"

    # Kernel
    KERNEL="$(uname -r)"

    # Output JSON
    cat << EOF
{
  "os": "${OS}",
  "os_version": "${OS_VERSION}",
  "os_target": "${OS_TARGET:-}",
  "os_arch": "${OS_ARCH}",
  "router_brand": "${BRAND}",
  "router_model": "${ROUTER_MODEL}",
  "board": "${BOARD}",
  "cpu": "${CPU}",
  "cpu_cores": ${CORES},
  "ram_mb": ${RAM},
  "flash_total_mb": ${FLASH_TOTAL},
  "flash_free_mb": ${FLASH_FREE},
  "kernel": "${KERNEL}"
}
EOF
}

# If run directly, output JSON
if [ "${1}" = "--json" ]; then
    detect_all
elif [ "${1}" = "--pretty" ]; then
    detect_all | python3 -m json.tool 2>/dev/null || detect_all
else
    detect_all
fi
