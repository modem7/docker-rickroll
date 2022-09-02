#!/bin/sh

set -eu

PORT="${PORT:-"8080"}"

# Create nginx conf with port variable
tee /etc/nginx/conf.d/default.conf << 'EOF' >/dev/null
server {
    listen       ${PORT};

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

# Apply port variable
sed -i s/'${PORT}'/${PORT}/g /etc/nginx/conf.d/default.conf

echo "Nginx running on port $PORT"

exec "$@"