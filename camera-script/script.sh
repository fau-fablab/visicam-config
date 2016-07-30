#/bin/bash
DEVICE=/dev/video0
test -e $DEVICE || DEVICE=/dev/video1
rm /opt/VisiCam/still.jpg
SCRIPTDIR=/opt/VisiCam/camera-script/
# disable "backlight compensation" damit belichtung nicht hart kaputt geht
v4l2ctrl -d $DEVICE -l $SCRIPTDIR/v4l2ctrl-settings
touch /opt/VisiCam/still.jpg
fswebcam -d $DEVICE -r 1600x1200 --flip h,v --no-banner --set "Brightness"="128" --set "Contrast"="32" --set "Gain"="200" --jpeg 100 /opt/VisiCam/still.jpg > $SCRIPTDIR/log
# fswebcam ist zu blöd saubere ausgabe zu liefern
test -s /opt/VisiCam/still.jpg || { >&2 cat $SCRIPTDIR/log; exit 1; }
