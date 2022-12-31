import json
from pathlib import Path
import codecs
from typing import List


import strawberry

_BASE = Path("public/data/")
_DB_EVENTS = {
    filepath.stem: json.load(codecs.open(filepath, 'r', 'UTF-8'))
    for filepath in _BASE.glob(pattern="*.json")
}
_DB_SERIES = json.load(codecs.open("cache/party_series.json", "r", "UTF-8"))

_DB_UPCOMINGS = {
    filepath.stem: json.load(codecs.open(filepath, 'r', 'UTF-8'))
    for filepath in _BASE.glob(pattern="future/*.json")
}


def get_upcomings():
    return _DB_UPCOMINGS


def get_series_from_event_id(event_id):
    return _DB_SERIES.get(str(event_id))


def get_event_from_party_serie(serie_id):
    return [
        (id, event)
        for id, event in _DB_EVENTS.items()
        if str(event.get('demozoo_party_id'))
        in [
            demozoo_party_id
            for demozoo_party_id, serie in _DB_SERIES.items()
            if serie['id'] == serie_id
        ]
    ]


def get_party_series():
    return [data for data in _DB_SERIES.values()]


def get_party_serie(id):
    return [
        data for data in _DB_SERIES.values() if str(data.get('id')) == str(id)
    ]


def get_events_from_year(year: strawberry.ID):
    return [
        (id, event)
        for id, event in _DB_EVENTS.items()
        if event['started'][0:4] == year
    ]


def get_all_events_key():
    return _DB_EVENTS.keys()


def get_all_years():
    all = {event['started'][0:4] for event in _DB_EVENTS.values()}
    return sorted(list(all))


def get_events(ids: List[strawberry.ID] = []):
    if ids == []:
        return _DB_EVENTS.items()
    return [(key, event) for key, event in _DB_EVENTS.items() if key in ids]
