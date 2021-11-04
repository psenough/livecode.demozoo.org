import pathlib
from multiprocessing import Pool

from rdflib import Graph, Literal, XSD, FOAF
from PIL import Image, ImageDraw, ImageFont
import requests



def get_all_handles(graph):
    list_handle_query = """
    SELECT DISTINCT ?handle
    WHERE {
        ?p rdfs:label ?handle .
        ?p a foaf:Person
    }"""
    list_handle_result = graph.query(list_handle_query)
    return [handle_result.handle for handle_result in list_handle_result]

def get_final_participation(graph, handle):
    list_final_participation_query = """
    SELECT ?started ?title ?phase_title ?rank ?image
    WHERE {
        ?p rdfs:label ?handle .
        ?entry lcdz:performer ?p .
        ?entry lcdz:phase ?phase .
        OPTIONAL { ?phase rdfs:label ?phase_title }.
        OPTIONAL { ?entry lcdz:preview_image ?image }.
        ?phase lcdz:isFinal true .
        ?entry lcdz:rank ?rank .
        ?phase lcdz:event ?event .
        ?event rdfs:label ?title .
        ?event lcdz:date_started ?started .
        ?event a ?event_type .
        ?event_type a <https://livecode.demozoo.org/onotlogy/2021.10.19#/event_type/showdown> .
    } ORDER BY DESC(?started)"""

    return graph.query(
        list_final_participation_query, initBindings={"handle": Literal(handle, datatype=XSD.string)}
    )

def get_participation(graph,handle):
    list_participation_query = """
    SELECT ?started ?title ?phase_title
    WHERE {
        ?p rdfs:label ?handle .
        ?entry lcdz:performer ?p .
        ?entry lcdz:phase ?phase .
        ?phase lcdz:event ?event .
        ?event rdfs:label ?title .
        ?event lcdz:date_started ?started .
    } ORDER BY DESC(?started)"""

    return graph.query(
        list_participation_query, initBindings={"handle": Literal(handle, datatype=XSD.string)}
    )

def get_top9_images(graph, handle):
    list_last_9_image_query = """
    SELECT DISTINCT ?image
    WHERE {
        ?p rdfs:label ?handle .
        ?entry lcdz:performer ?p .
        ?entry lcdz:phase ?phase .
        ?entry lcdz:preview_image ?image .
        ?phase lcdz:event ?event .
        ?event lcdz:date_started ?started .
    } ORDER BY DESC(?started) LIMIT 9"""
    return graph.query(
        list_last_9_image_query, initBindings={"handle": Literal(handle, datatype=XSD.string)}
    )

def get_staffs_work(graph, handle):
    list_staff_query = """
    SELECT DISTINCT ?started ?staff_label ?title
    WHERE {
         {
            ?p rdfs:label ?handle .
            ?p a foaf:Person .
            ?p rdfs:label ?handle .
            ?phase ?staff ?p .
            ?staff rdfs:label ?staff_label .
            ?phase lcdz:event ?event .
            ?event rdfs:label ?title .
            ?event lcdz:date_started ?started .

        } UNION  {
            ?p rdfs:label ?handle .
            ?p a foaf:Person .
            ?p rdfs:label ?handle .
     
            ?phase lcdz:event ?event .
            ?event rdfs:label ?title .
            ?event ?staff ?p .
            ?staff rdfs:label ?staff_label .
            ?event lcdz:date_started ?started .
        }
    }  ORDER BY DESC(?started) """
    return graph.query(
        list_staff_query, initBindings={"handle": Literal(handle, datatype=XSD.string)}
    )

