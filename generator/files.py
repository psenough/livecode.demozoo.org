from __future__ import annotations
import json
from pathlib import Path
from typing import Any


def write_text_file(path: Path, data: str) -> None:
    """Write text to file."""
    path.write_text(data, encoding='utf-8')


def load_json(path: Path) -> Any:
    """Load data from JSON file."""
    with path.open() as f:
        return json.load(f)


def load_json_files(path: Path) -> list[Any]:
    """Load data from all JSON files in path."""
    return [load_json(p) for p in path.glob('*.json')]
