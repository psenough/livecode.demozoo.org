#!/usr/bin/env python

from __future__ import annotations
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
import sys

ROOT_PATH = (Path(__file__).parent / '..').absolute()
sys.path.append(str(ROOT_PATH))

from generator.files import load_json_files
from generator.handles import _get_demozoo_id, hash_handle
from generator.handles import load_db as load_demozoo_handles_db
from generator.handles import update_db as update_demozoo_handles_db
from generator.party_series import update_db as update_demozoo_party_series_db
from generator.party_series import load_db as load_demozoo_party_series_db
from generator.html import render_html_file

import download_shadertoy_overviews as download_shadertoy_overview
import download_tic80_cart_overview as download_tic80_cart_overview


@dataclass(frozen=True)
class NavItem:
    href: str
    label: str
    item_id: str


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


def add_demozoo_names(events: list[dict]) -> None:
    handles_db = load_demozoo_handles_db()

    for event in events:
        for phase in event.get('phases', []):
            for entry in phase['entries']:
                demozoo_id = _get_demozoo_id(entry)
                if demozoo_id:
                    entry['handle']['demozoo_name'] = handles_db[demozoo_id]

            for staff in phase['staffs']:
                demozoo_id = _get_demozoo_id(staff)
                if demozoo_id:
                    staff['handle']['demozoo_name'] = handles_db[demozoo_id]

        for staff in event['staffs']:
            demozoo_id = _get_demozoo_id(staff)
            if demozoo_id:
                staff['handle']['demozoo_name'] = handles_db[demozoo_id]


def group_events_by_year(events) -> dict[int, list[dict]]:
    # For keeping page not overloaded, we divide per year, which means
    # 1 year = 1 page to generate.
    events_by_year = defaultdict(list)
    for event in events:
        year = int(event['started'][0:4])
        events_by_year[year].append(event)
    return events_by_year


def get_events_html_filename(year: int, latest_year: int) -> str:
    # The latest year will be `index.html`, others will be `%Y.html`.
    return 'index.html' if year == latest_year else f'{year}.html'


def assemble_nav_items(years: set[int], latest_year: int) -> list[NavItem]:
    nav_items_events = [
        NavItem(
            href=get_events_html_filename(year, latest_year),
            label=str(year),
            item_id=f'events-{year}',
        )
        for year in sorted(years)
    ]

    return (
        [NavItem(href='about.html', label='About', item_id='about')]
        + nav_items_events
        + [NavItem(href='upcoming.html', label='Upcoming', item_id='upcoming')]
    )


def generate_html_pages(
    html_path: Path,
    past_events: list[dict],
    future_events: list[dict],
    events_by_year: dict[int, list[dict]],
    latest_year: int,
    nav_items: list[NavItem],
    party_series: list[dict],
) -> None:
    generate_events_html_pages(
        html_path, events_by_year, latest_year, nav_items, party_series
    )

    render_about_html_page(html_path / 'about.html', nav_items, party_series)
    render_upcoming_html_page(
        html_path / 'upcoming.html', nav_items, future_events, party_series
    )
    generate_party_series_html_pages(
        html_path, past_events, nav_items, party_series
    )
    generate_performers_html_pages(
        html_path, past_events, nav_items, party_series
    )


def generate_events_html_pages(
    html_path: Path,
    events_by_year: dict[int, list[dict]],
    latest_year,
    nav_items: list[NavItem],
    party_series: list[dict],
) -> None:
    for year, events in events_by_year.items():
        html_filename = get_events_html_filename(year, latest_year)
        render_event_html_page(
            html_path / html_filename, year, events, nav_items, party_series
        )


def generate_party_series_html_pages(
    html_path: Path,
    past_events: list[dict],
    nav_items: list[NavItem],
    party_series,
) -> None:
    party_series_data = collect_party_series_data(past_events)
    party_series_info_data = load_demozoo_party_series_db()
    party_series_info_data  = {v['id']:v for v in party_series_info_data.values()}
    party_series_path = html_path / 'party_series'
    party_series_path.mkdir(exist_ok=True)
    for id, entries in party_series_data.items():
        render_party_series_html_page(
        party_series_path / f'{id}.html',
        id,
        entries,
        party_series_info_data.get(id),
        nav_items,
        party_series
        )


def generate_performers_html_pages(
    html_path: Path,
    past_events: list[dict],
    nav_items: list[NavItem],
    party_series,
) -> None:
    performer_pages, staff_page, performer_data = collect_performers_data(
        past_events
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
            party_series,
        )


def collect_party_series_data(
    events,
):
    party_series_info_data = load_demozoo_party_series_db()
    party_series = defaultdict(lambda: [])
    for event in events:
        if event.get('demozoo_party_id'):
            party_serie_id = party_series_info_data[event.get('demozoo_party_id')]['id']
            party_series[party_serie_id].append(event)
    return party_series


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
    filename: Path,
    year: str,
    events,
    nav_items: list[NavItem],
    party_series: list[dict],
) -> None:
    render_html_file(
        'events.html',
        {
            'nav_items': nav_items,
            'current_nav_item_id': f'events-{year}',
            'events': events,
            'current_filename': filename.name,
            'hash_handle': hash_handle,
            'party_series': party_series,
        },
        filename,
    )


def render_about_html_page(
    filename: Path, nav_items: list[NavItem], party_series
) -> None:
    render_html_file(
        'about.html',
        {
            'nav_items': nav_items,
            'current_nav_item_id': 'about',
            'party_series': party_series,
        },
        filename,
    )


def render_upcoming_html_page(
    filename: Path, nav_items: list[NavItem], future_events, party_series
) -> None:
    render_html_file(
        'upcoming.html',
        {
            'nav_items': nav_items,
            'current_nav_item_id': 'upcoming',
            'data': future_events,
            'party_series': party_series,
        },
        filename,
    )


def render_party_series_html_page(
    filename: Path,
    id,
    entries,
    metadata,
    nav_items: list[NavItem],
    party_series,
) -> None:
    render_html_file(
        'party_series.html',
        {
            'id':id,
            'entries': entries,
            'metadata': metadata,
            'nav_items': nav_items,
            'current_nav_item_id': f'party_series-{id}',
            'party_series': party_series,
            'hash_handle': hash_handle,
        },
        filename,
    )


def render_performer_html_page(
    filename: Path,
    entries,
    performer_data,
    staff_data,
    nav_items: list[NavItem],
    party_series,
) -> None:
    render_html_file(
        'performer.html',
        {
            'entries': entries,
            'performer_data': performer_data,
            'staff_data': staff_data,
            'nav_items': nav_items,
            'current_nav_item_id': None,
            'party_series': party_series,
        },
        filename,
    )


def main() -> None:
    public_path = ROOT_PATH / Path('public')
    data_path = public_path / 'data'
    html_path = public_path

    past_events = load_past_events(data_path)
    future_events = load_future_events(data_path)

    update_demozoo_handles_db(past_events + future_events)
    update_demozoo_party_series_db(past_events)

    update_image_cache(past_events, public_path / 'media')

    add_demozoo_names(past_events + future_events)

    events_by_year = group_events_by_year(past_events)

    years = set(events_by_year.keys())
    latest_year = max(years)

    nav_items = assemble_nav_items(years, latest_year)

    party_series = load_demozoo_party_series_db()
    party_series  = {v['id']:v for v in party_series.values()}
    generate_html_pages(
        html_path,
        past_events,
        future_events,
        events_by_year,
        latest_year,
        nav_items,
        party_series,
    )


if __name__ == '__main__':
    main()
