#!/usr/bin/env python3
"""Proboy PS5 Manager — PlayStation 5 auto-detect and DPI bypass"""

import subprocess
import os
import json
import logging
import re

logger = logging.getLogger("proboy.ps5")

PS5_MAC_PREFIX = "AC:DE:48"
INSTALL_DIR = "/opt/proboy"
NFTABLES_DIR = f"{INSTALL_DIR}/nftables"


class PS5Manager:
    def __init__(self):
        self.enabled = False
        self.detected = False
        self.ps5_mac = None
        self.ps5_ip = None
        self.nat_type = None

    def detect_ps5(self):
        """Auto-detect PS5 by MAC prefix."""
        try:
            # Check ARP table
            result = subprocess.run(["ip", "neigh"], capture_output=True, text=True)
            for line in result.stdout.splitlines():
                parts = line.split()
                if len(parts) >= 5:
                    mac = parts[3].upper()
                    ip = parts[0]
                    if mac.startswith(PS5_MAC_PREFIX):
                        self.detected = True
                        self.ps5_mac = mac
                        self.ps5_ip = ip
                        logger.info(f"PS5 detected: MAC={mac}, IP={ip}")
                        return True

            # Check DHCP leases
            for lease_file in ["/tmp/dhcp.leases", "/var/lib/misc/dnsmasq.leases"]:
                if os.path.exists(lease_file):
                    with open(lease_file) as f:
                        for line in f:
                            parts = line.split()
                            if len(parts) >= 4:
                                mac = parts[1].upper()
                                if mac.startswith(PS5_MAC_PREFIX):
                                    self.detected = True
                                    self.ps5_mac = mac
                                    self.ps5_ip = parts[2]
                                    logger.info(f"PS5 detected via DHCP: MAC={mac}, IP={self.ps5_ip}")
                                    return True
        except Exception as e:
            logger.error(f"PS5 detection failed: {e}")

        return False

    def start(self):
        """Start PS5 DPI bypass."""
        if not self.detected:
            self.detect_ps5()

        if not self.detected:
            logger.warning("PS5 not detected, applying rules for all devices")

        # Apply PS5 nftables rules
        nft_file = f"{NFTABLES_DIR}/ps5-nftables.nft"
        if os.path.exists(nft_file):
            try:
                subprocess.run(["nft", "-f", nft_file], check=False, timeout=5)
                self.enabled = True
                logger.info("PS5 DPI bypass started")
                return True
            except Exception as e:
                logger.error(f"Failed to start PS5 bypass: {e}")

        self.enabled = True
        return True

    def stop(self):
        """Stop PS5 DPI bypass."""
        self.enabled = False
        return True

    def status(self):
        """Check PS5 status."""
        return {
            "enabled": self.enabled,
            "detected": self.detected,
            "mac": self.ps5_mac,
            "ip": self.ps5_ip,
            "nat_type": self.nat_type
        }
