import strawberry
from gql.types.phase import Phase
from gql.types.phase import Staff
from gql.types.software import Software
from typing import Optional, List
from typing import TYPE_CHECKING, Annotated
import gql.db as db
import gql.types.party_series as party_series
import gql.types.event_type as event_type


@strawberry.type
class Event:
    def __eq__(self, __o: object) -> bool:
        return self.gql_id == __o.gql_id

    def __hash__(self) -> int:
        return self.gql_id.__hash__()

    @staticmethod
    def from_(id, data):
        return Event(
            gql_id=id,
            title=data.get('title'),
            started=data.get('started'),
            date=data.get('date'),
            type=event_type.EventType.from_(data),
            vod=data.get('vod'),
            phases=[
                Phase.from_(f'{id}_phase_{e}', data)
                for e, data in enumerate(data.get('phases'))
            ],
            demozoo_party_id=data.get('demozoo_party_id'),
            staffs=[
                Staff.from_(f'{id}_staff_{e}', data)
                for e, data in enumerate(data.get('staffs'))
            ],
            software_used=[
                Software.from_(d) for d in data.get('software_used') or []
            ],
        )

    @strawberry.field
    def party_serie(
        self,
    ) -> Optional[
        Annotated["PartySerie", strawberry.lazy("gql.types.party_series")]
    ]:
        if self.demozoo_party_id is None:
            return None
        return party_series.PartySerie.from_(
            db.get_series_from_event_id(self.demozoo_party_id)
        )

    gql_id: strawberry.ID
    title: str
    started: str
    date: str
    type: event_type.EventType
    phases: List[Phase]
    vod: Optional[str]
    demozoo_party_id: Optional[str]
    staffs: List[Staff]
    software_used: List[Software]
