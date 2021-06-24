#!/usr/bin/env python

from __future__ import annotations
from collections import defaultdict
import hashlib
from pathlib import Path

from ebbe import grouped, with_is_first

import sys

sys.path.append('.')
from generator.files import load_json_files
from generator.handles import get_handle_from_id
from generator.html import render_html_file

import download_shadertoy_overviews as download_shadertoy_overview
import download_tic80_cart_overview as download_tic80_cart_overview


DATA_PATH = Path('data')
HTML_PATH = Path('.')


def load_past_events():
    events = load_json_files(DATA_PATH)
    events = presort_events(events)
    return sorted(events, key=lambda e: e['started'], reverse=True)


def load_future_events():
    events = load_json_files(DATA_PATH / 'future')
    events = presort_events(events)
    return sorted(events, key=lambda e: e['started'], reverse=False)


def presort_events(events):
    return sorted(events, key=lambda e: (e['title'], e['type']))


def cache_past_events(past_events) -> None:
    """Generate cache for Shadertoy and TIC-80 overviews."""
    for event in past_events:
        download_shadertoy_overview.create_cache(event)
        download_tic80_cart_overview.create_cache(event)


def generate_md5_hash(s: str) -> str:
    """Generate MD5 hex digest."""
    return hashlib.md5(s.encode('utf-8')).hexdigest()


def hash_handle(handle_obj: dict[str, Any]) -> str:
    """Get either Demozoo id or, if not found, generate hash from name."""
    return (
        handle_obj.get('demozoo_id')
        or generate_md5_hash(handle_obj.get('name').lower())[:6]
    )


def collect_years(
    past_events,
) -> tuple[list[tuple[str, str]], list[tuple[str, list]]]:
    # For keeping page not overloaded, we divide per year, which means
    # 1 year = 1 page to generate.
    # As it's sorted in reverse order, it should go from current year to
    # previous year.
    grouped_per_year = grouped(past_events, key=lambda a: a['started'][0:4])

    # The current year will be `index.html`, others will be `%Y.html`.
    menu_year_navigation = []
    pages_year = []
    for is_first, (year, events) in with_is_first(grouped_per_year.items()):
        html_filename = f'{year}.html'
        if is_first:
            html_filename = 'index.html'
        menu_year_navigation.append((html_filename, year))
        pages_year.append((html_filename, events))

    return menu_year_navigation, pages_year


def collect_performers_data(
    past_events,
) -> tuple[defaultdict, defaultdict, defaultdict]:
    # List of all profile with their entries
    performer_pages: defaultdict = defaultdict(lambda: defaultdict(list))

    #
    staff_page: defaultdict = defaultdict(lambda: defaultdict(list))

    # Performer data, handle name and demozoo_id
    performer_data: defaultdict = defaultdict(dict)

    # Iteration over all the event, id is used to group entries per event per performer
    for id, d in enumerate(past_events):
        for p in d['phases']:
            for e in p["entries"]:
                e['event_name'] = d['title']
                e['phase_name'] = p['title']
                e['event_started'] = d['started']
                # Get the id for the filename
                handle_id = hash_handle(e['handle'])

                performer_pages[handle_id][id].append(e)
                performer_data[handle_id] = e['handle']

            for s in p['staffs']:
                handle_id = hash_handle(s['handle'])
                s['event_name'] = d['title']
                s['phase_name'] = p['title']
                s['event_started'] = d['started']
                performer_data[handle_id] = s['handle']
                staff_page[handle_id][id].append(s)

        for s in d['staffs']:
            handle_id = hash_handle(s['handle'])
            s['event_name'] = d['title']
            s['phase_name'] = None
            s['event_started'] = d['started']
            performer_data[handle_id] = s['handle']
            staff_page[handle_id][id].append(s)

    return performer_pages, staff_page, performer_data


def render_event_html_page(events, menu_year_navigation, html_filename) -> None:
    render_html_file(
        'index.html',
        {
            'events': events,
            'menu_year_navigation': menu_year_navigation,
            'current_filename': html_filename,
            'hash_handle': hash_handle,
            'handles_demozoo': get_handle_from_id,  # Resolution will be done at render time
        },
        HTML_PATH / html_filename,
    )


def render_about_html_page(menu_year_navigation) -> None:
    render_html_file(
        'about.html',
        {
            'menu_year_navigation': menu_year_navigation,
        },
        HTML_PATH / 'about.html',
    )


def render_upcoming_html_page(menu_year_navigation, future_events) -> None:
    render_html_file(
        'upcoming.html',
        {
            'menu_year_navigation': menu_year_navigation,
            'data': future_events,
        },
        HTML_PATH / 'upcoming.html',
    )


def render_performer_html_page(
    entries, performer_data, staff_data, menu_year_navigation
) -> None:
    render_html_file(
        'performer.html',
        {
            'entries': entries,
            'performer_data': performer_data,
            'staff_data': staff_data,
            'menu_year_navigation': menu_year_navigation,
            'handles_demozoo': get_handle_from_id,
        },
        HTML_PATH / 'performers' / f'{pid}.html',
    )


if __name__ == '__main__':
    past_events = load_past_events()
    future_events = load_future_events()

    cache_past_events(past_events)

    menu_year_navigation, pages_year = collect_years(past_events)

    performer_pages, staff_page, performer_data = collect_performers_data(
        past_events
    )

    for html_filename, events in pages_year:
        render_event_html_page(events, menu_year_navigation, html_filename)

    render_about_html_page(menu_year_navigation)
    render_upcoming_html_page(menu_year_navigation, future_events)

    for pid in performer_data.keys():
        render_performer_html_page(
            performer_pages[pid],
            performer_data[pid],
            staff_page[pid],
            menu_year_navigation,
        )
