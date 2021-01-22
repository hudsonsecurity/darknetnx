#!/bin/sh
#get the latest bookmark start time
SOURCE="Bookmark2Gif"
TAG=`sed  -n '3p' < $DIR/$1`
DESCRIPTION=`sed  -n '5p' < $DIR/$1`
LENGTH=`sed  -n '6p' < $DIR/$1`
CAMID=`sed  -n '7p' < $DIR/$1`
SERVER=`sed  -n '8p' < $DIR/$1`
CREDS=`sed  -n '9p' < $DIR/$1`
BUCKET=`sed  -n '10p' < $DIR/$1`
S3=`sed  -n '11p' < $DIR/$1`
PTOKEN=`sed  -n '12p' < $DIR/$1`
PUSER=`sed  -n '13p' < $DIR/$1`
TIME=`date +%s`
echo $CAMID
echo $SERVER
echo $CREDS
CAMID="$2"
echo $CAMID
LATEST=`curl -s -u $CREDS -k "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep "creationTimeStampMs" | sort | tail -n1 | sed 's/[^0-9]*//g'`
START=`curl -s -u $CREDS -k "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "startTimeMs" | tail -n1 | awk '{print $3}' | sed 's/[^0-9]*//g'`
#get the bookmark length
DURATION=`curl -s -u $CREDS "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "durationMs" | tail -n1 | awk '{print $3}' | sed 's/[^0-9]*//g'`
NAME=`curl -s -u $CREDS "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "name" | tail -n1 | cut -d' ' -f2- | cut -d' ' -f2- | cut -d' ' -f2- | tr -d '"' | tr -d ','`
DESCRIPTION=`curl -s -u $CREDS "$SERVER/ec2/bookmarks?cameraId={$CAMID}" | jshon | grep -n12 "$LATEST" | grep "description" | tail -n1 | cut -d' ' -f2- | cut -d' ' -f2- | cut -d' ' -f2- | tr -d '"' | tr -d ','`
echo "$LATEST"
echo "$START"
echo "$DURATION"
echo "$NAME"
echo "$DESCRIPTION"
GIF="$CAMID.$START.gif"
FILE="$CAMID.bookmark.mkv"
wget --timeout 20 -O $FILE http://$CREDS@$SERVER/hls/$CAMID.mkv?pos=$START&duration=$DURATION
sleep 15

#turn video to gif
ffmpeg -i "/root/nxgif/$FILE" -vf "fps=3,scale=320:-1:flags=lanczos,palettegen" palette.png
ffmpeg -i "/root/nxgif/$FILE" -i palette.png -filter_complex "fps=3,scale=400:-1:flags=lanczos[x];[x][1:v]paletteuse"  -loop 0 /root/nxgif/$GIF
rclone copy $GIF s3:$BUCKET/
URL="https://s3.wasabisys.com/$BUCKET/$GIF"
PLAYBACK="https://$CREDS@$SERVER/static/index.html#/view/$CAMID?time=$START"
OPENAPP="http://$CREDS@$SERVER/media/$CAMID.webm?resolution=320p&pos=$START"
echo $URL
echo "$PLAYBACK"
#/root/nxgif/pushover -T $PTOKEN -U $PUSER -u $URL NxGIF
curl -s \
--form-string "token=$PTOKEN" \
--form-string "user=$PUSER" \
--form-string "title=$NAME" \
--form-string "url=$OPENAPP" \
--form-string "message=$DESCRIPTION" \
-F "attachment=@/root/nxgif/$GIF" \
https://api.pushover.net/1/messages.json
sleep 4
rm $FILE
rm $GIF
rm  palette.png
echo "Done"
