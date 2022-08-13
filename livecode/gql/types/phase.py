import strawberry
from typing import Optional, List
from gql.types.entry import Entry
from gql.types.staff import Staff


@strawberry.type
class Phase:
    @staticmethod
    def from_(id, data):
        return Phase(
            gql_id=id,
            title=data.get('title'),
            vod=data.get('vod'),
            entries=[
                Entry.from_(f'{id}_entry_{e}', data)
                for e, data in enumerate(data.get('entries'))
            ],
            staffs=[
                Staff.from_(f'{id}_staff_{e}', data)
                for e, data in enumerate(data.get('staffs'))
            ],
            keyword=data.get("keyword"),
        )

    gql_id: strawberry.ID
    title: Optional[str]
    vod: Optional[str]
    entries: List[Entry]
    staffs: List[Staff]
    keyword: Optional[str]
