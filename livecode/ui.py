"""NiceGUI-based admin UI for creating new livecode event entries."""

import json
import re
from datetime import datetime
from pathlib import Path

from nicegui import ui, events

# ─────────────────────────────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────────────────────────────

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "public" / "data"
SOURCES_DIR = BASE_DIR / "public" / "shader_file_sources"
MEDIA_DIR = BASE_DIR / "public" / "media"

# ─────────────────────────────────────────────────────────────────────
# Theme
# ─────────────────────────────────────────────────────────────────────

_CSS = """
:root { --ca-r: rgba(255,0,0,.35); --ca-c: rgba(0,255,255,.35); --ca-s: 1.2px; }

body, .q-page, .q-layout { background:#111!important; color:#ccc!important }
.q-header { background:#181818!important; border-bottom:1px solid #222!important }
.q-card { background:#161616!important; border:1px solid #222!important; color:#ccc!important }
.q-field__label,.q-field__native,.q-field__input,
.q-select__dropdown-icon,.q-field__append { color:#aaa!important }
.q-btn--unelevated { background:#333!important; color:#e0e0e0!important }
.q-btn--flat { color:#999!important }
.q-table { background:#141414!important; color:#bbb!important }
.q-table thead th { color:#888!important; border-color:#222!important }
.q-table tbody td { border-color:#1a1a1a!important }
.q-separator { background:#222!important }
.q-expansion-item { border-color:#222!important }
a { color:#999!important } a:hover { color:#fff!important }
::-webkit-scrollbar { width:6px }
::-webkit-scrollbar-track { background:#111 }
::-webkit-scrollbar-thumb { background:#333; border-radius:3px }

.ca-title {
    text-shadow: calc(-1*var(--ca-s)) 0 var(--ca-r), var(--ca-s) 0 var(--ca-c);
    color:#fff!important; letter-spacing:.5px;
}
.ca-heading {
    text-shadow: calc(-.8*var(--ca-s)) 0 var(--ca-r), calc(.8*var(--ca-s)) 0 var(--ca-c);
    color:#ddd!important;
}
"""

# ─────────────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────────────

_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
_SLUG_RE = re.compile(r"[^a-z0-9]+")


def _slugify(text: str) -> str:
    return _SLUG_RE.sub("_", text.strip().lower()).strip("_")


def _human_date(iso: str) -> str:
    try:
        return datetime.strptime(iso, "%Y-%m-%d").strftime("%-d %B %Y")
    except ValueError:
        return iso


def _event_stem(started: str, event_type: str, title: str) -> str:
    """Canonical name used for JSON file, source dir and media dir."""
    return f"{started.replace('-', '_')}_{_slugify(event_type)}_{_slugify(title)}"


def _int_or_none(v) -> int | None:
    if v is None or v == "":
        return None
    try:
        return int(v)
    except (TypeError, ValueError):
        return None


def _str_or_none(v) -> str | None:
    return v.strip() if isinstance(v, str) and v.strip() else None


# ─────────────────────────────────────────────────────────────────────
# Data scan — builds autocomplete/enum lists from existing JSONs
# ─────────────────────────────────────────────────────────────────────

