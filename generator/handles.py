from pathlib import Path

import requests

from .files import load_json, save_json


HANDLES_DB_FILE = Path('./cache/handles.json')


def _get_db():
    return load_json(HANDLES_DB_FILE)


def _get_demozoo_data(id):
    url = f'https://demozoo.org/api/v1/releasers/{id}/'
    return requests.get(url).json()


def get_handle_from_id(id) -> str:
    id = str(id)  # Make sure the id is interpreted as a string.

    db = _get_db()
    if id not in db.keys():  # If the handle isn't on the db, we add it.
        data = _get_demozoo_data(id)
        name = data.get('name')
        if not name:
            raise Exception(f"Can't find name for demozoo id '{id}'")

        db[id] = name
        save_json(db, HANDLES_DB_FILE)

    return db.get(id)
