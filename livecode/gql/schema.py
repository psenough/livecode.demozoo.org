import strawberry
from typing import List
from typing import Dict
from typing import Optional
from gql.types.party_series import PartySerie
from gql.types.event import Event
from gql.types.event_type import EventType
from gql.types.handle import Handle
from gql.types.performer import Performer
from gql.types.handle_group import HandleGroup
from gql.types.upcoming import Upcoming
from gql.db import (
    get_events,
    get_all_years,
    get_events_from_year,
    get_party_series,
    get_party_serie,
    get_upcomings,
)


@strawberry.type
class Query:
    @strawberry.field
    def events(self, ids: Optional[List[strawberry.ID]] = []) -> List[Event]:
        return [Event.from_(id, data) for id, data in get_events(ids)]

    @strawberry.field
    def year(self, id: strawberry.ID) -> List[Event]:
        return sorted(
            [Event.from_(id, data) for id, data in get_events_from_year(id)],
            key=lambda a: a.started,
            reverse=True,
        )

    @strawberry.field
    def years(self) -> List[strawberry.ID]:
        return get_all_years()

    @strawberry.field
    def party_series(self) -> List[PartySerie]:
        return sorted(
            list({PartySerie.from_(data) for data in get_party_series()}),
            key=lambda a: a.name,
        )

    @strawberry.field
    def party_serie(self, id: strawberry.ID) -> PartySerie:
        return list({PartySerie.from_(data) for data in get_party_serie(id)})[0]

    @strawberry.field
    def party_serie_by_stub(self, stub: str) -> PartySerie:
        return [
            p
            for p in {PartySerie.from_(data) for data in get_party_series()}
            if p.stub() == stub
        ][0]

    @strawberry.field
    def all_handles(self) -> List[HandleGroup]:
        events = [Event.from_(id, data) for id, data in get_events([])]

        pagination = dict()
        handles = set()
        for event in events:
            for staff in event.staffs:
                handles.add(staff.handle)
            for phase in event.phases:
                for staff in phase.staffs:
                    handles.add(staff.handle)
            for phase in event.phases:
                for entry in phase.entries:
                    handles.add(entry.handle)
        for h in sorted(handles, key=lambda a: a.display_name().lower()):
            if h.display_name()[0].isalpha():
                key = h.display_name().upper()[0]
            else:
                key = "#"
            if key not in pagination.keys():
                pagination[key] = HandleGroup(letter=key, handles=list())
            pagination[key].handles.append(h)
        return pagination.values()

    @strawberry.field
    def all_event_type() -> List[EventType]:
        return sorted(set(EventType.from_(data) for _, data in get_events([])))

    @strawberry.field
    def events_by_type(type_stub: strawberry.ID) -> List[Event]:
        return sorted(
            [
                Event.from_(id, data)
                for id, data in get_events([])
                if EventType.from_(data).stub() == type_stub
            ],
            key=lambda a: a.started,
            reverse=True,
        )

    @strawberry.field
    def event_by_id(self, gqlId: strawberry.ID) -> Event:
        data = [Event.from_(id, data) for id, data in get_events([gqlId])][0]
        return data

    @strawberry.field
    def events_by_handle(self, stub: str) -> Performer:

        events = [Event.from_(id, data) for id, data in get_events([])]

        handle = None
        filtered_events = []
        staff_events = set()
        performer_events = set()
        for event in events:
            handles = set()
            for staff in event.staffs:
                handles.add(staff.handle.stub())
                if staff.handle.stub() == stub:
                    staff_events.add(event)
                    if handle is None:
                        handle = staff.handle

            for phase in event.phases:
                for staff in phase.staffs:
                    handles.add(staff.handle.stub())
                    if staff.handle.stub() == stub:
                        staff_events.add(event)
                        if handle is None:
                            handle = staff.handle
            for phase in event.phases:
                for entry in phase.entries:
                    handles.add(entry.handle.stub())
                    if entry.handle.stub() == stub:
                        performer_events.add(event)
                        if handle is None:
                            handle = entry.handle
            if stub in handles:
                filtered_events.append(event)
        return Performer(
            handle=handle,
            staff_events=sorted(
                staff_events, key=lambda a: a.started, reverse=True
            ),
            performer_events=sorted(
                performer_events, key=lambda a: a.started, reverse=True
            ),
        )

    @strawberry.field
    def upcomings(self) -> List[Upcoming]:
        return [
            Upcoming.from_(id, data) for id, data in get_upcomings().items()
        ]


schema = strawberry.Schema(query=Query)
