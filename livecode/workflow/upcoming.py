import json
import codecs
from pathlib import Path
import string
BASE_FUTURE_PATH = Path("./public/data/future")
def _generate_filename(started,type,title):
    started = started.replace('-','_')
    type = type.replace(" ","_").lower()
    title = ''.join([x for x in title if x not in string.punctuation]).replace(" ","_").lower() 
    return f"{started}_{type}_{title}.json"
def create_upcoming(title:str, started:str, type:str, website:str, flyer:str ,  contact, looking_for_participant):
    base = {
        "title": title,
        "started": started,
        "type": type,
        "website": website or "",
        "flyer": flyer or "",
        "software_used": [
        
        ],
        "looking_for_participant":looking_for_participant,
        "staffs": []
    }
    if contact:
        base['staffs'] = [
            {
            "handle": {
                "name": contact,
                "demozoo_id": None
            },
            "job": "Contact"
            }
        ]

    outfile_path = BASE_FUTURE_PATH / _generate_filename(started,type,title)
    if not outfile_path.exists():
        json.dump(base, codecs.open(outfile_path,"w","UTF-8"), indent=4)
    else : 
        print(f"File {outfile_path} already exists")
        exit(1)

