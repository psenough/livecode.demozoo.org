from __future__ import annotations
import hashlib
from pathlib import Path
from typing import Any

import requests

from .files import load_json, save_json


HANDLES_DB_FILE = Path('./cache/handles.json')


def hash_handle(handle_obj: dict[str, Any]) -> str:
    """Get either Demozoo id or, if not found, generate hash from name."""
    return (
        handle_obj.get('demozoo_id')
        or _generate_md5_hash(handle_obj['name'].lower())[:6]
    )


def _generate_md5_hash(s: str) -> str:
    """Generate MD5 hex digest."""
    return hashlib.md5(s.encode('utf-8')).hexdigest()


def get_handle_from_id(id) -> str:
    """Return name for id as found on Demozoo."""
    id = str(id)  # Make sure the id is interpreted as a string.

    db = load_json(HANDLES_DB_FILE)

    if id not in db.keys():  # If the handle isn't on the db, we add it.
        db[id] = _get_demozoo_name(id)
        save_json(db, HANDLES_DB_FILE)

    return db.get(id)


def _get_demozoo_name(id) -> str:
    """Retrieve name for id from Demozoo."""
    url = f'https://demozoo.org/api/v1/releasers/{id}/'
    data = requests.get(url).json()

    name = data.get('name')
    if not name:
        raise Exception(f"Can't find name for Demozoo id '{id}'")

    return name
