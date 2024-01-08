import strawberry
import urllib.parse


@strawberry.type
class EventType:
    label: str

    @strawberry.field
    def stub(self) -> str:
        return urllib.parse.quote(self.label.replace(" ","_"))

    @staticmethod
    def from_(data):
        return EventType(label=data['type'])

    def __hash__(self) -> int:
        return self.label.__hash__()

    def __lt__(self, other):
        return self.label < other.label
