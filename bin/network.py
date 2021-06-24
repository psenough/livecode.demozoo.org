from pathlib import Path
import sys

sys.path.append('.')
from generator.files import load_json_files
from generator.handles import get_handle_from_id


print("source,target")

for data in load_json_files(Path('data')):
    for p in data['phases']:
        for e in p['entries']:
            for f in p['entries']:
                if e != f:
                    e_handle = e['handle'].get('demozoo_id')
                    if e_handle:
                        e_handle = get_handle_from_id(e_handle).lower()
                    else :
                        e_handle = e['handle']['name'].lower()

                    f_handle = f['handle'].get('demozoo_id')
                    if f_handle:
                        f_handle = get_handle_from_id(f_handle).lower()
                    else :
                        f_handle = e['handle']['name'].lower()
                    if f_handle != e_handle:
                        print(f"{e_handle},{f_handle}")
