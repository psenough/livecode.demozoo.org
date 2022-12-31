import strawberry
from typing import TYPE_CHECKING, Annotated, List

if TYPE_CHECKING:
    from gql.types.handle import Handle


@strawberry.type
class HandleGroup:
    letter: str
    handles: List[Annotated["Handle", strawberry.lazy("gql.types.handle")]]