def create_poster(graph, handle):  
    factor = 1
    size =  (1920*factor, 1080*factor)
    FontTitle = "UnDotumBold.ttf"
    AllerRg = ImageFont.truetype("Anonymous_Pro.ttf", 30*factor)
    print(f'{handle}') 
    """if 'phi16' not in  f'{handle}':
        
        return"""

    im = Image.new("RGB", size)
    draw = ImageDraw.Draw(im)
    draw.text(
        (50*factor, 1000*factor),
        f"More at http://livecode.demozoo.org",
        font=AllerRg,
        stroke_width=1,
        fill=(255, 255, 255),
    )

    i = 300
    qq = draw.textbbox((50*factor, 50*factor), handle.upper(), font= ImageFont.truetype(FontTitle, i), stroke_width=1*factor)
    while qq[2] > 1920:
        i = i - 10
        qq = draw.textbbox((50*factor, 50*factor), handle.upper(), font= ImageFont.truetype(FontTitle, i), stroke_width=1*factor)
    draw.text((50*factor, 50*factor), handle.upper(), font= ImageFont.truetype(FontTitle,i), stroke_width=1*factor, fill=(255, 255, 255))

    list_final_participation_result = get_final_participation(graph, handle)

    def rank(r):
        r = int(r)
        if r == 1:
            return "1st"
        elif r == 2:
            return "2nd"
        elif r == 3:
            return "3rd"
        return f"{r}th"

    events = set()
    nbwinner = len(list_final_participation_result)
    for k, final_participation in enumerate(list_final_participation_result):
        events.add(f"{final_participation.started[:4]} {final_participation.title}")
        draw.text(
            (50*factor, 450*factor + 40*factor * k),
            f"{final_participation.started[:4]}  {rank(final_participation.rank)}",
            font=AllerRg,
            stroke_width=1*factor,
            fill=(255, 255, 255),
        )
        draw.text(
            (50*factor + 7 * 30*factor, 450*factor + 40*factor * k),
            f"{final_participation.title}",
            font=AllerRg,
            stroke_width=1*factor,
            fill=(255, 255, 255),
        )

    list_participation_result = get_participation(graph,handle)

    other = nbwinner + 1
    for k, participation in enumerate(list_participation_result):
        if f"{participation.started[:4]} {participation.title}" in events:
            continue
        events.add(f"{participation.started[:4]} {participation.title}")
        draw.text(
            (50*factor, 450*factor + 40 *factor* (other)),
            f"{participation.started[:4]}",
            font=AllerRg,
            stroke_width=1*factor,
            fill=(255, 255, 255),
        )
        draw.text(
            (50*factor + 7 * 30*factor, 450*factor + 40*factor * (other)),
            f"{participation.title}",
            font=AllerRg,
            stroke_width=1*factor,
            fill=(255, 255, 255),
        )
        other = other + 1
        if other > 12:
            break
    other = other + 1
    events = set()
    for k,staff in enumerate(get_staffs_work(graph,handle)):
        if other > 12:
            break
        if f"{staff.started[:4]} {staff.staff_label} {staff.title}" in events:
            continue
        events.add(f"{staff.started[:4]} {staff.staff_label} {staff.title}")
        draw.text(
            (50*factor, 450*factor + 40 *factor* (other)),
            f"{staff.started[:4]}",
            font=AllerRg,
            stroke_width=1*factor,
            fill=(255, 255, 255),
        )
        draw.text(
            (50*factor + 7 * 30*factor, 450*factor + 40*factor * (other)),
            f"{staff.staff_label}  {staff.title}",
            font=AllerRg,
            stroke_width=1*factor,
            fill=(255, 255, 255),
        )
        other = other + 1

    list_last_9_image_result = get_top9_images(graph, handle)

    for k, last_9_image in enumerate(list_last_9_image_result):
        thumb = Image.open(requests.get(last_9_image.image, stream=True).raw)
        thumb = thumb.resize((320*factor, 180*factor))
        im.paste(thumb, (900*factor + 320*factor * (k % 3), 450*factor + 180*factor * (k // 3)))
    try:
        im.save(f"./public/posters/{handle}_{size[0]}x{size[1]}.jpg")
    except Exception as ex :
        print(ex)


if __name__ == '__main__':

    pathlib.Path("./public/posters").mkdir(parents=True, exist_ok=True)
    g = Graph()
    g.parse("./public/livecode_db.turtle")
    g.bind("foaf", FOAF)
    # create_poster(g,"azertyuiopqsdfghjklm")
    # exit()
    with Pool(4) as p:
        p.starmap(create_poster, [ (g,h) for h in get_all_handles(g) ] )
