#!/usr/bin/env python

from __future__ import annotations
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
import sys

from ebbe import grouped, with_is_first

ROOT_PATH = (Path(__file__).parent / '..').absolute()
sys.path.append(str(ROOT_PATH))

from generator.files import load_json_files
from generator.handles import get_handle_from_id, hash_handle
from generator.html import render_html_file

import download_shadertoy_overviews as download_shadertoy_overview
import download_tic80_cart_overview as download_tic80_cart_overview


@dataclass(frozen=True)
class NavItem:
    href: str
    label: str


def load_past_events(data_path: Path):
    events = load_json_files(data_path)
    events = presort_events(events)
    return sorted(events, key=lambda e: e['started'], reverse=True)


def load_future_events(data_path: Path):
    events = load_json_files(data_path / 'future')
    events = presort_events(events)
    return sorted(events, key=lambda e: e['started'], reverse=False)


def presort_events(events):
    return sorted(events, key=lambda e: (e['title'], e['type']))


def update_image_cache(events, target_path: Path) -> None:
    """Update cache of Shadertoy and TIC-80 overview images."""
    for event in events:
        download_shadertoy_overview.create_cache(event, target_path)
        download_tic80_cart_overview.create_cache(event, target_path)


def collect_years(events, nav_items: list[NavItem]) -> list[tuple[str, list]]:
    # For keeping page not overloaded, we divide per year, which means
    # 1 year = 1 page to generate.
    # As it's sorted in reverse order, it should go from current year to
    # previous year.
    grouped_per_year = grouped(events, key=lambda a: a['started'][0:4])

    # The current year will be `index.html`, others will be `%Y.html`.
    pages_year = []
    for is_first, (year, events) in with_is_first(grouped_per_year.items()):
        html_filename = f'{year}.html'
        if is_first:
            html_filename = 'index.html'
        nav_items.append(NavItem(href=html_filename, label=year))
        pages_year.append((html_filename, events))

    return pages_year


def collect_performers_data(
    events,
) -> tuple[defaultdict, defaultdict, defaultdict]:
    # List of all profile with their entries
    performer_pages: defaultdict = defaultdict(lambda: defaultdict(list))

    #
    staff_page: defaultdict = defaultdict(lambda: defaultdict(list))

    # Performer data, handle name and demozoo_id
    performer_data: defaultdict = defaultdict(dict)

    # Iteration over all the event, id is used to group entries per event per performer
    for id, d in enumerate(events):
        for p in d['phases']:
            for e in p['entries']:
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


def render_event_html_page(
    filename: Path, events, nav_items: list[NavItem]
) -> None:
    render_html_file(
        'index.html',
        {
            'events': events,
            'nav_items': nav_items,
            'current_filename': filename.name,
            'hash_handle': hash_handle,
            'handles_demozoo': get_handle_from_id,  # Resolution will be done at render time
        },
        filename,
    )


def render_about_html_page(filename: Path, nav_items: list[NavItem]) -> None:
    render_html_file(
        'about.html',
        {
            'nav_items': nav_items,
        },
        filename,
    )


def render_upcoming_html_page(
    filename: Path, nav_items: list[NavItem], future_events
) -> None:
    render_html_file(
        'upcoming.html',
        {
            'nav_items': nav_items,
            'data': future_events,
        },
        filename,
    )


def render_performer_html_page(
    filename: Path,
    entries,
    performer_data,
    staff_data,
    nav_items: list[NavItem],
) -> None:
    render_html_file(
        'performer.html',
        {
            'entries': entries,
            'performer_data': performer_data,
            'staff_data': staff_data,
            'nav_items': nav_items,
            'handles_demozoo': get_handle_from_id,
        },
        filename,
    )


def main() -> None:
    public_path = ROOT_PATH / Path('public')
    data_path = public_path / 'data'
    html_path = public_path

    past_events = load_past_events(data_path)
    future_events = load_future_events(data_path)

    update_image_cache(past_events, public_path / 'media')

    nav_items = []

    pages_year = collect_years(past_events, nav_items)
    nav_items.sort(key=lambda item: item.label)

    nav_items.insert(0, NavItem(href='about.html', label='About'))
    nav_items.append(NavItem(href='upcoming.html', label='Upcoming'))

    performer_pages, staff_page, performer_data = collect_performers_data(
        past_events
    )

    for html_filename, events in pages_year:
        render_event_html_page(html_path / html_filename, events, nav_items)

    render_about_html_page(html_path / 'about.html', nav_items)
    render_upcoming_html_page(
        html_path / 'upcoming.html', nav_items, future_events
    )

    performers_path = html_path / 'performers'
    performers_path.mkdir(exist_ok=True)

    for pid in performer_data.keys():
        render_performer_html_page(
            performers_path / f'{pid}.html',
            performer_pages[pid],
            performer_data[pid],
            staff_page[pid],
            nav_items,
        )


if __name__ == '__main__':
    main()
