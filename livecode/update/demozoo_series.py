from pathlib import Path
import json
import requests

PARTY_SERIE_DB_FILE = Path('./cache/party_series.json')


def update_demozoo_series_db(events: list) -> None:
    db = json.load(PARTY_SERIE_DB_FILE.open(encoding="utf-8"))
    demozoo_ids = _collect_demozoo_ids(events)
    for demozoo_id in demozoo_ids:
        if str(demozoo_id) not in db.keys():
            db[demozoo_id] = _get_demozoo_party_data(demozoo_id)
    with PARTY_SERIE_DB_FILE.open('w', encoding='utf-8') as f:
        json.dump(db, f)


def _collect_demozoo_ids(events: list[dict]) -> set[str]:
    demozoo_ids: set[str] = set()
    demozoo_ids = {
        event.get('demozoo_party_id')
        for event in events
        if "demozoo_party_id" in event and event.get('demozoo_party_id')
    }
    return demozoo_ids


def _get_demozoo_party_data(demozoo_party):
    """Retrieve name for id from Demozoo."""
    url = f'https://demozoo.org/api/v1/parties/{demozoo_party}/'
    data = requests.get(url).json()

    party_series = data.get('party_series')

    if not party_series:
        raise Exception(f"Can't find series for Demozoo id '{demozoo_party}'")

    return party_series
