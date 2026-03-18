#!/bin/bash

set -e

TARGET_IP="${1:-127.0.0.1}"
PORT="${2:-8080}"
LOOP="${3:-10}"


echo "Target: http://${TARGET_IP}:${PORT}"

echo "Start"
while [ $LOOP -ge 0 ]
    do 
    curl "http://${TARGET_IP}:${PORT}/call?target=146.112.59.12"
    echo -e ""
    LOOP=$(($LOOP - 1))
done

echo "Done."