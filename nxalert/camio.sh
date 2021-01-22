#!/bin/sh
#get the latest bookmark start time
SOURCE="NxGIF"
#CONFIG=/root/nxgif/config.json
#TAG=`sed  -n '3p' < $DIR/$CONFIG`
#DESCRIPTION=`sed  -n '5p' < $DIR/$CONFIG`
#LENGTH=`sed  -n '6p' < $DIR/$CONFIG`
#CAMID=`sed  -n '7p' < $DIR/$CONFIG`
#SERVER=`sed  -n '8p' < $DIR/$CONFIG`
#CREDS=`sed  -n '9p' < $DIR/$CONFIG`
BUCKET=`sed  -n '10p' < $DIR/$CONFIG`
S3=`sed  -n '11p' < $DIR/$CONFIG`
PTOKEN=`sed  -n '12p' < $DIR/$CONFIG`
PUSER=`sed  -n '13p' < $DIR/$CONFIG`
TIME=`date +%s`
CAMID=$1
SERVER=$2
USER=$3
PASS=$4
PUSHOVERTOKEN="$5"
PUSHOVERUSER="$6"
QUERY="$7"
CREDS="$3:$4"
sleep 2

echo $CAMID
echo $SERVER
echo $CREDS
echo $CAMID
#find the latest created bookmark
#LATEST=`curl -s -u $CREDS -k "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep "creationTimeStampMs" | sort | tail -n1 | sed 's/[^0-9]*//g'`
#find the start epoch time
#START=`curl -s -u $CREDS -k "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "startTimeMs" | tail -n1 | awk '{print $3}' | sed 's/[^0-9]*//g'`
#get the bookmark length
#DURATION=`curl -s -u $CREDS "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "durationMs" | tail -n1 | awk '{print $3}' | sed 's/[^0-9]*//g'`
#get the name of the bookmark
#NAME=`curl -s -u $CREDS "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "name" | tail -n1 | cut -d' ' -f2- | cut -d' ' -f2- | cut -d' ' -f2- | tr -d '"' | tr -d ','`
#get the description from the bookmark
#DESCRIPTION=`curl -s -u $CREDS "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "description" | tail -n1 | cut -d' ' -f2- | cut -d' ' -f2- | cut -d' ' -f2- | tr -d '"' | tr -d ','`
#echo "$LATEST"
#echo "$START"
#echo "$DURATION"
#echo "$NAME"
#echo "$DESCRIPTION"
#GIF="$CAMID.$START.jpg"
FILE="cameraThumbnail?cameraId=$CAMID"
wget $FILE http://$CREDS@$SERVER/ec2/cameraThumbnail?cameraId=$CAMID
sleep 0
echo $FILE
#turn video to gif
#ffmpeg -i "/root/nxgif/$FILE" -vf "fps=1,scale=320:-1:flags=lanczos,palettegen" palette.png
#ffmpeg -i "/root/nxgif/$FILE" -i palette.png -filter_complex "fps=1,scale=400:-1:flags=lanczos[x];[x][1:v]paletteuse"  -loop 0 /root/nxgif/$GIF

#this way to copy it to the cloud
#rclone copy $GIF s3:$BUCKET/
#URL="https://s3.wasabisys.com/$BUCKET/$GIF"
#PLAYBACK="https://$CREDS@$SERVER/static/index.html#/view/$CAMID?time=$START"
#MAGIC URL TO OPEN THE VIDEO
OPENAPP="http://$CREDS@$SERVER/media/$CAMID.webm?resolution=320p&pos=$START"
#echo $URL
#echo "$PLAYBACK"
#/root/nxgif/pushover -T $PTOKEN -U $PUSER -u $URL NxGIF
CAMIO="https://video.retrospectvms.com/app/#search;q="
curl -s \
--form-string "token=$PUSHOVERTOKEN" \
--form-string "user=$PUSHOVERUSER" \
--form-string "title=Virtual Guard" \
--form-string "url=$CAMIO$QUERY" \
--form-string "message=$QUERY" \
-F "attachment=@/root/nxgif/$FILENULL" \
https://api.pushover.net/1/messages.json
sleep 2
rm $FILE
#rm $GIF
#rm  palette.png
echo "Done"
