import os
import uvicorn
from fastapi import FastAPI
from models import Item

app = FastAPI(
    title="Python Web API with Swagger",
    description="This is a simple API built with FastAPI and deployed using Jenkins.",
    version="1.0.0",
    docs_url="/docs",             # Swagger UI
    redoc_url="/redoc",           # ReDoc UI
    openapi_url="/openapi.json"   # OpenAPI schema
)

@app.get("/")
def read_root():
    return {"message": "Hello, world from Python API!"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "query": q}


@app.post("/items/")
def create_item(item: Item):
    return {"received_item": item}

