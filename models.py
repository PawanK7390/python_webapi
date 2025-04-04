from pydantic import BaseModel

class Item(BaseModel):
    name: str
    description: str = None
    price: float
    is_offer: bool = None
