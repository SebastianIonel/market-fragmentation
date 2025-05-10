#!/bin/bash
source ../venv/bin/activate
uvicorn py.api:app --reload --app-dir ./src
deactivate