from __future__ import annotations

from actions.handlers import execute_action


def find_macro(settings: dict, macro_id: str) -> dict | None:
    for macro in settings.get("macros", []):
        if macro.get("id") == macro_id:
            return macro
    return None


def execute_macro(settings: dict, macro_id: str) -> None:
    macro = find_macro(settings, macro_id)
    if not macro:
        raise ValueError(f"macro not found: {macro_id}")
    if macro.get("enabled") is False:
        raise ValueError(f"macro disabled: {macro_id}")

    for action in macro.get("actions", []):
        execute_action(action)
