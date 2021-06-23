from pathlib import Path


def write_text_file(path: Path, data: str) -> None:
    """Write text to file."""
    path.write_text(data, encoding='utf-8')
