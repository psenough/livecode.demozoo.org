from pathlib import Path
import sys

sys.path.append('.')
from generator.files import load_json, save_json


for path in Path('data').glob('*.json'):
    data = load_json(path)

    for p in data['phases']:
        for e in p['entries']:
            if e.get('tic80_cart_id'):
                e['tic80_cart_id'] = int(e['tic80_cart_id'])
            e['source_file'] = e.get('shader_file')
            del e['shader_file']

    save_json(data, path, indent=4)
