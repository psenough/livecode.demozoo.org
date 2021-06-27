#!/usr/bin/env python

"""Update cache of Shadertoy and TIC-80 overview images"""

from pathlib import Path
import sys

ROOT_PATH = (Path(__file__).parent / '..').absolute()
sys.path.append(str(ROOT_PATH))

from generator.files import load_json_files

import download_shadertoy_overviews as download_shadertoy_overview
import download_tic80_cart_overview as download_tic80_cart_overview


def main() -> None:
    public_path = ROOT_PATH / Path('public')
    data_path = public_path / 'data'
    media_path = public_path / 'media'

    events = load_json_files(data_path)

    for event in events:
        download_shadertoy_overview.create_cache(event, media_path)
        download_tic80_cart_overview.create_cache(event, media_path)


if __name__ == '__main__':
    main()
