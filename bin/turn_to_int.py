import json
import glob
import codecs

files = glob.glob('data/*')
for f in files :
    data = json.load(codecs.open(f,'r','utf-8'))
    for p in data['phases']:
        for e in p['entries']:
            if e.get('tic80_cart_id'):
                e['tic80_cart_id'] = int(e['tic80_cart_id'])
            e['source_file'] = e.get('shader_file')
            del e['shader_file']
    json.dump(data,codecs.open(f,'w','utf-8'),indent=4)