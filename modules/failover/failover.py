#!/usr/bin/env python3
"""Proboy Failover Engine — Auto-switch between servers"""

import subprocess
import time
import logging
import threading

logger = logging.getLogger("proboy.failover")


class FailoverEngine:
    def __init__(self):
        self.enabled = False
        self.check_interval = 30
        self.servers = []
        self.current_server = None
        self.monitor_thread = None
        self.running = False

    def start(self, servers=None, interval=30):
        """Start failover monitoring."""
        self.enabled = True
        self.check_interval = interval
        self.servers = servers or []
        self.running = True

        if self.servers:
            self.current_server = self.servers[0]

        self.monitor_thread = threading.Thread(target=self._monitor, daemon=True)
        self.monitor_thread.start()
        logger.info(f"Failover started (interval: {interval}s)")
        return True

    def stop(self):
        """Stop failover monitoring."""
        self.enabled = False
        self.running = False
        if self.monitor_thread:
            self.monitor_thread.join(timeout=5)
        return True

    def _monitor(self):
        """Background health check loop."""
        while self.running and self.enabled:
            time.sleep(self.check_interval)
            if self.current_server:
                if not self._check_server(self.current_server):
                    logger.warning(f"Server {self.current_server.get('name', 'unknown')} failed, switching...")
                    self._switch_to_next()

    def _check_server(self, server):
        """Check if a server is reachable."""
        host = server.get("host", "")
        if not host:
            return False

        try:
            result = subprocess.run(
                ["ping", "-c", "1", "-W", "3", host],
                capture_output=True, timeout=5
            )
            return result.returncode == 0
        except Exception:
            return False

    def _switch_to_next(self):
        """Switch to the next available server."""
        if not self.servers:
            return

        current_idx = 0
        for i, s in enumerate(self.servers):
            if s == self.current_server:
                current_idx = i
                break

        for i in range(1, len(self.servers)):
            idx = (current_idx + i) % len(self.servers)
            if self._check_server(self.servers[idx]):
                self.current_server = self.servers[idx]
                logger.info(f"Switched to server: {self.current_server.get('name', 'unknown')}")
                return

        logger.error("No available servers")

    def status(self):
        return {
            "enabled": self.enabled,
            "current_server": self.current_server,
            "server_count": len(self.servers),
            "check_interval": self.check_interval
        }
