import codecs
import json 

import requests

HANDLE_DB_FILE = "./cache/handles.json"

def get_db():
    return json.load(codecs.open(HANDLE_DB_FILE,'r','utf-8'))

def get_demozoo_data(id):
    print('query')
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
            json.dump(db, codecs.open(HANDLE_DB_FILE,'w','utf-8'))
        else :
            raise Exception(f"Can't find name for demozoo id : {id}")
    return db.get(id)