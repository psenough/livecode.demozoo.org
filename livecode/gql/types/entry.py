import strawberry
from typing import Optional
from gql.types.handle import Handle


@strawberry.type
class Entry:
    @staticmethod
    def from_(id, data):
        return Entry(
            gql_id=id,
            id=data.get('id'),
            rank=data.get('rank'),
            points=data.get('points'),
            shadertoy_url=data.get('shadertoy_url'),
            preview_image=data.get('preview_image'),
            source_file=data.get('source_file'),
            handle=Handle.from_(f'{id}_handle', data.get('handle')),
            tic80_cart_id=data.get('tic80_cart_id'),
            vod=data.get('vod'),
        )

    gql_id: strawberry.ID
    id: Optional[int]
    rank: Optional[int]
    points: Optional[int]
    shadertoy_url: Optional[str]
    preview_image: Optional[str]
    source_file: Optional[str]
    handle: Handle
    tic80_cart_id: Optional[str]
    vod: Optional[str]

    @strawberry.field
    def preview_url(self) -> Optional[str]:
        if self.preview_image:
            return f'/media/{self.preview_image}'
        elif self.shadertoy_url:
            id = self.shadertoy_url.split('/')[-1]
            return f'/media/{id}.jpg'
        elif self.tic80_cart_id:
            return f'/media/cart_{self.tic80_cart_id}.gif'
        return None

    def __hash__(self) -> int:
        return self.gql_id.__hash__()
