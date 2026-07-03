#!/usr/bin/env python3
"""Proboy Zapret API endpoint"""

import json
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from zapret.zapret_manager import ZapretManager

manager = ZapretManager()


def handle_request(action, params=None):
    if action == "list_strategies":
        return json.dumps(manager.list_strategies())
    elif action == "start":
        strategy = (params or {}).get("strategy", "auto")
        return json.dumps({"success": manager.start(strategy)})
    elif action == "stop":
        return json.dumps({"success": manager.stop()})
    elif action == "status":
        return json.dumps(manager.status())
    elif action == "test":
        strategy = (params or {}).get("strategy", "auto")
        return json.dumps(manager.test_strategy(strategy))
    return json.dumps({"error": "unknown action"})


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "status"
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    print(handle_request(action, params))
