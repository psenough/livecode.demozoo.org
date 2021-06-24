"""
    Poor Man md generator from json.
    At least no dependency than Python3
"""
import sys
import json
import glob
from collections import defaultdict

if len(sys.argv) == 2:
    filenames = [sys.argv[1]]
else:
    filenames = glob.glob("public/data/*")

for filename in filenames:
    data = json.load(open(filename))

    print(f"# {data['type'] } @ {data['title']} ({data['date']})")
    print()
    if data.get("vod"):
        print(f"**Vod** : {data['vod']}")
        print()
    for p in data["phases"]:
        # Title
        title = p.get("title")
        if title:
            print(f"## {title}")
        print()
        # Entries data
        for e in p["entries"]:
            suffix = "*"
            id = ""
            pts = ""
            if e.get("rank"):
                suffix = f'{e["rank"]}.'
            if e.get("id"):
                id = f"#{e['id']}"
            if e.get("points"):
                pts = f"*{e['points']}pts*"
            print(f'{suffix} {id} **{e["handle"]}** {pts}')

        print()
        # Phase staff data
        jobs = defaultdict(list)
        for e in p["staffs"]:
            jobs[e["job"]].append(e["handle"])

        for j, h in jobs.items():
            print(f'> {j} : {", ".join(h)}')
            print()
        print()
    print()
    # Global staff data
    jobs = defaultdict(list)
    for e in data["staffs"]:
        jobs[e["job"]].append(e["handle"])

    for j, h in jobs.items():
        print(f'> {j} : {", ".join(h)}')
        print()

    print()
    print("----")
    print()