class Enums:
    """Holds all scanned enum-like values. Computed once at page load."""

    __slots__ = ("event_types", "purposes", "jobs",
                 "software_names", "handles", "handle_names")

    def __init__(self):
        types: set[str] = set()
        purposes: set[str] = set()
        jobs: set[str] = set()
        sw_names: set[str] = set()
        handles: dict[str, int | None] = {}

        for f in DATA_DIR.glob("*.json"):
            try:
                d = json.loads(f.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                continue

            if t := d.get("type"):
                types.add(t)

            for sw in d.get("software_used") or []:
                if sw.get("name"):
                    sw_names.add(sw["name"])
                if sw.get("purpose"):
                    purposes.add(sw["purpose"])

            self._scan_staffs(d.get("staffs") or [], jobs, handles)
            for phase in d.get("phases") or []:
                self._scan_staffs(phase.get("staffs") or [], jobs, handles)
                for entry in phase.get("entries") or []:
                    self._collect_handle(entry.get("handle", {}), handles)

        self.event_types = sorted(types)
        self.purposes = sorted(purposes)
        self.jobs = sorted(jobs)
        self.software_names = sorted(sw_names)
        self.handles = handles
        self.handle_names = sorted(handles, key=str.lower)

    @staticmethod
    def _scan_staffs(staffs, jobs_set, handles_dict):
        for s in staffs:
            if s.get("job"):
                jobs_set.add(s["job"])
            Enums._collect_handle(s.get("handle", {}), handles_dict)

    @staticmethod
    def _collect_handle(h: dict, handles: dict):
        name = h.get("name", "").strip()
        if not name:
            return
        dzid = h.get("demozoo_id")
        if name not in handles or (dzid and not handles[name]):
            handles[name] = dzid
        for m in h.get("members") or []:
            Enums._collect_handle(m.get("handle", m), handles)


_enums: Enums | None = None

# ─────────────────────────────────────────────────────────────────────
# Form state & uploads
# ─────────────────────────────────────────────────────────────────────

_pending_uploads: dict[str, bytes] = {}
_form_state: dict = {}


def _new_entry() -> dict:
    return dict(
        id=None, rank=None, points=None,
        handle=dict(name="", demozoo_id=None),
        shadertoy_url=None, poshbrolly_url=None,
        preview_image=None, source_file=None,
        tic80_cart_id=None, vod=None,
        _src_key=None, _src_ext="",
        _media_key=None, _media_ext="",
    )


def _new_phase() -> dict:
    return dict(title=None, vod=None, keyword=None,
                entries=[_new_entry()], staffs=[])


def _new_staff() -> dict:
    return dict(handle=dict(name="", demozoo_id=None), job="")


def _new_software() -> dict:
    return dict(name="", url="", version="", purpose="")


def _init_state():
    global _form_state
    _form_state = dict(
        title="", started="", type="",
        website="", flyer="", vod="",
        software_used=[], phases=[_new_phase()],
        staffs=[], demozoo_party_id=None,
    )
    _pending_uploads.clear()


def _event_info_valid(state: dict) -> bool:
    return bool(state.get("title") and state.get("type")
                and state.get("started") and _DATE_RE.match(state["started"]))


async def _store_upload(key: str, e: events.UploadEventArguments):
    _pending_uploads[key] = await e.file.read()


# ─────────────────────────────────────────────────────────────────────
# JSON serialization
# ─────────────────────────────────────────────────────────────────────

def _serialize_handle(h: dict) -> dict:
    return {"name": h["name"], "demozoo_id": _int_or_none(h.get("demozoo_id"))}


def _serialize_staff(s: dict) -> dict:
    return {"handle": _serialize_handle(s["handle"]), "job": s["job"]}


def _build_json(state: dict) -> dict:
    phases = []
    for p in state["phases"]:
        entries = [{
            "id": _int_or_none(e["id"]),
            "rank": _int_or_none(e["rank"]),
            "points": _int_or_none(e["points"]),
            "handle": _serialize_handle(e["handle"]),
            "shadertoy_url": _str_or_none(e.get("shadertoy_url")),
            "poshbrolly_url": _str_or_none(e.get("poshbrolly_url")),
            "preview_image": _str_or_none(e.get("preview_image")),
            "source_file": _str_or_none(e.get("source_file")),
            "tic80_cart_id": _int_or_none(e.get("tic80_cart_id")),
            "vod": _str_or_none(e.get("vod")),
        } for e in p["entries"]]

        phases.append({
            "title": _str_or_none(p["title"]),
            "vod": _str_or_none(p["vod"]),
            "keyword": _str_or_none(p["keyword"]),
            "entries": entries,
            "staffs": [_serialize_staff(s) for s in p["staffs"]],
        })

    software = [
        {"name": s["name"], "url": s["url"], "version": s["version"], "purpose": s["purpose"]}
        for s in state["software_used"] if s["name"]
    ]

    return {
        "title": state["title"],
        "started": state["started"],
        "date": _human_date(state["started"]),
        "type": state["type"],
        "website": state["website"] or "",
        "flyer": state["flyer"] or "",
        "vod": _str_or_none(state["vod"]),
        "software_used": software or None,
        "phases": phases,
        "staffs": [_serialize_staff(s) for s in state["staffs"]],
        "demozoo_party_id": _int_or_none(state["demozoo_party_id"]),
    }


# ─────────────────────────────────────────────────────────────────────
# File I/O — create structure & save
# ─────────────────────────────────────────────────────────────────────

def _write_json(path: Path, data: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=4, ensure_ascii=False), encoding="utf-8")


