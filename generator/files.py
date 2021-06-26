from __future__ import annotations
import json
from pathlib import Path
from typing import Any


def write_text_file(path: Path, data: str) -> None:
    """Write text to file."""
    path.write_text(data, encoding='utf-8')


def save_json(data: Any, path: Path, **kwargs) -> None:
    """Save data as JSON to file."""
    with path.open(encoding='utf-8', 'w') as f:
        json.dump(data, f, **kwargs)


def load_json(path: Path) -> Any:
    """Load data from JSON file."""
    with path.open() as f:
        return json.load(f)


def load_json_files(path: Path) -> list[Any]:
    """Load data from all JSON files in path."""
    return [load_json(p) for p in path.glob('*.json')]
