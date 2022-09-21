#!/bin/bash
INTERVAL=${1:-7200}


while true;do
	freshclam
	sleep $INTERVAL
done


