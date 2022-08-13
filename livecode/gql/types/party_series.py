import strawberry


from gql.types.event import Event

from typing import List
import gql.db as db

import urllib.parse
from typing import Optional


@strawberry.type
class PartySerie:
    @staticmethod
    def from_(data):
        return PartySerie(
            gql_id=data.get('id'),
            url=data.get('url'),
            demozoo_url=data.get('demozoo_url'),
            name=data.get('name'),
            website=data.get('website'),
        )

    gql_id: strawberry.ID
    url: str
    demozoo_url: Optional[str]
    name: str
    website: str

    @strawberry.field
    def stub(self) -> str:
        return urllib.parse.quote(self.name)

    @strawberry.field
    def events(self) -> List[Event]:
        return sorted(
            [
                Event.from_(id, data)
                for id, data in db.get_event_from_party_serie(self.gql_id)
            ],
            key=lambda a: a.started,
            reverse=True,
        )

    def __hash__(self) -> int:
        return self.gql_id.__hash__()

    def __eq__(self, other) -> bool:
        return self.gql_id == other.gql_id
