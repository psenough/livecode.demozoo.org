import strawberry
from typing import List, Annotated


@strawberry.type
class Performer:

    handle: Annotated["Handle", strawberry.lazy("gql.types.handle")]
    staff_events: List[Annotated["Event", strawberry.lazy("gql.types.event")]]
    performer_events: List[
        Annotated["Event", strawberry.lazy("gql.types.event")]
    ]
