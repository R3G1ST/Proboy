#!/usr/bin/env python3
"""Proboy IPv6 Bypass — Full IPv6 DPI bypass"""

import subprocess
import os
import logging

logger = logging.getLogger("proboy.ipv6")

INSTALL_DIR = "/opt/proboy"


class IPv6Manager:
    def __init__(self):
        self.enabled = False

    def start(self):
        """Start IPv6 DPI bypass."""
        logger.info("Starting IPv6 bypass")
        nft_file = f"{INSTALL_DIR}/nftables/ipv6-nftables.nft"
        if os.path.exists(nft_file):
            try:
                subprocess.run(["nft", "-f", nft_file], check=False, timeout=5)
            except Exception:
                pass
        self.enabled = True
        return True

    def stop(self):
        self.enabled = False
        return True

    def status(self):
        return {"enabled": self.enabled}
