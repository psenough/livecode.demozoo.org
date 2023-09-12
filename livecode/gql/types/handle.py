import strawberry
from typing import Optional
from typing import TYPE_CHECKING, Annotated, List
import json
import codecs
import urllib.parse

_DB_HANDLES_CACHE = json.load(codecs.open('cache/handles.json'))
_DB_HANDLES_GROUP_CACHE = set(json.load(codecs.open('cache/groups.json')))

@strawberry.type
class Handle:
    @staticmethod
    def from_(id, data):
      
        members = []
        for e, m in enumerate(data.get('members',[])):
            members.append(
                Handle(
                    gql_id=f'{id}_"member"_{e}', 
                    name=m['handle'].get('name'), 
                    demozoo_id=m['handle'].get('demozoo_id'), 
                    is_group=False,
                    members=[]
                )
            )
        return Handle(
            gql_id=id, 
            name=data.get('name'), 
            demozoo_id=data.get('demozoo_id'),
            is_group="members" in data.keys() or str(data.get('demozoo_id')) in _DB_HANDLES_GROUP_CACHE, 
            members=members
        )
 

    gql_id: strawberry.ID
    name: str
    demozoo_id: Optional[int]
    is_group:bool
    members: Optional[List[Annotated["Handle", strawberry.lazy("gql.types.handle")]]]
    @strawberry.field
    def stub(self) -> str:
        return urllib.parse.quote(self.display_name())
    @strawberry.field
    def members_stub(self) -> List[str]:
        return [m.stub() for m in self.members]
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
