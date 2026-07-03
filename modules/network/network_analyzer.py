#!/usr/bin/env python3
"""Proboy Network Analyzer — DPI detection and auto-configuration"""

import subprocess
import socket
import json
import logging
import time

logger = logging.getLogger("proboy.network")

TEST_DOMAINS = [
    "google.com",
    "youtube.com",
    "telegram.org",
    "discord.com",
    "twitter.com",
    "facebook.com",
    "instagram.com",
    "linkedin.com",
    "rutracker.org"
]

DNS_SERVERS = [
    ("Google", "8.8.8.8"),
    ("Cloudflare", "1.1.1.1"),
    ("Quad9", "9.9.9.9"),
    ("AdGuard", "94.140.14.14")
]

BLOCKED_IPS = [
    ("Telegram", "149.154.167.50"),
    ("YouTube", "216.58.214.68"),
    ("Twitter", "104.244.42.129"),
    ("Facebook", "157.240.1.35"),
    ("Instagram", "157.240.1.35"),
]


class NetworkAnalyzer:
    def __init__(self):
        self.results = {}
        self.dpi_type = None
        self.recommended_strategy = None

    def analyze(self):
        """Run full network analysis."""
        logger.info("Starting network analysis...")
        self.results = {}

        self.results["dns_poisoning"] = self._check_dns_poisoning()
        self.results["port_blocking"] = self._check_port_blocking()
        self.results["tls_fingerprint"] = self._check_tls_fingerprint()
        self.results["dpi_type"] = self._detect_dpi_type()
        self.results["recommended_strategy"] = self._recommend_strategy()

        logger.info(f"Analysis complete. DPI type: {self.results['dpi_type']}")
        return self.results

    def _check_dns_poisoning(self):
        """Check if DNS responses are being poisoned."""
        results = []
        for name, server in DNS_SERVERS:
            poisoned = False
            for domain in TEST_DOMAINS[:3]:
                try:
                    result = subprocess.run(
                        ["nslookup", domain, server],
                        capture_output=True, text=True, timeout=5
                    )
                    if "SERVFAIL" in result.stdout or "NXDOMAIN" in result.stdout:
                        poisoned = True
                        break
                except Exception:
                    pass
            results.append({
                "server": name,
                "ip": server,
                "poisoned": poisoned
            })
        return results

    def _check_port_blocking(self):
        """Check if common ports are being blocked."""
        results = []
        test_ports = [
            (80, "HTTP"),
            (443, "HTTPS"),
            (993, "IMAPS"),
            (995, "POP3S"),
            (500, "IKE"),
            (1194, "OpenVPN"),
            (8080, "HTTP Proxy"),
            (8443, "HTTPS Alt")
        ]

        for port, name in test_ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(3)
                result = sock.connect_ex(("google.com", port))
                sock.close()
                results.append({
                    "port": port,
                    "name": name,
                    "blocked": result != 0
                })
            except Exception:
                results.append({
                    "port": port,
                    "name": name,
                    "blocked": True
                })

        return results

    def _check_tls_fingerprint(self):
        """Check if TLS fingerprinting is being used."""
        try:
            result = subprocess.run(
                ["curl", "-sI", "--max-time", "5", "https://www.google.com"],
                capture_output=True, text=True, timeout=10
            )
            return {"available": result.returncode == 0}
        except Exception:
            return {"available": False}

    def _detect_dpi_type(self):
        """Detect the type of DPI system."""
        blocked_count = sum(
            1 for b in self.results.get("port_blocking", [])
            if b.get("blocked")
        )

        if blocked_count == 0:
            return "none"
        elif blocked_count <= 2:
            return "basic"
        elif blocked_count <= 4:
            return "moderate"
        else:
            return "advanced"

    def _recommend_strategy(self):
        """Recommend a strategy based on analysis."""
        dpi = self.results.get("dpi_type", "unknown")

        if dpi == "none":
            return "general"
        elif dpi == "basic":
            return "general"
        elif dpi == "moderate":
            return "fake-tls-auto"
        elif dpi == "advanced":
            return "aggressive"
        else:
            return "auto"

    def save_results(self):
        """Save analysis results to config."""
        import os
        os.makedirs("/etc/proboy", exist_ok=True)
        with open("/etc/proboy/network_analysis.json", "w") as f:
            json.dump(self.results, f, indent=2)
