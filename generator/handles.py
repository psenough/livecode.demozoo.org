from __future__ import annotations
import hashlib
from pathlib import Path
from typing import Any, Iterator, Optional

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


def load_db() -> dict[str, str]:
    return load_json(HANDLES_DB_FILE)


def update_db(events: list) -> None:
    db = load_json(HANDLES_DB_FILE)

    demozoo_ids = _collect_demozoo_ids(events)
    for demozoo_id in demozoo_ids:
        if demozoo_id not in db.keys():
            db[demozoo_id] = _get_demozoo_name(demozoo_id)

    save_json(db, HANDLES_DB_FILE)


def _collect_demozoo_ids(events: list[dict]) -> set[str]:
    demozoo_ids: set[str] = set()
    for event in events:
        demozoo_ids.update(_collect_demozoo_ids_from_event(event))
    return demozoo_ids


def _collect_demozoo_ids_from_event(event: dict) -> Iterator[str]:
    for phase in event.get('phases', []):
        for entry in phase['entries']:
            demozoo_id = _get_demozoo_id(entry)
            if demozoo_id is not None:
                yield demozoo_id

        for staff in phase['staffs']:
            demozoo_id = _get_demozoo_id(staff)
            if demozoo_id is not None:
                yield demozoo_id

    for staff in event['staffs']:
        demozoo_id = _get_demozoo_id(staff)
        if demozoo_id is not None:
            yield demozoo_id


def _get_demozoo_id(item: dict) -> Optional[str]:
    demozoo_id = item['handle']['demozoo_id']
    if not demozoo_id:
        return None

    return str(demozoo_id)


def _get_demozoo_name(demozoo_id) -> str:
    """Retrieve name for id from Demozoo."""
    url = f'https://demozoo.org/api/v1/releasers/{demozoo_id}/'
    data = requests.get(url).json()

    name = data.get('name')
    if not name:
        raise Exception(f"Can't find name for Demozoo id '{demozoo_id}'")

    return name
