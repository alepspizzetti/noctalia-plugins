from __future__ import annotations

import json
from pathlib import Path


def load_settings(path: Path) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"settings file not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))
