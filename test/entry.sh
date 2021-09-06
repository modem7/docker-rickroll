#!/bin/sh
#Variables
FILEURL=$(https://share.modem7.com/nEsO3/fEduWuXa02.mp4);
# Download Video
curl $FILEURL --output /usr/share/nginx/html/rickroll.mp4
