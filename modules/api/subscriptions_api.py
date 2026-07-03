#!/usr/bin/env python3
"""Proboy Subscriptions API endpoint"""

import json
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from subscriptions.sub_manager import SubscriptionManager

sm = SubscriptionManager()


def handle_request(action, params=None):
    if action == "import_url":
        url = (params or {}).get("url", "")
        return json.dumps(sm.import_from_url(url))
    elif action == "parse":
        uri = (params or {}).get("uri", "")
        return json.dumps(sm.parse_uri(uri))
    elif action == "list":
        return json.dumps(sm.subscriptions)
    return json.dumps({"error": "unknown action"})


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "list"
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    print(handle_request(action, params))
