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
    multi_market: str = Query("none", description="Multi-market setting"),
    start_time: str = Query(None, description="Start time"),
    end_time: str = Query(None, description="End time"),
    date: str = Query(None, description="Date"),
):
    try:
        # merge parameters
        params = " ".join([
            str(filter_rule or "OB"),
            str(multi_market or "none"),
            str(start_time or "00:00"),
            str(end_time or "23:59"),
            str(date.replace("/", ".") if date else "2013.01.15")
        ])

        with open("logs/api_log.txt", "a") as log_file:
            log_file.write(f"{params}\n")

        data = utils.get_interval_data(params)
        # write log to file
        with open("logs/api_log.txt", "a") as log_file:
            log_file.write(f"filter_rule: {filter_rule}, multi_market: {multi_market}, data: {data}\n")
            
        return {"success": True, "data": data}
    except Exception as e:
        return {"success": False, "error": str(e)}


@app.get("/qualifiers-amount")
def qualifiers_amount(
    filter_rule: str = Query("OB", description="Filter rule"),
    multi_market: str = Query("none", description="Multi-market setting"),
    start_time: str = Query(None, description="Start time"),
    end_time: str = Query(None, description="End time"),
    date: str = Query(None, description="Date"),
):
    try:
        # merge parameters
        params = " ".join([
            str(filter_rule or "OB"),
            str(multi_market or "none"),
            str(start_time or "00:00"),
            str(end_time or "23:59"),
            str(date.replace("/", ".") if date else "2013.01.15")
        ])

        with open("logs/api_log.txt", "a") as log_file:
            log_file.write(f"{params}\n")

        data = utils.get_qualifiers_amount(params)
        # write log to file
        with open("logs/api_log.txt", "a") as log_file:
            log_file.write(f"filter_rule: {filter_rule}, multi_market: {multi_market}, data: {data}\n")
            
        return {"success": True, "data": data}
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.get("/")
def root():

    return {f"message": utils.test()}
