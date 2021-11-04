# -*- coding: utf-8 -*-
from rdflib import Namespace, Literal, URIRef, RDF, RDFS, BNode, DC, FOAF, XSD
from rdflib.graph import Graph
import glob
import json
import codecs
import urllib
import hashlib
from pathlib import Path

# fx_chromatic_aberrations 255,0,0,0,2,2,0,50,1,0,255,0,0,0,0,0,0,1,0,50,50

STORE = Graph()

NS_LCDZ = Namespace("https://livecode.demozoo.org/onotlogy/2021.10.19#")
NS_DEMOZOO_PARTY_SERIES = Namespace("https://demozoo.org/parties/series/")
NS_DEMOZOO_PARTY = Namespace("https://demozoo.org/parties/")

STORE.bind("lcdz", NS_LCDZ)
STORE.bind("rdfs", RDFS)
STORE.bind("rdf", RDF)

EVENT = Namespace(NS_LCDZ["/event/"])
PHASE = Namespace(NS_LCDZ["/phase/"])
ENTRY = Namespace(NS_LCDZ["/entry/"])
PERSON = Namespace(NS_LCDZ["/person/"])

JOB_TYPE = NS_LCDZ['/job']

EVENT_TYPE_JAM = NS_LCDZ["/event_type/jam"]
EVENT_TYPE_SHOWDOWN = NS_LCDZ["/event_type/showdown"]
EVENT_TYPE_SEMINAR = NS_LCDZ["/event_type/seminar"]

EVENT_TYPE_SHADER_JAM = NS_LCDZ["/event_type/shader_jam"]
EVENT_TYPE_BYTE_JAM = NS_LCDZ["/event_type/byte_jam"]
EVENT_TYPE_ONLINE_PERFORMANCE = NS_LCDZ["/event_type/online_performance"]
EVENT_TYPE_SHADER_ROYALE = NS_LCDZ["/event_type/shader_royale"]
EVENT_TYPE_BYTE_BATTLE = NS_LCDZ["/event_type/byte_battle"]
EVENT_TYPE_THE_INCREDIBLE_LIVE_CODER_MAYHEM_5000 = NS_LCDZ[
    "/event_type/the_incredible_live_coder_mayhem_5000"
]
EVENT_TYPE_DUCK_JAM = NS_LCDZ["/event_type/duck_jam"]
EVENT_TYPE_SHADER_CODE_SEMINAR = NS_LCDZ["/event_type/shader_code_seminar"]
EVENT_TYPE_SHADER_SHOWDOWN = NS_LCDZ["/event_type/shader_showdown"]
EVENT_TYPE_SHADER_LIVE = NS_LCDZ["/event_type/shader_live"]
EVENT_TYPE_SHADER_GRAND_PRIX = NS_LCDZ["/event_type/shader_grand_prix"]
EVENT_TYPE_LIVE_PERFORMANCE = NS_LCDZ["/event_type/live_performance"]
EVENT_TYPE_FRIENDLY_SHOWDOWN = NS_LCDZ["/event_type/friendly_showdown"]

STORE.add((EVENT_TYPE_SHADER_JAM, RDF.type, EVENT_TYPE_JAM))
STORE.add((EVENT_TYPE_BYTE_JAM, RDF.type, EVENT_TYPE_JAM))
STORE.add((EVENT_TYPE_DUCK_JAM, RDF.type, EVENT_TYPE_JAM))
STORE.add((EVENT_TYPE_LIVE_PERFORMANCE, RDF.type, EVENT_TYPE_JAM))

STORE.add((EVENT_TYPE_SHADER_ROYALE, RDF.type, EVENT_TYPE_SHOWDOWN))
STORE.add((EVENT_TYPE_BYTE_BATTLE, RDF.type, EVENT_TYPE_SHOWDOWN))
STORE.add(
    (EVENT_TYPE_THE_INCREDIBLE_LIVE_CODER_MAYHEM_5000, RDF.type, EVENT_TYPE_SHOWDOWN)
)
STORE.add((EVENT_TYPE_SHADER_SHOWDOWN, RDF.type, EVENT_TYPE_SHOWDOWN))
STORE.add((EVENT_TYPE_SHADER_GRAND_PRIX, RDF.type, EVENT_TYPE_SHOWDOWN))
STORE.add((EVENT_TYPE_FRIENDLY_SHOWDOWN, RDF.type, EVENT_TYPE_SHOWDOWN))

IS_WINNER = NS_LCDZ.is_winner


def normalize(str):
    return str.lower().replace(" ", "_").replace("-", "_")


def hash_handle(handle_obj) -> str:
    """Get either Demozoo id or, if not found, generate hash from name."""
    return (
        handle_obj.get("demozoo_id")
        or "lc_"
        + hashlib.md5(handle_obj["name"].encode("utf-8")).hexdigest().lower()[:6]
    )


files = glob.glob("./public/data/*.json")


def Person(id, data):
    person_node = STORE.resource(PERSON[str(id)])
    person_node.set(RDFS.label, Literal(data["name"], datatype=XSD.string))
    person_node.set(RDF.type, FOAF.Person)
    if data.get("demozoo_id"):
        person_node.set(
            RDFS.seeAlso, URIRef(f"https://demozoo.org/sceners/{data['demozoo_id']}")
        )
    pass


