#!/bin/sh

set -eu

TITLE="${TITLE:-"Rickroll"}"

#Create nginx conf
tee /etc/nginx/conf.d/default.conf << 'EOF' >/dev/null
server {
    listen       8080;

    root /usr/share/nginx/html;
    index index.html;

    # Make site accessible from http://localhost/
    server_name _;

    error_page 404 /index.html;

    location /healthz {
        return 200;
    }

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to index.html
        try_files $uri =404;
    }

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|tiff|ttf|svg|mp4)$ {
        expires 5d;
    }
}
EOF

#Create index.html
tee /usr/share/nginx/html/index.html << EOF >/dev/null
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>$TITLE</title>
</head>
<body>
<div style="text-align: center;">
  <video width="100%" loop poster="download.jpg" onclick="if (typeof InstallTrigger == 'undefined') (this.paused ? this.play() : this.pause());">
    <source src="rickroll.mp4" type="video/mp4">
  </video>
<style>
    video {
        height: 100vh;
        width: 100%;
        object-fit: cover; /**/ use "cover" to avoid distortion
        position: absolute;
    }
</style>
</div>
</html>
EOF

exec "$@"