from __future__ import annotations

import subprocess


def run_process(command: list[str]) -> None:
    subprocess.run(command, check=True)


def run_shell(command: str) -> None:
    subprocess.run(["sh", "-lc", command], check=True)


def paste_text(text: str) -> None:
    subprocess.run(["wl-copy"], input=text, text=True, check=True)
    subprocess.run(["wtype", "-M", "ctrl", "-M", "shift", "v"], check=True)
