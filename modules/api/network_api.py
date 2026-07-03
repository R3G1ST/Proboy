#!/usr/bin/env python3
"""Proboy Network API endpoint"""

import json
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from network.network_analyzer import NetworkAnalyzer

analyzer = NetworkAnalyzer()


def handle_request(action, params=None):
    if action == "analyze":
        results = analyzer.analyze()
        analyzer.save_results()
        return json.dumps(results)
    elif action == "results":
        try:
            with open("/etc/proboy/network_analysis.json") as f:
                return f.read()
        except Exception:
            return json.dumps({"error": "no results"})
    return json.dumps({"error": "unknown action"})


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "results"
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else None
    print(handle_request(action, params))
