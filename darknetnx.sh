#!/bin/bash
#july 2020 blackbox usa
SOURCE="darknet"
CAMID=$1
SERVER=$2
USER=$3
PASS=$4
PUSHOVERTOKEN="$7"
PUSHOVERUSER="$8"
RUNTIME=$7
CREDS="$3:$4"
MODEL="$5"
NAME="$6"
#QUERY="$7"
#MODEL="$1"
#CREDS="$3:$4"
#CAMID="$2"
#NAME="$5"
#STATE="$6"
#SERVER=192.168.1.250:7001
FILE="cameraThumbnail?cameraId=$CAMID"
THUMB=https://$CREDS@$SERVER/ec2/$FILE
#NXEVENT=http://144.202.0.208:1337
DIR=/tmp/$CAMID


loop (){
x=$7
while true;
do
mkdir -p /tmp/$CAMID/
#get the screenshot of the camera from dw spectrum
echo test
wget --no-check-certificate "$THUMB"
TIMESTAMP=`date -d "$TME 1 seconds ago" +%Y-%m-%dT%H:%M:%S`
mv $FILE /tmp/$CAMID/FILE
#interest region cropping
#convert -crop +0+200 FILE FILE
#running the deep learning function
#dev line for notification it is running
#curl "http://$CREDS@$SERVER/api/createEvent?source=$SOURCE&caption=Executed&description=$NAME%20using%20$MODEL&metadata=%7B%22cameraRefs%22%3A%5B%22$CAMID%22%5D%7D"
#replace this with model eventually
echo "Running $MODEL"
$MODEL
#getting the results from the deep learning
echo
results
#close the loop
echo "Graceful shutdown"
done
}


yolov3-tiny_xnor (){
cd /root/darknetnx
#run darknet classifier yolov3-tiny
echo "`date` on $CAMID"
./darknet detect cfg/yolov3-tiny_xnor.cfg yolov3-tiny_xnor.weights $DIR/FILE  > $DIR/results.txt
}


yolov3-tiny-prn (){
cd /root/darknetnx
#run darknet classifier yolov3-tiny
echo "`date` on $CAMID"
./darknet detect cfg/yolov3-tiny-prn.cfg yolov3-tiny-prn.weights $DIR/FILE  > $DIR/results.txt
}



darknet-yolov3-tiny (){
cd /root/darknetnx
#run darknet classifier yolov3-tiny
echo "`date` on $CAMID"
./darknet detect cfg/yolov3-tiny.cfg yolov3-tiny.weights $DIR/FILE  > $DIR/results.txt
}

darknet-yolov3 (){
#run darknet classifier yolov3
echo "`date` on $CAMID"
./darknet detect cfg/yolov3.cfg yolov3.weights $DIR/FILE  > $DIR/results.txt
}

darknet-yolov4 (){
#run darknet classifier yolov3
echo "`date` on $CAMID"
./alaxeyab/darknet detect cfg/yolov4.cfg yolov4.weights $DIR/FILE -ext_output $DIR/FILE.OUT $DIR/results.txt  > $DIR/results.txt
}

darknet-yolov4-tiny (){
#run darknet classifier yolov3
echo "`date` on $CAMID"
./alaxeyab/darknet detect cfg/yolov4-tiny.cfg yolov4-tiny.weights $DIR/FILE -ext_output $DIR/FILE.OUT $DIR/results.txt > $DIR/results.txt
}


machinebox (){
#run machinebox image classifier
echo "Launching AI with the model: $STATE"
#upload saved state file
curl -X POST -F file=@states/$STATE $MACHINEBOX/tagbox/state 2>/dev/null
#pass the image to the classifier
curl -X POST -F 'file=@FILE' $MACHINEBOX/tagbox/check > results.txt 2>/dev/null
}

sendnx (){
echo "sending nx"
NUMBER=`cat /$DIR/results.txt | grep 'car\|person\|truck\|vehicle\|cat\|dog' | head -n1 | awk '{ print $2 }' | tr -d '%'`
echo "Send generic event to DW Server at $SERVER"
#send generic event to dw spectrum
echo "$NUMBER"
curl -k "https://$CREDS@$SERVER/api/createEvent?timestamp=$TIMESTAMP&source=$SOURCE-$NAME&caption=$RESULT%20$NUMBER%25&description=$NAME%20using%20$MODEL&metadata=%7B%22cameraRefs%22%3A%5B%22$CAMID%22%5D%7D"


#send notification via nxevents and pushover with a thumbnail
#echo "Send pushover via nxevents"
#curl --silent "$NXEVENT/hooks/quickmark?camid=$CAMID&server=720fd27e-04cc-4c1a-a2cb-990bd167e9c3.relay.vmsproxy.com&user=ai&pass=ai123456&pushovertoken=armxjs7pxawfkiczctemozi8iq8rkp&pushoveruser=uxon9seqnxonzkm4jb5rzmw1t3ynvm&desc=$RESULT"

#CLEANUP
rm $DIR/FILE
rm $DIR/FILE
rm $DIR/results.txt
#CLEANUP FINISHED
exit
}

