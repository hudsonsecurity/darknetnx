#!/bin/bash
inotifywait -m /var/lib/motioneye/$1 -e create -e moved_to |
    while read dir action file; do
        echo "The file '$file' appeared in directory '$dir' via '$action'"
    echo "$file"
    echo "$file" > /tmp/NEWDATA-$1
   PIC=`cat /tmp/NEWDATA-$1`
    ./nxaimo.sh darknet-yolov3-tiny $1 ai ai123456 Driveway NULL $PIC
    done
