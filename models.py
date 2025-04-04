from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float
    description: str = None
    in_stock: bool = True
