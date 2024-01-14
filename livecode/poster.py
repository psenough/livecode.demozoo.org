from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw 
from gql.schema import schema
from pprint import pprint
from pathlib import Path
from multiprocessing import Pool
GRAY = (115,122,128)
GRAY_LIGHT = (int(115*1.81),int(122*1.8),int(128*1.75))
WHITE = (247,246,242)
ORANGE = (255,145,58)
BASE_POSTER_OUT_DIRECTORY="./public/posters"
# 115,122,128
#  C:\gmic\gmic-3.3.3-cli-win64\gmic.exe -input 1920,1080,1,4,"200" fx_random3d 0,128,7.232,100,45,0,0,-100,0.5,0.7,1,1 fx_gcd_norm_eq 0.5,0.5,2,0 -output bg.png
def font_handle(font_size):
    # BinxiaoBlockletterPT1.20230218.ttf
    return ImageFont.truetype("mikannnoki-font-2.ttf", font_size)

def font_text(font_size):
    return ImageFont.truetype("x12y16pxMaruMonica.ttf", font_size)

def create_posters():
    out_dir = Path(BASE_POSTER_OUT_DIRECTORY)
    out_dir.mkdir(parents=True, exist_ok=True)
    result = schema.execute_sync(
            """{     
            allHandles {
                letter
                handles {
                displayName
                stub
                isGroup 
                    members {
                    name:displayName
                    stub
                    }
                }
            }
        }"""
        )
    call_params = []
    for letter in result.data['allHandles']:
        for performer in letter['handles']:
            stub = performer['stub']
            display_name = performer["displayName"].lower().replace(" ","_").replace("?","_")
            out_file = out_dir / f"{display_name}_poster_1920x180.png"
            call_params.append((stub, out_file))
    with Pool(8) as pool:
        pool.starmap(create_poster,call_params)
def create_poster(stub, out_file):
    result = schema.execute_sync(
        """
    query perHandle($stub:String!){
        events:eventsByHandle(stub:$stub) {
            handle {
                displayName,
                demozooId
            }
            performerEvents {
                gqlId
                title 
                type {
                  label
                  stub
                }
                started
                date
                vod
                demozooPartyId
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                phases {
                    vod
                    title
                    entries {
                        points
                        previewUrl
                        handle{
                             name:displayName
                             demozooId
                             stub
                             membersStub
                            isGroup 
                              members {
                                name:displayName
                                stub
                              }
                        }
                        rank 
                        points
                        shadertoyUrl 
                        sourceFile 
                        tic80CartId
                        poshbrollyUrl
                        vod
                    }
                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
            }
            staffEvents {
                gqlId
                title 
                type {
                  label
                  stub
                }
                started
                date
                vod
                staffs {
                    handle {
                        displayName
                        stub
                    }
                    job
                }
                demozooPartyId
                softwareUsed {
                    name
                    url
                    purpose
                    version
                }
                phases {
                    vod
                    title
                    staffs {
                        handle {
                            displayName
                            stub
                        }
                        job
                    }
                }
                partySerie {
                    name
                    website
                    demozooUrl
                    stub
                }
            }
        }
    }""",
        variable_values={"stub": stub},
    )

    perfomer_events =result.data['events']['performerEvents'] 


   



    width,height= 1920, 1080
    # im = Image.new(mode="RGBA", size=(width,height),color=GRAY)
    im = Image.open(r"bg.png")  .convert('RGBA')
  
    draw = ImageDraw.Draw(im)

    # header
    font_size = 310
    handle_title = result.data["events"]['handle']["displayName"].replace('ô','o').replace('ü','u')
  
    margin_left= 25
    margin_top = height-150

    ##### HANDLE MAIN ####


    font = font_handle(font_size)
    w, _ = draw.textsize(handle_title,font=font)
  
    while w > width-margin_left:
        font_size -= 1
        font = font_handle(font_size)
        w, _ = draw.textsize(handle_title,font=font)
    draw.rectangle( ((0,margin_top),(width,margin_top+font_size//2)),fill=WHITE)
    draw.rectangle( ((0,margin_top-font_size//2),(width,margin_top)),fill=GRAY_LIGHT)
    draw.text((margin_left, margin_top),handle_title,ORANGE,font=font,anchor='lm',stroke_width=2,stroke_fill=(0,0,0))
    ##### END HANDLE MAIN ####
    ##### PERF & STAFF ####
    font = font_text(50)
    offset = 0
    max_char_width = 0
    visual_list = []
    acts_list= []

    for performance in perfomer_events:#

        rank = ""
        if  performance['type']['label'] == "Shader Royale":
            for phase in performance['phases']:
                for e in phase['entries']:
                    if e['handle']['stub'] == stub:
                        if e['rank']:
                            rank = f"{e['rank']}"
                            visual_list.append(e['previewUrl'])
                        continue
        else :
            for phase in performance['phases'][-1:]:
                for e in phase['entries']:
                    if e['handle']['stub'] == stub:
                        if not rank:
                            if e['rank']:
                                rank = f"{e['rank']}"
                        visual_list.append(e['previewUrl'])
        if performance['type']['label']  not in ["Shader Showdown","Shader Royale","Patch Battle"]:
            continue
        year = performance['started'][:4]
        title = performance['title']
        if party_serie:=performance.get("partySerie"):
            party_serie = party_serie['name']
        if not party_serie:
            party_serie = title
        acts_list.append(
            f"{year}∙{party_serie}∙{rank}"
            )
    acts_list = acts_list[:13]

    for p in acts_list:
        max_char_width = max(len(p),max_char_width)
        draw.text((50, 50+offset),p,(220,220,220),font=font,stroke_width=2, stroke_fill=(0,0,0))
        offset +=50
    if len(acts_list) > 0:
        draw.text((50, 50+offset),f"■"*(max_char_width//2),(220,220,220),font=font,stroke_width=2, stroke_fill=(0,0,0))
        offset +=70

    for idx,v in enumerate([v for v in visual_list if v][:12]):
        x_off = idx%3
        y_off = idx//3
        mywidth = 300
        vim = Image.open(f"./public{v}")
   
        vim = vim.resize((300,168), Image.ANTIALIAS)

        im.paste(vim,(1920//2+10+x_off*mywidth,50+y_off*168))

    staff_events = result.data['events']['staffEvents'] 
    jobs = []
    for event in staff_events:
        for p in event['phases']:
            label = f"{event['started'][:4]}∙"
            title = event['title']
            if party_serie:=event.get("partySerie"):
                party_serie = party_serie['name']
            if not party_serie:
                party_serie = title
            for a in [a for a in p['staffs'] if a['handle']['stub']==stub]:
                label = f'{label}{a["job"]}∙{party_serie}'
                if label not in jobs:
                    jobs.append(label)
    
        for a in [a for a in event['staffs'] if a['handle']['stub']==stub]:
            label = f'{event["started"][:4]}∙{a["job"]}∙{party_serie}'
            if label not in jobs:
                jobs.append(label)
    
    for p in jobs[:max(0,13-len(acts_list))]:
        max_char_width = max(len(p),max_char_width)
        draw.text((50, 50+offset),p,(220,220,220),font=font,stroke_width=2, stroke_fill=(0,0,0))
        offset +=50
    im.save(out_file)