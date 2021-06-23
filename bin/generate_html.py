#!/usr/bin/env python

import codecs
import collections
import glob
import hashlib 
import json
from pathlib import Path

from ebbe import grouped, with_is_first
from htmlmin import minify

import download_shadertoy_overviews as download_shadertoy_overview
import download_tic80_cart_overview as download_tic80_cart_overview
from files import write_text_file
import handle_manager as handle_manager
from templating import render_template


# Use 'started' date to sort from latest to oldest
data = sorted(
    [json.load(codecs.open(d, encoding="utf-8")) for d in glob.glob("./data/*.json")],
    key=lambda a: a["started"],
    reverse=True,
)

data_future = sorted(
    [json.load(codecs.open(d, encoding="utf-8")) for d in glob.glob("./data/future/*.json")],
    key=lambda a: a["started"],
    reverse=False,
)

# Generate cache for shadertoy overview and tic80 overview
for d in data:
    download_shadertoy_overview.create_cache(d)
    download_tic80_cart_overview.create_cache(d)
# For keeping page not overloaded, we divide per year, which mean 1 year = 1 page to generate 
# As it's sorted reverse, it's should go from current year to previous year
grouped_per_year = grouped(data,key=lambda a :a["started"][0:4])

# The current year will be index.html, others will be %Y.html
menu_year_navigation = []
pages_year = []
for is_first,(year,events) in with_is_first(grouped_per_year.items()):
    html_filename = f"{year}.html"
    if is_first:
        html_filename = "index.html"
    menu_year_navigation.append((html_filename,year))
    pages_year.append((html_filename,events))

##################### Profile #####################
# This is used to either get demozoo_id or generate a hash from the if no demozoo
def hash_handle(handle_obj):
    return handle_obj.get('demozoo_id') or hashlib.md5(handle_obj.get('name').lower().encode('UTF-8')).hexdigest()[:6] 

# List of all profile with their entries
performer_pages = collections.defaultdict(lambda: collections.defaultdict(list))

# 
staff_page = collections.defaultdict(lambda: collections.defaultdict(list))

# Performer data, handle name and demozoo_id
performer_data = collections.defaultdict(dict)

# Iteration over all the event, id is used to group entries per event per performer
for id,d in enumerate(data):
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

# Generate all performer HTML files
for pid in performer_data.keys():
    performer_html = render_template(
        'performer.html',
        entries=performer_pages[pid],
        performer_data=performer_data[pid],
        staff_data=staff_page[pid],
        menu_year_navigation=menu_year_navigation,
        handles_demozoo=handle_manager.get_handle_from_id,
    )
    write_text_file(Path(f"performers/{pid}.html"), minify(performer_html))


##################### End Profile #####################


# Render HTML files

for html_filename,events in pages_year:
    html = render_template(
        'index.html',
        events=events, 
        menu_year_navigation=menu_year_navigation,
        current_filename=html_filename,
        hash_handle=hash_handle,
        handles_demozoo=handle_manager.get_handle_from_id,  # Resolution will be done at render time
    )
    write_text_file(Path(html_filename), minify(html))

about_html = render_template(
    'about.html',
    menu_year_navigation=menu_year_navigation,
)
write_text_file(Path('about.html'), minify(about_html))

upcoming_html = render_template(
    'upcoming.html',
    menu_year_navigation=menu_year_navigation,
    data=data_future,
)
write_text_file(Path('upcoming.html'), minify(upcoming_html))