def _create_structure(state: dict) -> str | None:
    if not _event_info_valid(state):
        ui.notify("Title, date (YYYY-MM-DD), and type are required", type="negative")
        return None

    stem = _event_stem(state["started"], state["type"], state["title"])

    (SOURCES_DIR / stem).mkdir(parents=True, exist_ok=True)
    (MEDIA_DIR / stem).mkdir(parents=True, exist_ok=True)

    json_path = DATA_DIR / f"{stem}.json"
    if not json_path.exists():
        _write_json(json_path, _build_json(state))

    ui.notify(f"Created structure: {stem}", type="positive")
    return stem


def _save_event(state: dict):
    if not _event_info_valid(state):
        ui.notify("Title, date, and type are required", type="negative")
        return

    stem = _event_stem(state["started"], state["type"], state["title"])
    src_dir = SOURCES_DIR / stem
    media_dir = MEDIA_DIR / stem

    for phase in state["phases"]:
        phase_sl = _slugify(phase["title"] or "")
        for ent in phase["entries"]:
            handle_sl = _slugify(ent["handle"]["name"])
            if not handle_sl:
                continue
            tag = f"{handle_sl}-{phase_sl}" if phase_sl else handle_sl

            for key_field, ext_field, dest_dir, path_tpl in (
                ("_src_key",   "_src_ext",   src_dir,   f"/shader_file_sources/{stem}/{tag}{{ext}}"),
                ("_media_key", "_media_ext", media_dir, f"{stem}/{tag}{{ext}}"),
            ):
                ukey = ent.get(key_field)
                if ukey and ukey in _pending_uploads:
                    ext = ent.get(ext_field) or ".bin"
                    dest_dir.mkdir(parents=True, exist_ok=True)
                    (dest_dir / f"{tag}{ext}").write_bytes(_pending_uploads.pop(ukey))
                    target = "source_file" if "src" in key_field else "preview_image"
                    ent[target] = path_tpl.format(ext=ext)

    _write_json(DATA_DIR / f"{stem}.json", _build_json(state))
    ui.notify(f"Saved {stem}.json", type="positive")


# ─────────────────────────────────────────────────────────────────────
# Reusable UI components
# ─────────────────────────────────────────────────────────────────────

def _handle_input(handle_dict: dict, label: str = "Handle name", flex: str = "flex-1"):
    """Name input with autocomplete + Demozoo ID that auto-fills on match."""
    dzid = ui.number("Demozoo ID", format="%.0f").classes("w-32") \
        .bind_value(handle_dict, "demozoo_id")

    def _on_change(e, h=handle_dict, w=dzid):
        name = (e.value or "").strip()
        h["name"] = name
        looked_up = _enums.handles.get(name)
        if looked_up:
            h["demozoo_id"] = looked_up
            w.value = looked_up

    ui.input(label, autocomplete=_enums.handle_names, on_change=_on_change) \
        .classes(flex).bind_value(handle_dict, "name")


