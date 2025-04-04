from fastapi import FastAPI
from models import Item

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, world from Python API!"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "query": q}


@app.post("/items/")
def create_item(item: Item):
    return {"received_item": item}

#ccomment
