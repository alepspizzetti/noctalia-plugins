from __future__ import annotations

import time

from .process import paste_text, run_process, run_shell


def execute_action(action: dict) -> None:
    action_type = action.get("type", "")
    value = action.get("value", "")
    delay_ms = int(action.get("delayMs", 0) or 0)

    if action_type == "runCommand":
        if value:
            run_shell(value)
    elif action_type == "openUrl":
        if value:
            run_process(["xdg-open", value])
    elif action_type == "notify":
        if value:
            run_process(["notify-send", "BindHub", value])
    elif action_type == "typeText":
        if value:
            if "\n" in value:
                paste_text(value)
            else:
                run_process(["wtype", value])
    elif action_type == "delay":
        pass
    else:
        raise ValueError(f"unsupported action type: {action_type}")

    if delay_ms > 0:
        time.sleep(delay_ms / 1000.0)
