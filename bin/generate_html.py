#!/usr/bin/python
# -*- coding: utf-8 -*-
# https://www.shadertoy.com/media/shaders/tlBcD1.jpg

import codecs
import json
import glob

import jinja2
from htmlmin.minify import html_minify

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

# No more code, only template from jinja2 + minifier
with codecs.open("index.html", "w", "utf-8") as outFile:
    outFile.write(
        html_minify(
            template.render(events=data)
        )
    )