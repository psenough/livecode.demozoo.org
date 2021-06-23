from pathlib import Path

from jinja2 import Environment, FileSystemLoader, Template


def create_env(searchpath: Path) -> Environment:
    """Create template environment that loads from file system."""
    loader = FileSystemLoader(searchpath=searchpath)
    return Environment(loader=loader)


ENV = create_env(Path('templates'))


def get_template(name: str) -> Template:
    """Load a template."""
    return ENV.get_template(name)
