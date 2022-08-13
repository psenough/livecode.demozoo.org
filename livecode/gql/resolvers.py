import gql.db as db
import strawberry
from typing import Optional, List, TYPE_CHECKING, Annotated

if TYPE_CHECKING:
    import gql.types as Types


def party_serie(
    root: Annotated["Types.Event", strawberry.lazy("gql.types")]
) -> Annotated["Type.PartySerie", strawberry.lazy("gql.types")]:
    if root.demozoo_party_id is None:
        return None
    return Types.PartySerie.from_(
        db.get_series_from_event_id(root.demozoo_party_id)
    )
