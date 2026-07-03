#!/usr/bin/env python3
"""Proboy Game Filter — Universal gaming DPI bypass"""

import subprocess
import os
import json
import logging

logger = logging.getLogger("proboy.gamefilter")

INSTALL_DIR = "/opt/proboy"
GAME_SERVERS_DIR = f"{INSTALL_DIR}/game-servers"
NFTABLES_DIR = f"{INSTALL_DIR}/nftables"


class GameFilter:
    def __init__(self):
        self.enabled = False
        self.mode = "universal"  # universal, discord, fortnite, games
        self.active_games = []

    def list_games(self):
        """List all game server databases."""
        games = []
        if os.path.isdir(GAME_SERVERS_DIR):
            for f in sorted(os.listdir(GAME_SERVERS_DIR)):
                if f.endswith(".json"):
                    try:
                        with open(f"{GAME_SERVERS_DIR}/{f}") as fp:
                            data = json.load(fp)
                        games.append({
                            "name": data.get("name", f),
                            "description": data.get("description", ""),
                            "file": f
                        })
                    except Exception:
                        pass
        return games

    def start(self, mode="universal"):
        """Start game filter with the given mode."""
        logger.info(f"Starting game filter (mode: {mode})")

        # Apply game filter nftables rules
        nft_file = f"{NFTABLES_DIR}/nftables-game.nft"
        if os.path.exists(nft_file):
            try:
                subprocess.run(["nft", "-f", nft_file], check=False, timeout=5)
                self.enabled = True
                self.mode = mode
                logger.info("Game filter started")
                return True
            except Exception as e:
                logger.error(f"Failed to start game filter: {e}")

        self.enabled = True
        self.mode = mode
        return True

    def stop(self):
        """Stop game filter."""
        logger.info("Stopping game filter...")
        self.enabled = False
        return True

    def status(self):
        """Check game filter status."""
        return {
            "enabled": self.enabled,
            "mode": self.mode,
            "active_games": self.active_games
        }

    def get_game_ports(self, game_name):
        """Get port list for a specific game."""
        game_file = f"{GAME_SERVERS_DIR}/{game_name.lower()}.json"
        if os.path.exists(game_file):
            with open(game_file) as f:
                data = json.load(f)
            return data.get("ports", {})
        return {}
