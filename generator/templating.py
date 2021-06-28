from __future__ import annotations
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, StrictUndefined, Template


def create_env(searchpath: Path) -> Environment:
    """Create template environment that loads from file system."""
    loader = FileSystemLoader(searchpath=searchpath)
    return Environment(loader=loader, undefined=StrictUndefined)


ENV = create_env(Path('templates'))


def get_template(name: str) -> Template:
    """Load a template."""
    return ENV.get_template(name)


def render_template(name: str, **context: dict[str, Any]) -> str:
    """Render a template."""
    template = get_template(name)
    return template.render(context)
