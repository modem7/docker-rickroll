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

        /* object-fit: cover looks great on a wide/landscape screen, but
           this video is 16:9 - on a narrow/portrait viewport (basically
           any phone held normally), cover has to scale the video up so
           much to fill the height that it ends up extremely cropped and
           zoomed in, losing most of the picture. Switch to contain
           (letterboxed, but the whole frame is visible) for anything
           narrower than it is tall, regardless of the OBJECT_FIT setting
           above - cover never looks right in that situation. */
        @media (max-aspect-ratio: 1/1) {
            video {
                object-fit: contain;
                background: #000;
            }
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

        .prompt {
            position: fixed;
            left: 0;
            right: 0;
            z-index: 10;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        #cookie-banner {
            bottom: 0;
            z-index: 15;
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

        /* A genuine 500/502 error is usually rendered by a completely
           different layer of the stack than the site itself (the load
           balancer, the CDN, a generic web server default page) - it
           doesn't inherit the site's own styling. A plain white
           full-page takeover that looks nothing like the dark theme
           everywhere else sells that far better than a dark modal
           floating over visible page content would. */
        #site-error {
            top: 0;
            bottom: 0;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 24px;
        }

        #site-error .icon {
            width: 56px;
            height: 56px;
            margin-bottom: 20px;
        }

        #site-error .code {
            font-size: 64px;
            font-weight: 700;
            color: #1a1a1a;
            line-height: 1;
            margin: 0 0 8px;
        }

        #site-error .title {
            font-size: 18px;
            font-weight: 600;
            color: #1a1a1a;
            margin: 0 0 12px;
        }

        #site-error .message {
            font-size: 14px;
            color: #6b6b6b;
            max-width: 360px;
            line-height: 1.6;
            margin: 0 0 28px;
        }

        #site-error button {
            background: #1a1a1a;
            color: #fff;
            border: none;
            padding: 12px 28px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        #site-error .reference {
            margin-top: 28px;
            font-size: 12px;
            color: #9a9a9a;
            font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
        }

        #loading-screen {
            top: 0;
            bottom: 0;
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

    <div id="loading-screen" class="prompt hidden">
        <div class="wrap">
            <div class="spinner"></div>
            <p class="status">Loading...</p>
            <p id="loading-fallback">Taking longer than expected? Click to continue</p>
        </div>
    </div>

    <div id="site-error" class="prompt hidden">
        <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
        </svg>
        <p class="code">500</p>
        <p class="title">Internal Server Error</p>
        <p class="message">The server encountered an internal error and was unable to complete your request.</p>
        <button type="button">Reload page</button>
        <p class="reference" id="error-reference"></p>
    </div>

    <div id="cookie-banner" class="prompt hidden">
        <p>This site uses cookies to improve your experience.</p>
        <button type="button">Accept</button>
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

            function randomHex(len) {
                var s = '';
                for (var i = 0; i < len; i++) {
                    s += Math.floor(Math.random() * 16).toString(16);
                }
                return s.toUpperCase();
            }

            // "loading" and "error" are mutually exclusive page states - a
            // page can't be both at once - so one of those two is picked
            // at random. The cookie banner isn't a page state, it's site
            // chrome that would realistically show up regardless of what
            // the page underneath is doing, so it's always shown on top
            // of whichever one gets picked, rather than being a third
            // option that could be picked instead of them.
            var validTypes = ['error', 'loading'];
            var configured = "$OVERLAY".split(',').map(function (s) { return s.trim(); })
                .filter(function (s) { return validTypes.indexOf(s) !== -1; });
            var enabled = configured.length > 0 ? configured : validTypes;
            var choice = enabled[Math.floor(Math.random() * enabled.length)];

            var loadingScreen = document.getElementById('loading-screen');
            var cookieBanner = document.getElementById('cookie-banner');
            var siteError = document.getElementById('site-error');

            cookieBanner.classList.remove('hidden');

            if (choice === 'loading') {
                loadingScreen.classList.remove('hidden');
                setTimeout(function () {
                    var fallback = document.getElementById('loading-fallback');
                    if (fallback) {
                        fallback.classList.add('shown');
                    }
                }, 3000);
            } else {
                siteError.classList.remove('hidden');
                var ref = document.getElementById('error-reference');
                if (ref) {
                    ref.textContent = 'Reference #' + randomHex(8);
                }
            }

            var events = ['click', 'keydown', 'touchstart', 'pointerdown'];

            function reveal() {
                video.muted = false;
                video.play().catch(function () {});
                document.title = title;
                if (headline) {
                    headline.classList.remove('hidden');
                }
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
