#!/bin/sh

set -eu

TITLE="${TITLE:-"Rickroll"}"
PRE_TITLE="${PRE_TITLE:-"Loading..."}"
HEADLINE="${HEADLINE:-""}"
HEIGHT="${HEIGHT:-"100vh"}"
WIDTH="${WIDTH:-"100%"}"
OBJECT_FIT="${OBJECT_FIT:-"cover"}"
LOOP="${LOOP:-"true"}"
VIDEO_FILE="${VIDEO_FILE:-"video.mp4"}"

LOOP_ATTR=""
if [ "$LOOP" = "true" ]; then
    LOOP_ATTR="loop"
fi

HEADLINE_HTML=""
if [ -n "$HEADLINE" ]; then
    HEADLINE_HTML="<h1 id=\"headline\">$HEADLINE</h1>"
fi

# Create index.html
tee /usr/share/nginx/html/index.html << EOF >/dev/null
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>$PRE_TITLE</title>
    <style>
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            overflow: hidden;
            background: #000;
        }

        video {
            position: fixed;
            top: 0;
            left: 0;
            height: $HEIGHT;
            width: $WIDTH;
            object-fit: $OBJECT_FIT;
        }

        #headline {
            position: fixed;
            top: 1rem;
            left: 0;
            width: 100%;
            margin: 0;
            text-align: center;
            color: #fff;
            font-family: sans-serif;
            text-shadow: 0 0 6px #000;
            z-index: 1;
            pointer-events: none;
        }
    </style>
</head>
<body>
    $HEADLINE_HTML
    <video id="video" autoplay muted playsinline $LOOP_ATTR>
        <source src="$VIDEO_FILE" type="video/mp4">
        Sorry, your browser doesn't support embedded videos.
    </video>
    <noscript>
        <p style="color:#fff;font-family:sans-serif;text-align:center;">
            <a href="$VIDEO_FILE" style="color:#fff;">Click to play</a>
        </p>
    </noscript>
    <script>
        (function () {
            var video = document.getElementById('video');
            var title = "$TITLE";
            var events = ['click', 'keydown', 'touchstart', 'pointerdown', 'mousemove', 'wheel'];

            function reveal() {
                video.muted = false;
                video.play().catch(function () {});
                document.title = title;
                events.forEach(function (evt) {
                    document.removeEventListener(evt, reveal);
                });
            }

            events.forEach(function (evt) {
                document.addEventListener(evt, reveal, { once: true, passive: true });
            });
        })();
    </script>
</body>
</html>
EOF

echo ""
echo "#####################"
echo "Website height: $HEIGHT"
echo "Website width: $WIDTH"
echo "Video file: $VIDEO_FILE (loop=$LOOP, object-fit=$OBJECT_FIT)"
echo "#####################"
echo ""

exec "$@"
