from __future__ import annotations
from pathlib import Path
import sys
from typing import Iterator

sys.path.append('.')
from generator.files import load_json_files
from generator.handles import load_db


def get_opponent_pairs(path: Path) -> Iterator[tuple[str, str]]:
    handles_db = load_db()

    for data in load_json_files(path):
        for phase in data['phases']:
            entries = phase['entries']
            for a in entries:
                for b in entries:
                    if a != b:
                        handle_a = get_handle(handles_db, a['handle'])
                        handle_b = get_handle(handles_db, b['handle'])
                        if handle_a != handle_b:
                            yield handle_a, handle_b


def get_handle(db, handle_dict: dict) -> str:
    demozoo_id = handle_dict.get('demozoo_id')
    if demozoo_id:
        return db[str(demozoo_id)].lower()
    else:
        return handle_dict['name'].lower()


if __name__ == '__main__':
    path = Path('public/data')

    print('source,target')
    for opponent1, opponent2 in get_opponent_pairs(path):
        print(f'{opponent1},{opponent2}')
