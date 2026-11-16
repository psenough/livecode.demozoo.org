import glob 
import json
import codecs
import collections

names = json.load(codecs.open('../cache/handles.json','r','UTF-8'))
db = collections.defaultdict(list)


for d in glob.glob('../data/*.json'):
    d = json.load(codecs.open(d,"r","UTF-8"))
    for p in d['phases']:
        for e in p['entries']:
            n = names.get(str(e['handle']['demozoo_id']),e['handle']['name'])
            #print(e)
            image = e.get("preview_image")
            if not image:
                shadertoy = e.get('shadertoy_url')
                if shadertoy:
                    image = shadertoy.split('/')[-1]+".jpg"
            if image:
                db[n].append({
                    "image":image,
                    "date": d["started"],
                    "event": f"{d['title']}"
                })
print('------------------------------------')
groups = [ f'{{"content": "{s[0]}", "id": "{s[0]}", "value": {e}, className:"participant"}}' for e,s in enumerate(sorted(db.items(),key=lambda a:len(a[1]),reverse=True))]
print(',\n'.join(groups))
print('------------------------------------')

entries = []
for e,(k,v) in enumerate(db.items()):
    for ee,i in enumerate(v):
        year = int(i['date'][:4])
        month = int(i['date'][5:7])
        day = int(i['date'][8:])
    
        entries.append(f'{{start: new Date({year}, {month}, {day}), group:"{k}", className:"entry", content:"<img src=\\"../media/{i["image"]}\\" height=\\"100px\\"/>",id:"{k}-{e}-{ee}"}}'),

print(',\n'.join(entries))
