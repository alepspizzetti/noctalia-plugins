#!/usr/bin/env python3
"""Skeleton for the future BindHub global hotkey daemon."""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[1]
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

from common.settings import load_settings


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="BindHub hotkey daemon")
    parser.add_argument("--settings", required=True, help="path to BindHub settings.json")
    parser.add_argument("--once", action="store_true", help="load config once and exit")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    settings_path = Path(args.settings)
    settings = load_settings(settings_path)
    enabled_hotkeys = [hotkey for hotkey in settings.get("hotkeys", []) if hotkey.get("enabled") is not False]

    print(f"BindHub hotkey daemon skeleton loaded {len(enabled_hotkeys)} enabled hotkey(s)")

    if args.once:
        return 0

    while True:
        time.sleep(30)


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(0)
    except Exception as exc:
        print(f"BindHub hotkey daemon error: {exc}", file=sys.stderr)
        raise SystemExit(1)
