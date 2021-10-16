from __future__ import annotations

from pathlib import Path

from .files import load_json, save_json
import requests

PARTY_SERIE_DB_FILE = Path('./cache/party_series.json')


def _collect_demozoo_ids(events: list[dict]) -> set[str]:
    demozoo_ids: set[str] = set()
    demozoo_ids = {
        event.get('demozoo_serie_id')
        for event in events
        if "demozoo_serie_id" in event and event.get('demozoo_serie_id')
    }
    return demozoo_ids


def update_db(events: list) -> None:
    db = load_json(PARTY_SERIE_DB_FILE)
    demozoo_ids = _collect_demozoo_ids(events)
    for demozoo_id in demozoo_ids:
        if str(demozoo_id) not in db.keys():
            db[demozoo_id] = _get_demozoo_data(demozoo_id)
    save_json(db, PARTY_SERIE_DB_FILE)


def _get_demozoo_data(demozoo_party_series):
    """Retrieve name for id from Demozoo."""
    url = f'https://demozoo.org/api/v1/party_series/{demozoo_party_series}/'
    data = requests.get(url).json()

    name = data.get('name')
    website = data.get('website')
    if not name:
        raise Exception(
            f"Can't find series for Demozoo id '{demozoo_party_series}'"
        )

    return {'name': name, 'website': website}


def load_db():
    return {int(k): v for k, v in load_json(PARTY_SERIE_DB_FILE).items()}