def _delete_btn(on_click):
    ui.button(icon="delete", on_click=on_click).props("flat dense color=red size=sm")


# ── Software list ────────────────────────────────────────────────────

def _render_software_list(items: list, container):
    container.clear()
    with container:
        for sw in items:
            with ui.row().classes("w-full gap-2 items-end"):
                ui.input("Name", autocomplete=_enums.software_names) \
                    .classes("flex-1").bind_value(sw, "name")
                ui.input("URL").classes("flex-1").bind_value(sw, "url")
                ui.input("Version").classes("w-24").bind_value(sw, "version")
                ui.input("Purpose", autocomplete=_enums.purposes) \
                    .classes("w-32").bind_value(sw, "purpose")
                _delete_btn(lambda s=sw: (
                    items.remove(s), _render_software_list(items, container)))


# ── Staff list ───────────────────────────────────────────────────────

def _render_staff_list(items: list, container):
    container.clear()
    with container:
        for staff in items:
            with ui.row().classes("w-full gap-2 items-end"):
                _handle_input(staff["handle"], label="Name")
                ui.input("Job", autocomplete=_enums.jobs) \
                    .classes("w-48").bind_value(staff, "job")
                _delete_btn(lambda s=staff: (
                    items.remove(s), _render_staff_list(items, container)))


# ── Entry ────────────────────────────────────────────────────────────

def _render_entry(ent: dict, idx: int, phase_idx: int, phases_container):
    ukey = f"p{phase_idx}_e{idx}"

    with ui.card().classes("w-full").style("background:#131313"):
        with ui.row().classes("items-center justify-between w-full"):
            ui.label(f"Entry #{idx + 1}").classes("font-semibold")
            _delete_btn(lambda: _remove_entry(phases_container, ent))

        with ui.row().classes("w-full gap-4 flex-wrap"):
            _handle_input(ent["handle"], flex="flex-1 min-w-[200px]")

        with ui.row().classes("w-full gap-4 flex-wrap"):
            ui.number("Rank",   format="%.0f").classes("w-24").bind_value(ent, "rank")
            ui.number("Points", format="%.0f").classes("w-24").bind_value(ent, "points")
            ui.number("ID",     format="%.0f").classes("w-24").bind_value(ent, "id")

        with ui.row().classes("w-full gap-4 flex-wrap"):
            ui.input("Shadertoy URL").classes("flex-1 min-w-[200px]").bind_value(ent, "shadertoy_url")
            ui.input("Poshbrolly URL").classes("flex-1 min-w-[200px]").bind_value(ent, "poshbrolly_url")
            ui.number("TIC-80 Cart ID", format="%.0f").classes("w-36").bind_value(ent, "tic80_cart_id")

        ui.input("VOD URL").classes("w-full").bind_value(ent, "vod")
        ui.input("Source file (external URL, leave empty if uploading)") \
            .classes("w-full").bind_value(ent, "source_file")

        with ui.row().classes("w-full gap-4"):
            _upload_field("Upload source file", ukey, "src", ent,
                          ".glsl,.frag,.hlsl,.lua,.csd,.txt")
            _upload_field("Upload preview image", ukey, "media", ent,
                          "image/*,.gif")


def _upload_field(label: str, ukey: str, kind: str, ent: dict, accept: str):
    key_field = f"_{kind}_key"
    ext_field = f"_{kind}_ext"
    upload_key = f"{kind}_{ukey}"

    with ui.column().classes("flex-1 gap-1"):
        ui.label(label).classes("text-xs text-gray-400")

        async def _on_upload(e, k=upload_key, ent=ent):
            await _store_upload(k, e)
            ent[key_field] = k
            ent[ext_field] = Path(e.file.name).suffix

        ui.upload(auto_upload=True, on_upload=_on_upload) \
            .props(f"flat dense accept='{accept}'").classes("w-full")


# ── Phase ────────────────────────────────────────────────────────────

