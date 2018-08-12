#/bin/bash
set -e
rm -f /opt/VisiCam/still.jpg

SCRIPTDIR=/opt/VisiCam/camera-script/
LOG=$SCRIPTDIR/log
function errormessage {
    echo "$@" | tee -a $LOG >&2
}

function die {
    errormessage "$@"
    exit 1
}

# find camera device by name
# to list all names, run: find /sys/devices/ -regex '.*video4linux.*' -name name | xargs
NAME="UVC Camera (046d:0809)"
#NAME="Integrated Camera"
camera_by_name=$(find /sys/devices/ -regex '.*video4linux.*' -name name | xargs grep -l "$NAME" | sort | head -n1)
if [ ! -z $camera_by_name ]; then
    DEVICE=/dev/$(basename $(dirname $camera_by_name)/)
else
    errormessage "cannot find camera '$NAME'. Falling back to device scanning."
    DEVICE=/dev/video0
fi

# fallback
test -e $DEVICE || DEVICE=/dev/video1
test -e $DEVICE || DEVICE=/dev/video2
test -e $DEVICE || DEVICE=/dev/video3
test -e $DEVICE || { die "Cannot find any video device. Exiting."; }


# disable "backlight compensation" damit belichtung nicht hart kaputt geht
v4l2ctrl -d $DEVICE -l $SCRIPTDIR/v4l2ctrl-settings
touch /opt/VisiCam/still.jpg
fswebcam -d $DEVICE -r 1600x1200 --flip h,v --no-banner --set "Brightness"="128" --set "Contrast"="32" --set "Gain"="200" --jpeg 100 /opt/VisiCam/still.jpg > $LOG
# fswebcam ist zu blöd saubere ausgabe zu liefern
test -s /opt/VisiCam/still.jpg || { >&2 cat $LOG; exit 1; }
