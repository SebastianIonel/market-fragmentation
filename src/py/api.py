from fastapi import FastAPI, Query
import sys
from fastapi.middleware.cors import CORSMiddleware

sys.path.append('./src')
from py import utils

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)


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
        # write log to file
        with open("logs/api_log.txt", "a") as log_file:
            log_file.write(f"filter_rule: {filter_rule}, multi_market: {multi_market}, data: {data}\n")
        return {"success": True, "data": data}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/")
def root():

    return {f"message": utils.test()}