def _render_phase(phase: dict, p_idx: int, phases_container):
    with ui.card().classes("w-full").style("border-left:3px solid #444"):
        with ui.row().classes("items-center justify-between w-full"):
            ui.label(f"Phase #{p_idx + 1}").classes("text-lg font-bold ca-heading")
            _delete_btn(lambda: _remove_phase(phases_container, phase))

        with ui.row().classes("w-full gap-4 flex-wrap"):
            ui.input("Phase title (e.g. Final, Round 1)") \
                .classes("flex-1 min-w-[200px]").bind_value(phase, "title")
            ui.input("VOD URL").classes("flex-1 min-w-[200px]").bind_value(phase, "vod")
            ui.input("Keyword (Byte Battle theme)").classes("w-48").bind_value(phase, "keyword")

        with ui.expansion("Phase Staff", icon="people").classes("w-full"):
            staff_ct = ui.column().classes("w-full gap-2")
            _render_staff_list(phase["staffs"], staff_ct)

            def add_ps(ph=phase, c=staff_ct):
                ph["staffs"].append(_new_staff())
                _render_staff_list(ph["staffs"], c)

            ui.button("Add phase staff", icon="add", on_click=add_ps).props("flat dense size=sm")

        ui.label("Entries").classes("font-semibold mt-2")
        entries_ct = ui.column().classes("w-full gap-2")
        for e_idx, ent in enumerate(phase["entries"]):
            with entries_ct:
                _render_entry(ent, e_idx, p_idx, phases_container)

        def add_entry(ph=phase, c=phases_container):
            ph["entries"].append(_new_entry())
            _refresh_phases(c)

        ui.button("Add entry", icon="add", on_click=add_entry).props("flat dense size=sm")


def _remove_entry(phases_container, ent):
    for p in _form_state["phases"]:
        if ent in p["entries"] and len(p["entries"]) > 1:
            p["entries"].remove(ent)
            _refresh_phases(phases_container)
            return


def _remove_phase(phases_container, phase):
    if len(_form_state["phases"]) > 1:
        _form_state["phases"].remove(phase)
        _refresh_phases(phases_container)


def _refresh_phases(container):
    container.clear()
    with container:
        for idx, phase in enumerate(_form_state["phases"]):
            _render_phase(phase, idx, container)


# ─────────────────────────────────────────────────────────────────────
# Page layout
# ─────────────────────────────────────────────────────────────────────

