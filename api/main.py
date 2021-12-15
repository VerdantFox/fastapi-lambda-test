import os
from myproj import calculations

from fastapi import FastAPI
from mangum import Mangum

stage = os.environ.get('STAGE', None)
openapi_prefix = f"/{stage}" if stage else "/"

app = FastAPI(title="MyAwesomeApp", openapi_prefix=openapi_prefix) # Here is the magic


@app.get("/hello")
def hello_world():
    return {"message": "Hello World"}


@app.get("/hello/{name}")
def do_something(name: str):
    """Does a thing"""
    return {"message": f"Hello {name}!"}


@app.get("/square/{num}")
def do_something(num: int):
    """Does a thing"""
    squared = calculations.square(num)
    return {"message": f"{num} squared is {squared}!"}


handler = Mangum(app)
