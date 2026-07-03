#!/usr/bin/env python3
"""Proboy Games API endpoint"""

import json
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from gamefilter.gamefilter import GameFilter

gf = GameFilter()


def handle_request(action, params=None):
    if action == "list_games":
        return json.dumps(gf.list_games())
    elif action == "start":
        mode = (params or {}).get("mode", "universal")
        return json.dumps({"success": gf.start(mode)})
    elif action == "stop":
        return json.dumps({"success": gf.stop()})
    elif action == "status":
        return json.dumps(gf.status())
    elif action == "ports":
        game = (params or {}).get("game", "")
        return json.dumps(gf.get_game_ports(game))
    return json.dumps({"error": "unknown action"})


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "status"
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    print(handle_request(action, params))
