import strawberry
from typing import Optional
import json
import codecs
import urllib.parse

_DB_HANDLES_CACHE = json.load(codecs.open('cache/handles.json'))


@strawberry.type
class Handle:
    @staticmethod
    def from_(id, data):
        return Handle(
            gql_id=id, name=data.get('name'), demozoo_id=data.get('demozoo_id')
        )

    gql_id: strawberry.ID
    name: str
    demozoo_id: Optional[int]

    @strawberry.field
    def stub(self) -> str:
        return urllib.parse.quote(self.display_name())

    @strawberry.field
    def display_name(self) -> str:
        if self.demozoo_id:
            cached_name = _DB_HANDLES_CACHE.get(str(self.demozoo_id))
            if cached_name:
                return cached_name
        return self.name

    def __hash__(self) -> int:
        # return self.name.__hash__()
        return self.display_name().__hash__()

    def __eq__(self, other: object) -> bool:
        if self.demozoo_id and other.demozoo_id:
            return self.demozoo_id == other.demozoo_id
        return self.display_name().lower() == other.display_name().lower()
