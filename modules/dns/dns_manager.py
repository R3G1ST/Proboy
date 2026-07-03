#!/usr/bin/env python3
"""Proboy DNS Manager — DNS-over-HTTPS/TLS encrypted DNS"""

import subprocess
import os
import json
import logging

logger = logging.getLogger("proboy.dns")

DOH_SERVERS = [
    {"name": "Cloudflare", "url": "https://1.1.1.1/dns-query", "ips": ["1.1.1.1", "1.0.0.1"]},
    {"name": "Google", "url": "https://dns.google/dns-query", "ips": ["8.8.8.8", "8.8.4.4"]},
    {"name": "Quad9", "url": "https://dns.quad9.net/dns-query", "ips": ["9.9.9.9", "149.112.112.112"]},
    {"name": "AdGuard", "url": "https://dns.adguard.com/dns-query", "ips": ["94.140.14.14", "94.140.15.15"]},
    {"name": "OpenNIC", "url": "https://opennicproject.org/dns-query", "ips": ["185.121.177.177"]},
]

DOT_SERVERS = [
    {"name": "Cloudflare", "host": "1.1.1.1", "port": 853},
    {"name": "Google", "host": "8.8.8.8", "port": 853},
    {"name": "Quad9", "host": "9.9.9.9", "port": 853},
]


class DNSManager:
    def __init__(self):
        self.enabled = False
        self.provider = "cloudflare"
        self.mode = "doh"  # doh or dot

    def get_servers(self):
        """Return available DNS servers."""
        return {
            "doh": DOH_SERVERS,
            "dot": DOT_SERVERS
        }

    def start(self, provider="cloudflare"):
        """Start encrypted DNS."""
        logger.info(f"Starting encrypted DNS (provider: {provider})")
        self.enabled = True
        self.provider = provider

        # Apply DNS bypass nftables rules
        nft_file = "/opt/proboy/nftables/dns-bypass.nft"
        if os.path.exists(nft_file):
            try:
                subprocess.run(["nft", "-f", nft_file], check=False, timeout=5)
            except Exception:
                pass

        return True

    def stop(self):
        """Stop encrypted DNS."""
        self.enabled = False
        return True

    def status(self):
        """Check DNS manager status."""
        return {
            "enabled": self.enabled,
            "provider": self.provider,
            "mode": self.mode
        }
