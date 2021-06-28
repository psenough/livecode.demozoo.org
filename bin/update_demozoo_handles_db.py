#!/usr/bin/env python

"""Update database of Demozoo ID to name mappings"""

from pathlib import Path
import sys

ROOT_PATH = (Path(__file__).parent / '..').absolute()
sys.path.append(str(ROOT_PATH))

from generator.files import load_json_files
from generator.handles import update_db


def main() -> None:
    public_path = ROOT_PATH / Path('public')
    data_path = public_path / 'data'

    past_events = load_json_files(data_path)
    future_events = load_json_files(data_path / 'future')
    events = past_events + future_events

    update_db(events)


if __name__ == '__main__':
    main()
