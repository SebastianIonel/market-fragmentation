from fastapi import FastAPI
import sys

sys.path.append('./src')
from py import utils

app = FastAPI()

@app.on_event("startup")
def startup_func():
    utils.start_up()


@app.get("/")
def root():
    utils.test()
    return {f"message": "Hello World"}
