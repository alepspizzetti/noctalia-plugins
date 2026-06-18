from __future__ import annotations

import subprocess
from pathlib import Path

from common.settings import load_settings
from hotkeys.niri import (
    DEFAULT_NIRI_BINDHUB_FILE,
    DEFAULT_NIRI_CONFIG,
    ensure_include,
    render_bindhub_file,
)


def _read_if_exists(path: Path) -> str | None:
    if path.exists():
        return path.read_text(encoding="utf-8")
    return None


def _restore(path: Path, content: str | None) -> None:
    if content is None:
        if path.exists():
            path.unlink()
        return
    path.write_text(content, encoding="utf-8")


def sync_niri_hotkeys(settings_path: Path, reload_config: bool = True) -> Path:
    settings = load_settings(settings_path)
    config_path = DEFAULT_NIRI_CONFIG
    bindhub_path = DEFAULT_NIRI_BINDHUB_FILE

    if not config_path.exists():
        raise FileNotFoundError(f"niri config file not found: {config_path}")

    original_config = _read_if_exists(config_path)
    original_bindhub = _read_if_exists(bindhub_path)

    bindhub_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        config_text = original_config or ""
        bindhub_text = render_bindhub_file(settings)

        config_path.write_text(ensure_include(config_text), encoding="utf-8")
        bindhub_path.write_text(bindhub_text, encoding="utf-8")

        validate = subprocess.run(
            ["niri", "validate", "-c", str(config_path)],
            check=False,
            capture_output=True,
            text=True,
        )
        if validate.returncode != 0:
            raise RuntimeError(validate.stderr.strip() or validate.stdout.strip() or "niri validate failed")

        if reload_config:
            subprocess.run(["niri", "msg", "action", "load-config-file"], check=True)

        return bindhub_path
    except Exception:
        _restore(config_path, original_config)
        _restore(bindhub_path, original_bindhub)
        raise
