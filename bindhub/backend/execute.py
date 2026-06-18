#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from actions.handlers import execute_action
from common.settings import load_settings
from hotkeys.service import execute_hotkey
from hotkeys.sync import sync_niri_hotkeys
from macros.service import execute_macro


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="BindHub backend executor")
    parser.add_argument("--settings", required=True, help="path to BindHub settings.json")

    subparsers = parser.add_subparsers(dest="command", required=True)

    hotkey_parser = subparsers.add_parser("run-hotkey")
    hotkey_parser.add_argument("hotkey_id")

    macro_parser = subparsers.add_parser("run-macro")
    macro_parser.add_argument("macro_id")

    text_parser = subparsers.add_parser("type-text")
    text_parser.add_argument("text")

    sync_parser = subparsers.add_parser("sync-hotkeys")
    sync_parser.add_argument("--no-reload", action="store_true")

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    settings = load_settings(Path(args.settings))

    if args.command == "run-hotkey":
        execute_hotkey(settings, args.hotkey_id)
    elif args.command == "run-macro":
        execute_macro(settings, args.macro_id)
    elif args.command == "type-text":
        execute_action({
            "type": "typeText",
            "value": args.text,
            "delayMs": 0,
        })
    elif args.command == "sync-hotkeys":
        sync_niri_hotkeys(Path(args.settings), reload_config=not args.no_reload)
    else:
        raise ValueError(f"unknown command: {args.command}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"BindHub backend error: {exc}", file=sys.stderr)
        raise SystemExit(1)
