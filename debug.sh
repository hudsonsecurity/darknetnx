#!/bin/bash
killall runapi.sh
ttyd -p 9001 /root/darknetnx/runapi.sh &
