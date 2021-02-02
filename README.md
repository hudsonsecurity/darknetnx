DARKNETNX - Darknet YoloV4 in NX VMS
by MATTHEW DEL SALTO @ RETROSPECT.VIDEO
LATEST UPDATE: FEB 02 2021
Integrated confidence level parameter as threshold.
Integrated telegram notifications with parameters tgtoken tgid.

PREAMBLE:
All of my work is free software, free as in freedom. GPL V3.
Free and open security is a growing necessity as the cloud 
Gobles up more of our privacy and freedom bit by bit.
Releasing free physical security software is one way
We can take back our privacy while protecting our property.



Objective: Implement cost effective - easy to launch deep learning models in production for small surveillance systems primarly powered by NX VMS and other open platforms:
DW Spectrum, Hanwha Wave, Network Optix, MotionEye



Overview:
I am running this on a NVIDIA Jetson with decent results for 4 cameras with little activity.
NX sends all motion detection events to the jetson through an http request. The jetson then responds by taking a snapshot and running the darknet models on it.
The results are then parsed and returned to the server as a generic event.

Files:
getweights.sh - gets the yolov4-tiny weight file
darknetnx.sh - the main script that gets executed by the webhook
darknet.json - the webhook daemon config listening on port 1337
runapi.sh - runs the webhook api with the above config
run.sh - runs the webhook run file from crontab at reboot

YOLO-V4-TINY is the only weight file included if you want to use the full yolo v4 just download the weight file to the root where the other weight file exists.


QRD:
Here we are turning a tuned darknet build into a web api.
We are then triggering events in NX to send snapshots to the api.
The api processes the image using the requested model and returns the results as a generic event.
Within NX you can create rules around this generic event such as bookmarks, push notifications, etc.
The stock weight and model is typcially applied best for person, vehicle and animal.
Pushover support is now inherent, use it as the last wto variables 

Steps:
1. In the NX VMS create a user and password with admin functionality.
2. Crate an event rule that is triggered by motion detection or analytics.
3. Use this event to trigger an HTTP request to our local darknet server.

This requires seveveral variables.
a. NX camera id
b. darknet server IP
c. NX Server IP and port or NX System ID URL
d. Newly created username and password in step 1.
e. the desired yolo model you want to run
f. arbitrary camera name for notifications in NX

Event trigger example:
http://192.168.1.219:1337/hooks/darknet?camid=dbeba7ec-6e25-856c-395b-d4b3993d2446&server=192.168.1.198:7001&user=ai&pass=ai123456&model=darknet-yolov4-tiny&name=Entrance&runtime=8&threshold=35&tgtoken=telegrambottoken&tgid=telegramuserid

4. Create an event inside of NX that triggers based on the darknet generic event containing the variables of successful detection IE: Person or Vehicle
5. Use this event to create a bookmark, push notification or anything else you can trigger with events!


Setup:
apt-get install curl wget jshon jq webhook
Add to the end of crontab as root
@reboot /root/darknetnx/runapi.sh



NOTES:
Currently only alerts on the highest confidence object.
Separate motion eye scripts and nxwitness scripts.


TODO:
Allow all objects above a certain percentage.
dockerize the service
