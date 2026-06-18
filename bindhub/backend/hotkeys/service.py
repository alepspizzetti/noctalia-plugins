from __future__ import annotations

from actions.handlers import execute_action
from macros.service import execute_macro


def find_hotkey(settings: dict, hotkey_id: str) -> dict | None:
    for hotkey in settings.get("hotkeys", []):
        if hotkey.get("id") == hotkey_id:
            return hotkey
    return None


def execute_hotkey(settings: dict, hotkey_id: str) -> None:
    hotkey = find_hotkey(settings, hotkey_id)
    if not hotkey:
        raise ValueError(f"hotkey not found: {hotkey_id}")
    if hotkey.get("enabled") is False:
        raise ValueError(f"hotkey disabled: {hotkey_id}")

    if hotkey.get("mode") == "macro":
        macro_id = hotkey.get("macroId", "")
        if not macro_id:
            raise ValueError(f"hotkey has no macro target: {hotkey_id}")
        execute_macro(settings, macro_id)
        return

    execute_action({
        "type": hotkey.get("actionType", "runCommand"),
        "value": hotkey.get("payload", ""),
        "delayMs": 0,
    })