def Entry(id, entry, base_ns):
    entry_node = STORE.resource(ENTRY[id])
    entry_node.set(NS_LCDZ.phase, base_ns)
    if entry.get("rank"):
        entry_node.set(NS_LCDZ.rank, Literal(entry["rank"], datatype=XSD.numeric))
    if entry.get("points"):
        entry_node.set(NS_LCDZ.points, Literal(entry["points"], datatype=XSD.numeric))
    if entry.get("shadertoy_url"):
        entry_node.set(NS_LCDZ.shadertoy_url, URIRef(entry["shadertoy_url"]))
    if entry.get("preview_image"):
        entry_node.set(
            NS_LCDZ.preview_image,
            URIRef(
                f"https://livecode.demozoo.org/media/{urllib.parse.quote(entry['preview_image'])}"
            ),
        )
    else :
        if entry.get('shadertoy_url'):
            entry_node.set(
            NS_LCDZ.preview_image,
            URIRef(
                f"https://livecode.demozoo.org/media/{urllib.parse.quote(entry['shadertoy_url'].split('/')[-1])}.jpg"
            ),
            )
        elif entry.get('tic80_cart_id') :
            entry_node.set(
            NS_LCDZ.preview_image,
            URIRef(
                f"https://livecode.demozoo.org/media/cart_{urllib.parse.quote(str(entry['tic80_cart_id']))}.gif"
            ),)
    if entry.get("source_file"):
        entry_node.set(
            NS_LCDZ.source_file, Literal(urllib.parse.quote(entry["source_file"]))
        )

    handle_id = hash_handle(entry["handle"])

    handle = STORE.resource(PERSON[str(handle_id)])
    if entry["handle"]["name"] == "gopher":
        print(handle)
        print(entry)
        print((NS_LCDZ.performer, handle))
    entry_node.set(NS_LCDZ.performer, handle)


def Phase(id, phase, base_ns):

    phase_node = STORE.resource(PHASE[id])
    phase_node.set(NS_LCDZ.event, base_ns)
    phase_node.set(RDF.type, NS_LCDZ.phase)
    if phase.get("title"):
        phase_node.set(RDFS.label, Literal(phase["title"]))
    if (
        phase.get("title") == None
        or phase.get("title").casefold() == "Final".casefold()
    ):
        phase_node.set(NS_LCDZ.isFinal, Literal(True, datatype=XSD.boolean))
    if phase.get("vod"):
        phase_node.set(NS_LCDZ.vod, Literal(phase["vod"]))
    for k, entry in enumerate(phase["entries"]):
        entry_id = f"{id}_{str(k).zfill(3)}"
        Entry(entry_id, entry, phase_node)
    for s in phase["staffs"]:
        handle_id = hash_handle(s["handle"])
        handle = STORE.resource(PERSON[str(handle_id)])
        phase_node.add(NS_LCDZ[normalize(s["job"])], handle)
    return phase_node

def StaffType(job):
    rdf_job = STORE.resource(NS_LCDZ[normalize(s["job"])])
    rdf_job.set(RDF.type, JOB_TYPE)
    rdf_job.set(RDFS.label, Literal(s['job']))
    return rdf_job
def Event(f, event):
    rdf_event = STORE.resource(EVENT[f"{Path(f).stem}"])
    rdf_event.set(RDF.type, NS_LCDZ[f"/event_type/{normalize(event['type'])}"])
    rdf_event.set(RDFS.label, Literal(event["title"]))
    rdf_event.set(NS_LCDZ.date_started, Literal(event["started"], datatype=XSD.date))
    if event.get("vod"):
        rdf_event.set(NS_LCDZ.vod, URIRef(event["vod"]))
    if event.get("demozoo_party_id"):
        rdf_event.set(RDFS.seeAlso, NS_DEMOZOO_PARTY[str(event["demozoo_party_id"])])

    for k, phase in enumerate(event["phases"]):
        id = f"{Path(f).stem}_{str(k).zfill(3)}"
        Phase(id, phase, rdf_event)
    for s in event["staffs"]:
        handle_id = hash_handle(s["handle"])
        handle = STORE.resource(PERSON[str(handle_id)])
        StaffType(s["job"])
        rdf_event.add(NS_LCDZ[normalize(s["job"])], handle)
    return rdf_event


def Participant(name):
    participant = STORE.resource(
        f"https://livecode.demozoo.org/onotlogy/2021.10.19/Participant/{name}"
    )
    participant.set(RDF.type, PERSON)
    participant.set(RDF.name, Literal(name))
    return participant


for f in files:
    event = json.load(codecs.open(f, "r", "UTF-8"))
    persons = {}
    for s in event["staffs"]:
        persons[hash_handle(s["handle"])] = s["handle"]
    for phase in event["phases"]:
        for s in phase["staffs"]:
            persons[hash_handle(s["handle"])] = s["handle"]
        for e in phase["entries"]:
            persons[hash_handle(e["handle"])] = e["handle"]
    for k, v in persons.items():
        Person(k, v)
    Event(f, event)

knows_query = """
SELECT ?started ?title ?phase_title ?rank ?image
WHERE {
    ?entry lcdz:performer <https://livecode.demozoo.org/onotlogy/2021.10.19/person/88839>  .
    ?entry lcdz:phase ?phase .
    OPTIONAL { ?phase rdfs:label ?phase_title }.
    OPTIONAL { ?entry lcdz:preview_image ?image }.
    ?phase lcdz:isFinal true .
    ?entry lcdz:rank ?rank .
    ?phase lcdz:event ?event .
    ?event rdfs:label ?title .
    ?event lcdz:date_started ?started .
    ?event a ?event_type .
    ?event_type a <https://livecode.demozoo.org/onotlogy/2021.10.19/event_type/showdown> .
} ORDER BY DESC(?started)"""

qres = STORE.query(knows_query)
for row in qres:
    print(f"{row.started} {row.title} {row.phase_title} {row.rank} {row.image} ")
STORE.serialize("./public/livecode_db.turtle", format="turtle")
