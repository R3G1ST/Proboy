#!/usr/bin/env python3
"""Proboy Subscription Manager — Import and manage VPN subscriptions"""

import json
import base64
import re
import urllib.parse
import logging

logger = logging.getLogger("proboy.subscriptions")


class SubscriptionManager:
    def __init__(self):
        self.subscriptions = []

    def parse_uri(self, uri):
        """Parse a VPN URI string."""
        uri = uri.strip()

        if uri.startswith("hysteria2://"):
            return self._parse_hysteria2(uri)
        elif uri.startswith("vless://"):
            return self._parse_vless(uri)
        elif uri.startswith("trojan://"):
            return self._parse_trojan(uri)
        elif uri.startswith("ss://"):
            return self._parse_shadowsocks(uri)
        elif uri.startswith("wg://") or "wireguard" in uri.lower():
            return self._parse_wireguard(uri)
        elif "clash" in uri.lower() or uri.endswith(".yaml"):
            return {"type": "clash", "url": uri}
        elif "v2ray" in uri.lower() or "vless" in uri.lower():
            return self._parse_v2ray(uri)
        else:
            return {"type": "unknown", "raw": uri}

    def _parse_hysteria2(self, uri):
        """Parse hysteria2:// URI."""
        try:
            # hysteria2://password@host:port?sni=example.com
            without_scheme = uri[len("hysteria2://"):]
            if "@" in without_scheme:
                auth, rest = without_scheme.split("@", 1)
                host_port = rest.split("?")[0]
                host, port = host_port.rsplit(":", 1)

                params = {}
                if "?" in rest:
                    query = rest.split("?", 1)[1]
                    for pair in query.split("&"):
                        k, v = pair.split("=", 1) if "=" in pair else (pair, "")
                        params[k] = v

                return {
                    "type": "hysteria2",
                    "host": host,
                    "port": int(port),
                    "password": auth,
                    "sni": params.get("sni", host),
                    "insecure": params.get("insecure", "0") == "1"
                }
        except Exception as e:
            logger.error(f"Failed to parse hysteria2 URI: {e}")
        return {"type": "hysteria2", "raw": uri}

    def _parse_vless(self, uri):
        """Parse vless:// URI."""
        try:
            without_scheme = uri[len("vless://"):]
            if "@" in without_scheme:
                uuid, rest = without_scheme.split("@", 1)
                host_port = rest.split("?")[0]
                host, port = host_port.rsplit(":", 1)

                params = {}
                if "?" in rest:
                    query = rest.split("?", 1)[1]
                    for pair in query.split("&"):
                        k, v = pair.split("=", 1) if "=" in pair else (pair, "")
                        params[k] = v

                return {
                    "type": "vless",
                    "host": host,
                    "port": int(port),
                    "uuid": uuid,
                    "transport": params.get("type", "tcp"),
                    "security": params.get("security", "none"),
                    "sni": params.get("sni", "")
                }
        except Exception as e:
            logger.error(f"Failed to parse vless URI: {e}")
        return {"type": "vless", "raw": uri}

    def _parse_trojan(self, uri):
        """Parse trojan:// URI."""
        try:
            without_scheme = uri[len("trojan://"):]
            if "@" in without_scheme:
                password, rest = without_scheme.split("@", 1)
                host_port = rest.split("?")[0]
                host, port = host_port.rsplit(":", 1)
                return {
                    "type": "trojan",
                    "host": host,
                    "port": int(port),
                    "password": password
                }
        except Exception as e:
            logger.error(f"Failed to parse trojan URI: {e}")
        return {"type": "trojan", "raw": uri}

    def _parse_shadowsocks(self, uri):
        """Parse ss:// URI."""
        try:
            without_scheme = uri[len("ss://"):]
            # ss://base64(method:password)@host:port
            if "@" in without_scheme:
                encoded, rest = without_scheme.split("@", 1)
                decoded = base64.b64decode(encoded + "==").decode()
                method, password = decoded.split(":", 1)
                host_port = rest.split("?")[0]
                host, port = host_port.rsplit(":", 1)
                return {
                    "type": "shadowsocks",
                    "host": host,
                    "port": int(port),
                    "method": method,
                    "password": password
                }
        except Exception as e:
            logger.error(f"Failed to parse shadowsocks URI: {e}")
        return {"type": "shadowsocks", "raw": uri}

    def _parse_wireguard(self, uri):
        """Parse WireGuard config."""
        return {"type": "wireguard", "config": uri}

    def _parse_v2ray(self, uri):
        """Parse v2rayN base64 subscription."""
        try:
            # Try base64 decode
            decoded = base64.b64decode(uri).decode()
            if decoded.startswith("{"):
                return json.loads(decoded)
            elif "://" in decoded:
                # Multiple URIs
                uris = decoded.strip().split("\n")
                return {"type": "v2ray_batch", "uris": [self.parse_uri(u) for u in uris if u.strip()]}
        except Exception:
            pass
        return {"type": "v2ray", "raw": uri}

    def import_from_url(self, url):
        """Import subscription from URL."""
        import urllib.request
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Proboy/1.0"})
            with urllib.request.urlopen(req, timeout=15) as resp:
                content = resp.read().decode()

            # Try to parse as base64
            try:
                decoded = base64.b64decode(content).decode()
                if "://" in decoded:
                    lines = decoded.strip().split("\n")
                    servers = []
                    for line in lines:
                        if "://" in line:
                            parsed = self.parse_uri(line.strip())
                            if parsed.get("type") != "unknown":
                                servers.append(parsed)
                    return {"success": True, "servers": servers, "count": len(servers)}
            except Exception:
                pass

            # Try as JSON
            try:
                data = json.loads(content)
                return {"success": True, "config": data}
            except Exception:
                pass

            # Try as single URI
            parsed = self.parse_uri(content.strip())
            if parsed.get("type") != "unknown":
                return {"success": True, "servers": [parsed], "count": 1}

            return {"success": False, "error": "Unsupported format"}
        except Exception as e:
            return {"success": False, "error": str(e)}
