import strawberry
from gql.types.handle import Handle


@strawberry.type
class Staff:
    @staticmethod
    def from_(id, data):
        return Staff(
            gql_id=id,
            job=data.get('job'),
            handle=Handle.from_(f'{id}_handle', data.get('handle')),
        )

    gql_id: strawberry.ID
    job: str
    handle: Handle
