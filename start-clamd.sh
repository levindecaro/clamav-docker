#!/bin/bash

while true;do

if [ -f /usr/local/share/clamav/main.cvd ];then
	break
fi
	echo waiting for freshclam complete
	sleep 30
done
sleep 10
/usr/local/sbin/clamd --foreground=true
