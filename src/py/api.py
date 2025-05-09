from fastapi import FastAPI, Query
import sys

sys.path.append('./src')
from py import utils

app = FastAPI()

@app.on_event("startup")
def startup_func():
    utils.start_up()


@app.get("/interval-data")
def interval_data(
    filter_rule: str = Query("OB", description="Filter rule"),
    multi_market: str = Query("none", description="Multi-market setting")
):
    try:
        data = utils.get_interval_data(filter_rule, multi_market)
        return {"success": True, "data": data}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/")
def root():

    return {f"message": utils.test()}
