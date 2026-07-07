#!/bin/sh

set -eu

OVERLAY="${OVERLAY:-"random"}"

# Create index.html
tee /usr/share/nginx/html/index.html << EOF >/dev/null
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Loading...</title>
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
            height: 100vh;
            width: 100%;
            object-fit: cover;
        }

        .overlay {
            position: fixed;
            left: 0;
            right: 0;
            z-index: 10;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        #cookie-banner {
            bottom: 0;
            background: #fff;
            color: #222;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.2);
        }

        #cookie-banner p {
            margin: 0;
            font-size: 14px;
            line-height: 1.5;
            max-width: 640px;
        }

        #cookie-banner button {
            flex-shrink: 0;
            background: #1a73e8;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
        }

        #site-error {
            top: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #site-error .card {
            background: #fff;
            color: #222;
            padding: 28px 32px;
            border-radius: 8px;
            text-align: center;
            max-width: 280px;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.3);
        }

        #site-error .card p.title {
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 6px;
        }

        #site-error .card p.code {
            font-size: 13px;
            color: #666;
            margin: 0 0 16px;
        }

        #site-error button {
            background: #f1f3f4;
            color: #222;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
        }

        .hidden {
            display: none !important;
        }
    </style>
</head>
<body>
    <video id="video" autoplay muted loop playsinline>
        <source src="video.mp4" type="video/mp4">
        Sorry, your browser doesn't support embedded videos.
    </video>

    <div id="cookie-banner" class="overlay hidden">
        <p>This site uses cookies to improve your experience.</p>
        <button type="button">Accept</button>
    </div>

    <div id="site-error" class="overlay hidden">
        <div class="card">
            <p class="title">Something went wrong</p>
            <p class="code">Error 500</p>
            <button type="button">Reload</button>
        </div>
    </div>

    <noscript>
        <p style="position:fixed;top:0;left:0;right:0;color:#fff;background:#000;font-family:sans-serif;text-align:center;padding:8px;margin:0;">
            <a href="video.mp4" style="color:#fff;">Click to play</a>
        </p>
    </noscript>

    <script>
        (function () {
            var video = document.getElementById('video');
            var overlays = {
                cookie: document.getElementById('cookie-banner'),
                error: document.getElementById('site-error')
            };
            var forced = "$OVERLAY";
            var choice = (forced === 'cookie' || forced === 'error')
                ? forced
                : (Math.random() < 0.5 ? 'cookie' : 'error');
            overlays[choice].classList.remove('hidden');

            var events = ['click', 'keydown', 'touchstart', 'pointerdown'];

            function reveal() {
                video.muted = false;
                video.play().catch(function () {});
                document.title = 'Rickroll';
                overlays.cookie.classList.add('hidden');
                overlays.error.classList.add('hidden');
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
echo "Overlay: $OVERLAY"
echo "#####################"
echo ""

exec "$@"
