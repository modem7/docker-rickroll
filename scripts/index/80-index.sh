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
OVERLAY="${OVERLAY:-"random"}"

LOOP_ATTR=""
if [ "$LOOP" = "true" ]; then
    LOOP_ATTR="loop"
fi

HEADLINE_HTML=""
if [ -n "$HEADLINE" ]; then
    HEADLINE_HTML="<h1 id=\"headline\" class=\"hidden\">$HEADLINE</h1>"
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
            z-index: 0;
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
            z-index: 20;
            pointer-events: none;
        }

        .hidden {
            display: none !important;
        }

        /* Sits over the video so nothing plays visibly until the reveal -
           the video itself keeps loading/playing muted underneath the
           whole time, so it's instantly ready once this is hidden. */
        .backdrop {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 5;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        #site-backdrop {
            background: #18181b;
        }

        .fake-header {
            height: 56px;
            background: #212124;
            border-bottom: 1px solid #3f3f46;
            display: flex;
            align-items: center;
            padding: 0 20px;
            gap: 16px;
        }

        .fake-logo {
            width: 110px;
            height: 20px;
            background: #3f3f46;
            border-radius: 4px;
        }

        .fake-nav {
            display: flex;
            gap: 12px;
            margin-left: auto;
        }

        .fake-nav span {
            width: 56px;
            height: 12px;
            background: #3f3f46;
            border-radius: 6px;
        }

        .fake-content {
            padding: 40px;
            max-width: 720px;
        }

        .skeleton-block {
            height: 18px;
            background: #3f3f46;
            border-radius: 4px;
            margin-bottom: 14px;
            width: 100%;
        }

        .skeleton-block.short {
            width: 55%;
        }

        .prompt {
            position: fixed;
            left: 0;
            right: 0;
            z-index: 10;
        }

        #cookie-banner {
            bottom: 0;
            background: #27272a;
            color: #f4f4f5;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            border-top: 1px solid #3f3f46;
            box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.4);
        }

        #cookie-banner p {
            margin: 0;
            font-size: 14px;
            line-height: 1.5;
            max-width: 640px;
            color: #d4d4d8;
        }

        #cookie-banner button {
            flex-shrink: 0;
            background: #f4f4f5;
            color: #18181b;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        #site-error {
            top: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #site-error .card {
            background: #27272a;
            color: #f4f4f5;
            padding: 28px 32px;
            border-radius: 8px;
            text-align: center;
            max-width: 280px;
            border: 1px solid #3f3f46;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.5);
        }

        #site-error .card p.title {
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 6px;
        }

        #site-error .card p.code {
            font-size: 13px;
            color: #a1a1aa;
            margin: 0 0 16px;
        }

        #site-error button {
            background: #f4f4f5;
            color: #18181b;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        #loading-screen {
            background: #18181b;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #loading-screen .wrap {
            text-align: center;
        }

        .spinner {
            width: 40px;
            height: 40px;
            margin: 0 auto 16px;
            border: 3px solid #3f3f46;
            border-top-color: #f4f4f5;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        #loading-screen p.status {
            color: #a1a1aa;
            font-size: 14px;
            margin: 0;
        }

        #loading-fallback {
            margin-top: 16px;
            color: #a1a1aa;
            font-size: 13px;
            cursor: pointer;
            text-decoration: underline;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        #loading-fallback.shown {
            opacity: 1;
        }
    </style>
</head>
<body>
    $HEADLINE_HTML
    <video id="video" autoplay muted $LOOP_ATTR playsinline>
        <source src="$VIDEO_FILE" type="video/mp4">
        Sorry, your browser doesn't support embedded videos.
    </video>

    <div id="site-backdrop" class="backdrop hidden">
        <div class="fake-header">
            <div class="fake-logo"></div>
            <div class="fake-nav"><span></span><span></span><span></span></div>
        </div>
        <div class="fake-content">
            <div class="skeleton-block"></div>
            <div class="skeleton-block"></div>
            <div class="skeleton-block short"></div>
        </div>
    </div>

    <div id="loading-screen" class="backdrop hidden">
        <div class="wrap">
            <div class="spinner"></div>
            <p class="status">Loading...</p>
            <p id="loading-fallback">Taking longer than expected? Click to continue</p>
        </div>
    </div>

    <div id="cookie-banner" class="prompt hidden">
        <p>This site uses cookies to improve your experience.</p>
        <button type="button">Accept</button>
    </div>

    <div id="site-error" class="prompt hidden">
        <div class="card">
            <p class="title">Something went wrong</p>
            <p class="code">Error 500</p>
            <button type="button">Reload</button>
        </div>
    </div>

    <noscript>
        <p style="position:fixed;top:0;left:0;right:0;color:#fff;background:#000;font-family:sans-serif;text-align:center;padding:8px;margin:0;">
            <a href="$VIDEO_FILE" style="color:#fff;">Click to play</a>
        </p>
    </noscript>

    <script>
        (function () {
            var video = document.getElementById('video');
            var headline = document.getElementById('headline');
            var title = "$TITLE";

            var validTypes = ['cookie', 'error', 'loading'];
            var configured = "$OVERLAY".split(',').map(function (s) { return s.trim(); })
                .filter(function (s) { return validTypes.indexOf(s) !== -1; });
            var enabled = configured.length > 0 ? configured : validTypes;
            var choice = enabled[Math.floor(Math.random() * enabled.length)];

            var siteBackdrop = document.getElementById('site-backdrop');
            var loadingScreen = document.getElementById('loading-screen');
            var cookieBanner = document.getElementById('cookie-banner');
            var siteError = document.getElementById('site-error');

            if (choice === 'loading') {
                loadingScreen.classList.remove('hidden');
                setTimeout(function () {
                    var fallback = document.getElementById('loading-fallback');
                    if (fallback) {
                        fallback.classList.add('shown');
                    }
                }, 3000);
            } else {
                siteBackdrop.classList.remove('hidden');
                (choice === 'cookie' ? cookieBanner : siteError).classList.remove('hidden');
            }

            var events = ['click', 'keydown', 'touchstart', 'pointerdown'];

            function reveal() {
                video.muted = false;
                video.play().catch(function () {});
                document.title = title;
                if (headline) {
                    headline.classList.remove('hidden');
                }
                siteBackdrop.classList.add('hidden');
                loadingScreen.classList.add('hidden');
                cookieBanner.classList.add('hidden');
                siteError.classList.add('hidden');
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
echo "Overlay: $OVERLAY"
echo "#####################"
echo ""

exec "$@"
