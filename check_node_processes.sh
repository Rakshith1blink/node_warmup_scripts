#!/bin/bash

# Get the current time minus 1 minute
one_minute_ago=$(date -d '1 minute ago' '+%Y-%m-%d %H:%M:%S')

# Get the list of node processes with their PID, start time, and command
ps -eo pid,lstart,cmd | grep '/root/.nvm/versions/node' | grep -v 'grep' | while read -r pid lstart1 lstart2 lstart3 lstart4 lstart5 cmd; do
    # Combine the start time fields
    start_time=$(date -d "$lstart1 $lstart2 $lstart3 $lstart4 $lstart5" '+%Y-%m-%d %H:%M:%S')

    # Compare the start time with the current time minus 1 minute
    if [[ "$start_time" > "$one_minute_ago" ]]; then
        echo "$pid"
    fi
done
