#!/usr/bin/python
# -*- coding: utf-8 -*-
import codecs
import json
import glob

import jinja2

templateEnv = jinja2.Environment(
    loader=jinja2.FileSystemLoader(searchpath="./templates/")
)
template = templateEnv.get_template("index.html")

data = [json.load(codecs.open(d, encoding="utf-8")) for d in glob.glob("./data/**")]

with codecs.open("index.html", "w", "utf-8") as fh:
    fh.write(template.render(events=data))