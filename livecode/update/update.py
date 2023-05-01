from pathlib import Path
from update.demozoo_handle import (
    update_demozoo_handles_db,
    replace_with_demozoo_handle,
)
from update.demozoo_series import update_demozoo_series_db
from update.overviews.shadertoy import download_shadertoy_overview
from update.overviews.tic80 import download_tic80_cart_overview
from update.overviews.poshbrolly import download_poshbrolly_overview
import json


def _load_events(data_path: Path):
    events = [
        json.load(p.open(encoding='utf-8')) for p in data_path.glob('*.json')
    ]
    return sorted(events, key=lambda e: e['started'], reverse=True)


def _update_image_cache(events, target_path: Path) -> None:
    """Update cache of Shadertoy and TIC-80 overview images."""
    for event in events:
        download_shadertoy_overview(event, target_path)
        download_tic80_cart_overview(event, target_path)
        download_poshbrolly_overview(event,target_path / "poshbrolly")


def update_all_data():
    """
    Set of process to update fully the database
    """
    public_path = Path('public')
    data_path = public_path / 'data'

    past_events = _load_events(data_path)
    # Future event are mainly use right now for handles caching
    future_events = _load_events(data_path / "future")

    # Handle based on demozoo db
    update_demozoo_handles_db(past_events + future_events)
    # Rewrite the json to replace the name with the one provided with demozoo
    replace_with_demozoo_handle(past_events + future_events)

    # Fetch db
    # TODO: Current hack based on int id / str id for unregistered serie.
    #     : To improve
    update_demozoo_series_db(past_events)

    # Fetch Image from shadertoy and tic80
    _update_image_cache(past_events, public_path / 'media')
