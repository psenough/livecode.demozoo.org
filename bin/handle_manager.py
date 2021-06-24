from pathlib import Path
import sys

import requests

sys.path.append('.')
from generator.files import load_json, save_json


HANDLES_DB_FILE = Path('./cache/handles.json')


def get_db():
    return load_json(HANDLES_DB_FILE)


def get_demozoo_data(id):
    req = requests.get(f'https://demozoo.org/api/v1/releasers/{id}/').json()
    return req


def get_handle_from_id(id):
    id = str(id) # Make sure the id is interpreted as a str.
    db = get_db()
    if id not in db.keys(): #If the handle isn't on the db, we add it
        data = get_demozoo_data(id)
        name = data.get('name')
        if name:
            db[id] = data.get('name')
            save_json(db, HANDLES_DB_FILE)
        else :
            raise Exception(f"Can't find name for demozoo id : {id}")
    return db.get(id)
