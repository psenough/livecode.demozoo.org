import strawberry


@strawberry.type
class Software:
    @staticmethod
    def from_(data):
        return Software(
            name=data.get("name"),
            url=data.get("url"),
            version=data.get("version"),
            purpose=data.get("purpose"),
        )

    name: str
    url: str
    version: str
    purpose: str