sendpushover (){
echo "sending pushover"
#send to pushover
curl -s \
--form-string "token=$PUSHOVERTOKEN" \
--form-string "user=$PUSHOVERUSER" \
--form-string "title=$NAME" \
--form-string "url=$OPENAPP" \
--form-string "message=$RESULT $CONF detected by blackboxusa.com" \
-F "attachment=@/root/darknetnx/predictions.jpg" \
https://api.pushover.net/1/messages.json
#CLEANUP
rm $DIR/FILE
rm $DIR/FILE
#rm $DIR/results.txt
#CLEANUP FINISHED

}


results (){
#show results
cat $DIR/results.txt
#search for Person or Vehicle on the results
if grep --ignore-case -q 'car' $DIR/results.txt
then
RESULT="Vehicle"
data
elif grep --ignore-case -q 'person' $DIR/results.txt
then
RESULT="Person"
echo "PERSON FOUND HERE"
data
elif grep --ignore-case -q 'truck' $DIR/results.txt
then
RESULT="Vehicle"
data
elif grep --ignore-case -q 'cat' $DIR/results.txt
then
RESULT="Animal"
data
elif grep --ignore-case -q 'vehicle' $DIR/results.txt
then
RESULT="Vehicle"
data
elif grep --ignore-case -q 'dog' $DIR/results.txt
then
RESULT="Animal"
data
elif grep --ignore-case -q 'animal' $DIR/results.txt
then
RESULT="Animal"
data
else
echo "No objects of interest detected"
RESULT="None"
exit
fi
}

data (){
#get the coordinates
CONF=`cat /$DIR/results.txt | grep 'car\|person\|truck\|vehicle\|cat\|dog' | head -n1 | awk '{ print $2 }'`
PERCENT=`cat /$DIR/results.txt | grep 'car\|person\|truck\|vehicle\|cat\|dog' | head -n1 | awk '{ print $2 }' | tr -d '%'`
LEFT=`cat /$DIR/results.txt | grep 'car\|person\|truck\|vehicle\|cat\|dog' | head -n1 | awk '{ print $4 }'`
#TOP=`cat /$DIR/results.txt | head -n1 | grep 'car\|person\|vehicle' | awk '{ print $6 }'`
#WIDTH=`cat /$DIR/results.txt | head -n1 | grep 'car\|person\|vehicle' | awk '{ print $8 }'`
#HEIGHT=`cat /$DIR/results.txt | head -n1 | grep 'car\|person\|vehicle' | awk '{ print $10 }'`
#move previous results to old
mv $DIR/$RESULT-coords.txt $DIR/$RESULT-coordsold.txt
#mv $DIR/topcoords.txt $DIR/topcoordsold.txt
#create new result
#left variable pixel
echo $LEFT > $DIR/$RESULT-coords.txt
OLDCOORD=`cat $DIR/$RESULT-coordsold.txt`
NEWCOORD=`cat $DIR/$RESULT-coords.txt`
#sort the variables by size for easy subtraction
VAL1=`echo "$OLDCOORD $NEWCOORD" | tr " " "\n" | sort -rnu | head -n1`
VAL2=`echo "$OLDCOORD $NEWCOORD" | tr " " "\n" | sort -rnu | tail -n1`
#subtract the coordinates for a difference number
if test -f "$DIR/$RESULT-coordsold.txt"; then
DIFF=$(($VAL1 - $VAL2))
else
DIFF=$((200 - 100))
fi
echo "OBJECT: $RESULT"
echo "CONFIDENCE: $CONF"
echo "LEFT DIFFERENCE: $DIFF"

#if the difference between the object is greater than 50 pixels report as new object
if [[ "$RESULT" == *"Vehicle"* ]] && [ $DIFF -gt 50 ]
then
echo "New vehicle object event"
echo "using vehicle rules"
sendnx
#sendpushover
#if the result is person and the pixel difference is 10
elif [[ "$RESULT" = *"Person"* ]] && [ $DIFF -gt 20 ]
 then
echo "New person object event"
sendnx
#sendpushover
elif [[ "$RESULT" == *"Animal"* ]] && [ $DIFF -gt 30 ]
 then
echo "New animal object event"
sendnx
#sendpushover
else
echo "Object: $RESULT"
echo "Similar object detected not reporting or low confidence"
fi
#end the if statement
exit
}


echo
echo
echo "Running AI with $MODEL on $CAMID"
#how many times are we running the loop after motion start in nx (3 times)
echo "STARTING NOW"
echo "Running the loop $RUNTIME times"

loop
