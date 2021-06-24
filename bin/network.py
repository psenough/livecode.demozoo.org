from __future__ import annotations
from pathlib import Path
import sys
from typing import Iterator

sys.path.append('.')
from generator.files import load_json_files
from generator.handles import get_handle_from_id


def get_opponent_pairs(path: Path) -> Iterator[tuple[str, str]]:
    for data in load_json_files(path):
        for phase in data['phases']:
            entries = phase['entries']
            for a in entries:
                for b in entries:
                    if a != b:
                        handle_a = get_handle(a['handle'])
                        handle_b = get_handle(b['handle'])
                        if handle_a != handle_b:
                            yield handle_a, handle_b


def get_handle(handle_dict: dict) -> str:
    demozoo_id = handle_dict.get('demozoo_id')
    if demozoo_id:
        return get_handle_from_id(demozoo_id).lower()
    else:
        return handle_dict['name'].lower()


if __name__ == '__main__':
    path = Path('data')

    print('source,target')
    for opponent1, opponent2 in get_opponent_pairs(path):
        print(f'{opponent1},{opponent2}')
