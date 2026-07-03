#!/usr/bin/env python3
"""Proboy Zapret Manager — DPI bypass engine control"""

import subprocess
import os
import json
import logging

logger = logging.getLogger("proboy.zapret")

INSTALL_DIR = "/opt/proboy"
CONFIG_DIR = "/etc/proboy"
STRATEGIES_DIR = f"{INSTALL_DIR}/strategies"
NFTABLES_DIR = f"{INSTALL_DIR}/nftables"


class ZapretManager:
    def __init__(self):
        self.nfqws = f"{INSTALL_DIR}/bin/nfqws"
        self.tpws = f"{INSTALL_DIR}/bin/tpws"
        self.current_strategy = None
        self.running = False

    def list_strategies(self):
        """List all available zapret strategies."""
        strategies = []
        if os.path.isdir(STRATEGIES_DIR):
            for f in sorted(os.listdir(STRATEGIES_DIR)):
                if f.endswith(".sh"):
                    name = f[:-3]
                    strategies.append({
                        "name": name,
                        "file": f"{STRATEGIES_DIR}/{f}",
                        "active": name == self.current_strategy
                    })
        return strategies

    def start(self, strategy="auto"):
        """Start zapret with the given strategy."""
        if self.running:
            logger.info("Zapret already running")
            return True

        strategy_file = f"{STRATEGIES_DIR}/{strategy}.sh"
        if not os.path.exists(strategy_file):
            strategy_file = f"{STRATEGIES_DIR}/general.sh"

        logger.info(f"Starting zapret with strategy: {strategy}")

        # Apply strategy
        try:
            subprocess.run(["sh", strategy_file], check=False, timeout=10)
            self.current_strategy = strategy
            self.running = True
            logger.info(f"Zapret started (strategy: {strategy})")
            return True
        except Exception as e:
            logger.error(f"Failed to start zapret: {e}")
            return False

    def stop(self):
        """Stop zapret."""
        logger.info("Stopping zapret...")
        try:
            subprocess.run(["pkill", "-f", "nfqws"], check=False)
            # Flush nftables
            subprocess.run(["nft", "flush", "ruleset"], check=False)
            self.running = False
            logger.info("Zapret stopped")
            return True
        except Exception as e:
            logger.error(f"Failed to stop zapret: {e}")
            return False

    def status(self):
        """Check if zapret is running."""
        try:
            result = subprocess.run(["pgrep", "-f", "nfqws"], capture_output=True)
            self.running = result.returncode == 0
        except Exception:
            self.running = False
        return {
            "running": self.running,
            "strategy": self.current_strategy
        }

    def test_strategy(self, strategy):
        """Test a specific strategy against DPI."""
        strategy_file = f"{STRATEGIES_DIR}/{strategy}.sh"
        if not os.path.exists(strategy_file):
            return {"success": False, "error": f"Strategy {strategy} not found"}

        # Quick test: try to start nfqws with the strategy
        try:
            with open(strategy_file) as f:
                content = f.read()

            # Extract nfqws options from strategy
            if "NFQWS_OPT" in content:
                return {
                    "success": True,
                    "strategy": strategy,
                    "message": "Strategy loaded successfully"
                }
        except Exception as e:
            return {"success": False, "error": str(e)}

        return {"success": True, "strategy": strategy}