def root():
    global _enums
    _enums = Enums()
    _init_state()
    state = _form_state

    ui.add_css(_CSS)

    # ── Header ───────────────────────────────────────
    with ui.header().classes("items-center px-6"):
        ui.label("livecode.demozoo.org").classes("text-xl font-bold ca-title")
        ui.label("— New Event").classes("text-lg ml-2").style("color:#666")

    with ui.column().classes("w-full max-w-5xl mx-auto p-6 gap-6"):

        # ── Event info ───────────────────────────────
        ui.label("Event Info").classes("text-xl font-bold ca-heading")
        with ui.card().classes("w-full"):
            with ui.row().classes("w-full gap-4 flex-wrap"):
                ui.input("Title (party name)",
                         validation={"Required": bool}) \
                    .classes("flex-1 min-w-[200px]").bind_value(state, "title")
                ui.select(_enums.event_types, label="Event type",
                          with_input=True, new_value_mode="add",
                          validation={"Required": bool}) \
                    .classes("w-56").bind_value(state, "type")

            ui.input("Start date (YYYY-MM-DD)",
                     validation={"Format YYYY-MM-DD": lambda v: bool(_DATE_RE.match(v)) if v else False}) \
                .classes("w-48").bind_value(state, "started")

            with ui.row().classes("w-full gap-4 flex-wrap"):
                ui.input("Website URL").classes("flex-1").bind_value(state, "website")
                ui.input("Flyer URL").classes("flex-1").bind_value(state, "flyer")

            with ui.row().classes("w-full gap-4 flex-wrap"):
                ui.input("VOD URL").classes("flex-1").bind_value(state, "vod")
                ui.number("Demozoo Party ID", format="%.0f") \
                    .classes("w-48").bind_value(state, "demozoo_party_id")

            name_label = ui.label().classes("text-xs text-gray-400 mt-2")

            def _update_preview():
                if _event_info_valid(state):
                    name_label.text = f"→ {_event_stem(state['started'], state['type'], state['title'])}.json"
                else:
                    name_label.text = ""

            ui.timer(0.5, _update_preview)

        # ── Create structure gate ────────────────────
        status = ui.label().classes("text-sm")
        create_btn = ui.button("Create event file & directories", icon="create_new_folder") \
            .props("unelevated").style("background:#333!important; color:#ddd!important")
        rest = ui.column().classes("w-full gap-6")

        def _sync_gate():
            if _event_info_valid(state) and (DATA_DIR / f"{_event_stem(state['started'], state['type'], state['title'])}.json").exists():
                stem = _event_stem(state["started"], state["type"], state["title"])
                status.text = f"Structure ready: {stem}"
                status.classes(replace="text-sm text-green-400")
                create_btn.set_visibility(False)
                rest.props(remove="disable").classes(remove="opacity-50 pointer-events-none")
            else:
                status.text = "Fill in event info, then create file & directory structure."
                status.classes(replace="text-sm text-yellow-400")
                create_btn.set_visibility(True)
                rest.props("disable").classes("opacity-50 pointer-events-none")

        create_btn.on_click(lambda: (_create_structure(state), _sync_gate()))
        _sync_gate()

        # ── Gated sections ───────────────────────────
        with rest:
            # Software
            ui.label("Software Used").classes("text-xl font-bold ca-heading")
            sw_ct = ui.column().classes("w-full gap-2")
            _render_software_list(state["software_used"], sw_ct)
            ui.button("Add software", icon="add",
                      on_click=lambda: (state["software_used"].append(_new_software()),
                                        _render_software_list(state["software_used"], sw_ct))) \
                .props("flat size=sm")

            # Staff
            ui.label("Event Staff").classes("text-xl font-bold ca-heading")
            staff_ct = ui.column().classes("w-full gap-2")
            _render_staff_list(state["staffs"], staff_ct)
            ui.button("Add staff", icon="add",
                      on_click=lambda: (state["staffs"].append(_new_staff()),
                                        _render_staff_list(state["staffs"], staff_ct))) \
                .props("flat size=sm")

            # Phases
            ui.label("Phases").classes("text-xl font-bold ca-heading")
            phases_ct = ui.column().classes("w-full gap-4")
            _refresh_phases(phases_ct)
            ui.button("Add phase", icon="add",
                      on_click=lambda: (state["phases"].append(_new_phase()),
                                        _refresh_phases(phases_ct))) \
                .props("flat size=sm")

            ui.separator()

            # Preview & save
            with ui.expansion("Preview JSON", icon="code").classes("w-full"):
                preview = ui.code("", language="json").classes("w-full")

                def _refresh():
                    try:
                        preview.content = json.dumps(_build_json(state), indent=2, ensure_ascii=False)
                    except Exception as ex:
                        preview.content = f"// {ex}"

                ui.button("Refresh preview", icon="refresh", on_click=_refresh).props("flat size=sm")

            with ui.row().classes("w-full justify-end gap-4 py-4"):
                ui.button("Save event", icon="save", on_click=lambda: _save_event(state)) \
                    .props("unelevated").classes("text-lg px-8") \
                    .style("background:#333!important; color:#fff!important")


# ─────────────────────────────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────────────────────────────

def start_ui(host: str = "127.0.0.1", port: int = 8080):
    ui.run(root, title="Livecode Demozoo — New Event",
           host=host, port=port, dark=True, reload=False)
