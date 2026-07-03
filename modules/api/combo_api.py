#!/usr/bin/env python3
"""Proboy Combo API endpoint"""

import json
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from combo.combo_builder import ComboBuilder

cb = ComboBuilder()


def handle_request(action, params=None):
    if action == "list_presets":
        return json.dumps(cb.list_presets())
    elif action == "apply":
        preset_id = (params or {}).get("preset", "")
        return json.dumps(cb.apply_preset(preset_id))
    elif action == "save_custom":
        name = (params or {}).get("name", "Custom")
        components = (params or {}).get("components", {})
        return json.dumps(cb.save_custom(name, components))
    return json.dumps({"error": "unknown action"})


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "list_presets"
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    print(handle_request(action, params))
