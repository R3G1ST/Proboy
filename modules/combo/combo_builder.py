#!/usr/bin/env python3
"""Proboy Combo Builder — Quick setup presets"""

import json
import os
import logging

logger = logging.getLogger("proboy.combo")

PRESETS_FILE = "/opt/proboy/presets.json"


class ComboBuilder:
    def __init__(self):
        self.presets = self._load_presets()
        self.active_preset = None

    def _load_presets(self):
        """Load presets from JSON file."""
        if os.path.exists(PRESETS_FILE):
            try:
                with open(PRESETS_FILE) as f:
                    data = json.load(f)
                return data.get("presets", [])
            except Exception:
                pass
        return []

    def list_presets(self):
        """List all available presets."""
        return self.presets

    def get_preset(self, preset_id):
        """Get a specific preset by ID."""
        for p in self.presets:
            if p.get("id") == preset_id:
                return p
        return None

    def apply_preset(self, preset_id):
        """Apply a preset configuration."""
        preset = self.get_preset(preset_id)
        if not preset:
            return {"success": False, "error": f"Preset {preset_id} not found"}

        self.active_preset = preset
        components = preset.get("components", {})

        logger.info(f"Applying preset: {preset.get('name', preset_id)}")

        return {
            "success": True,
            "preset": preset_id,
            "components": components,
            "message": f"Preset '{preset.get('name', preset_id)}' applied"
        }

    def save_custom(self, name, components):
        """Save a custom preset."""
        custom = {
            "id": "custom",
            "name": name,
            "description": "Custom configuration",
            "icon": "⚙️",
            "components": components
        }

        # Update or add
        for i, p in enumerate(self.presets):
            if p.get("id") == "custom":
                self.presets[i] = custom
                break
        else:
            self.presets.append(custom)

        # Save to file
        try:
            with open(PRESETS_FILE, "w") as f:
                json.dump({"presets": self.presets}, f, indent=2, ensure_ascii=False)
            return {"success": True}
        except Exception as e:
            return {"success": False, "error": str(e)}
