import json
from pathlib import Path
from typing import Iterator, Optional
import requests

HANDLES_DB_FILE = Path("cache/handles.json")


def _get_db():
    return json.load(HANDLES_DB_FILE.open(encoding='utf-8'))


def update_demozoo_handles_db(events: list) -> None:
    db = _get_db()

    demozoo_ids = _collect_demozoo_ids(events)
    for demozoo_id in demozoo_ids:
        if demozoo_id not in db.keys():
            db[demozoo_id] = _get_demozoo_name(demozoo_id)
    with HANDLES_DB_FILE.open('w', encoding='utf-8') as f:
        json.dump(db, f)


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


def replace_with_demozoo_handle(events: list[dict]) -> None:
    handles_db = _get_db()

    for event in events:
        for phase in event.get('phases', []):
            for entry in phase['entries']:
                demozoo_id = _get_demozoo_id(entry)
                if demozoo_id:
                    entry['handle']['demozoo_name'] = handles_db[demozoo_id]

            for staff in phase['staffs']:
                demozoo_id = _get_demozoo_id(staff)
                if demozoo_id:
                    staff['handle']['demozoo_name'] = handles_db[demozoo_id]

        for staff in event['staffs']:
            demozoo_id = _get_demozoo_id(staff)
            if demozoo_id:
                staff['handle']['demozoo_name'] = handles_db[demozoo_id]
