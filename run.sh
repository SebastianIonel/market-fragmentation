#!/bin/bash

./src/source_code.sh &
./frontend/run_front.sh &
wait
deactivate
# This script runs the backend and frontend concurrently.
# It starts the backend server using the `source_code.sh` script
# and the frontend server using the `run_front.sh` script.
# The `wait` command is used to wait for all background processes to finish.
