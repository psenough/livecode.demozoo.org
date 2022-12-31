import strawberry
from gql.types.software import Software
from gql.types.phase import Staff
import gql.types.event_type as event_type

from typing import List, Optional


@strawberry.type
class Upcoming:
    gql_id: strawberry.ID
    title: str
    started: str
    type: event_type.EventType
    website: Optional[str]
    flyer: Optional[str]
    software_used: List[Software]
    staffs: List[Staff]

    @staticmethod
    def from_(id, data):
        return Upcoming(
            gql_id=id,
            title=data.get('title'),
            started=data.get('started'),
            type=event_type.EventType.from_(data),
            website=data.get('website'),
            flyer=data.get('flyer'),
            staffs=[
                Staff.from_(f'{id}_staff_{e}', data)
                for e, data in enumerate(data.get('staffs'))
            ],
            software_used=[
                Software.from_(d) for d in data.get('software_used') or []
            ],
        )
