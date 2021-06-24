import json
import glob
import codecs
import handle_manager as handle_manager
print("source,target")
files = glob.glob('data/*.json')
for f in files :
    data = json.load(codecs.open(f,'r','utf-8'))
    for p in data['phases']:
        for e in p['entries']:
            for f in p['entries']:
                if e != f:
                    e_handle = e['handle'].get('demozoo_id')
                    if e_handle:
                        e_handle = handle_manager.get_handle_from_id(e_handle).lower()
                    else :
                        e_handle = e['handle']['name'].lower()
                    
                    f_handle = f['handle'].get('demozoo_id')
                    if f_handle:
                        f_handle = handle_manager.get_handle_from_id(f_handle).lower()
                    else :
                        f_handle = e['handle']['name'].lower()
                    if f_handle != e_handle:
                        print(f"{e_handle},{f_handle}")
