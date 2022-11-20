import codecs
import sys
import json
import datetime
import copy
from pathlib import Path, PurePosixPath
PUBLIC_PATH = Path("public")
DATA_PATH =  Path("data")
SHADER_SOURCE_PATH = Path("shader_file_sources")
MEDIA_PATH = Path("media")

TEMPLATE = {
        "title": "Byte Battle Casuals",
        "started": None, # "2022-05-02",
        "date": None, # "02 - 05 June 2022",
        "type": None,
        "vod": None,
        "website": "",
        "flyer": "",
        "software_used": [
            {
                "name": "TIC-80",
                "url": "https://tic80.com/",
                "version": "tic80showdown v07",
                "purpose": "Graphic"
            }
        ], 

        "staffs": [  
            {
                "handle": {
                    "name": "aldroid",
                    "demozoo_id": 63755
                },
                "job": "Organizers"
            }
        ]
    }
def generate_byte_battle(template, nb_byte_battle, date):
    
    phases = []
    paths = create_paths(date,'byte_battle')

    for nb in range(1, nb_byte_battle+1):
        phases.append(
            {
                "title": f"Byte Battle #{nb}",
                "entries": [
                    {
                        "id": None,
                        "rank": None,
                        "points": None,
                        "handle": {
                            "name": None,
                            "demozoo_id": None
                        },
                        "shadertoy_url": None,
                        "source_file": (paths["base_source_file"] / Path('replace.lua')).as_posix(),
                        "preview_image": (paths["base_preview_image"] / Path('replace.gif')).as_posix(),
                 
                    },
                    {
                        "id": None,
                        "rank": None,
                        "points": None,
                        "handle": {
                            "name": None,
                            "demozoo_id": None
                        },
                        "shadertoy_url": None,
                        "source_file":(paths["base_source_file"] / Path('replace.lua')).as_posix(),
                        "preview_image":  (paths["base_preview_image"] / Path('replace.gif')).as_posix(),
                        
                    }
                ] ,
                "staffs": [
                    {
                        "handle": {
                            "name": "aldroid",
                            "demozoo_id": 63755
                        },
                        "job": "Commentator"
                    }
                ]
            }
        )
    
    template["phases"]=phases
    template['started']=date.strftime('%Y-%m-%d')
    template['date']=date.strftime('%d %B %Y')
    template['type']='Byte Battle'


    with codecs.open(paths['data_file_path'],'w','UTF-8') as f:
        json.dump(template, f, indent=4)


def generate_byte_jam(template, nb_byte_jam_participant, date):
    paths = create_paths(date,'byte_jam')

    phase = {
                "title": f"Byte Jam",
                "entries": [],
                 "staffs": [
                    {
                        "handle": {
                            "name": "aldroid",
                            "demozoo_id": 63755
                        },
                        "job": "Commentator"
                    }
                ]
            }
    for _ in range(0, nb_byte_jam_participant):
        phase['entries'].append(
            {
                        "id": None,
                        "rank": None,
                        "points": None,
                        "handle": {
                            "name": None,
                            "demozoo_id": None
                        },
                        "shadertoy_url": None,
                        "source_file":(paths["base_source_file"] / Path('replace.lua')).as_posix(),
                        "preview_image":  (paths["base_preview_image"] / Path('replace.gif')).as_posix(),
                    }
        )
       
    template['started']=date.strftime('%Y-%m-%d')
    template['date']=date.strftime('%d %B %Y')
    template['type']='Byte Jam'
    template['phases'] = [phase]

    with codecs.open(paths['data_file_path'],'w','UTF-8') as f:
        json.dump(template, f, indent=4)
 

def create_paths(date, type:str):
    base_name = date.strftime(f'%Y_%m_%d_{type}_fieldfx_casual')
    base_name_path = Path(f'{base_name}') 

    data_file_path = PUBLIC_PATH / DATA_PATH / Path(f'{base_name}.json')
    shader_directory_path = SHADER_SOURCE_PATH / base_name_path
    media_directory_path = MEDIA_PATH / base_name_path 

    (PUBLIC_PATH / media_directory_path).mkdir(exist_ok=True, parents=True)
    open(PUBLIC_PATH / media_directory_path / Path('.empty'),'a').close()

    (PUBLIC_PATH / shader_directory_path).mkdir(exist_ok=True, parents=True)
    open(PUBLIC_PATH / shader_directory_path / Path('.empty'),'a').close()

    return {
        'base_source_file': Path("/shader_file_sources") / base_name_path,
        'base_preview_image':base_name_path,
        'data_file_path': data_file_path.as_posix(),
        'shader_direcotry_path': shader_directory_path.as_posix(),
        'media_directory_path': media_directory_path.as_posix()
    }
if __name__ == "__main__":
    nb_match_byte_battle = int(sys.argv[1])
    nb_participant_byte_jam =int(sys.argv[2])
    date = sys.argv[3]
    date = datetime.datetime.strptime(date, "%Y-%m-%d")

    
    generate_byte_battle(copy.deepcopy(TEMPLATE), nb_match_byte_battle, date)
    generate_byte_jam(copy.deepcopy(TEMPLATE), nb_participant_byte_jam, date)