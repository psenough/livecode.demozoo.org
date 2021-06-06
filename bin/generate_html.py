#!/usr/bin/python
# -*- coding: utf-8 -*-
# https://www.shadertoy.com/media/shaders/tlBcD1.jpg

import codecs
import json
import glob

from ebbe import grouped, with_is_first
import jinja2
from htmlmin import minify

import download_shadertoy_overviews as download_shadertoy_overview
import download_tic80_cart_overview as download_tic80_cart_overview
import handle_manager as handle_manager

# Jinja2 Template system
templateEnv = jinja2.Environment(
    loader=jinja2.FileSystemLoader(searchpath="./templates/")
)
template = templateEnv.get_template("index.html")

# Use 'started' date to sort from latest to oldest
data = sorted(
    [json.load(codecs.open(d, encoding="utf-8")) for d in glob.glob("./data/**")],
    key=lambda a: a["started"],
    reverse=True,
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

# Compiling files
for html_filename,events in pages_year:
    with codecs.open(html_filename, "w", "utf-8") as outFile:
        outFile.write(
            minify(
                template.render(events=events, 
                                menu_year_navigation=menu_year_navigation,
                                current_filename=html_filename,
                                handles_demozoo=handle_manager.get_handle_from_id # Resolution will be done at render time
                )
            )
        )
