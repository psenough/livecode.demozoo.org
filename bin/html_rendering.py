from __future__ import annotations
from pathlib import Path
from typing import Any

from htmlmin import minify

from files import write_text_file
from templating import render_template


def render_html_file(
    template_name: str, template_context: dict[str, Any], output_path: Path
) -> None:
    """Render minified HTML from a template into a file."""
    html = render_template(template_name, **template_context)
    minified_html = minify(html)
    write_text_file(output_path, minified_html)
