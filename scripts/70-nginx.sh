#!/bin/sh

set -eu

PORT="${PORT:-"8080"}"

# Create nginx conf with port variable
tee /etc/nginx/nginx.conf << 'EOF' >/dev/null
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /tmp/nginx.pid;

events {
    accept_mutex off;
    worker_connections  1024;
}

http {
    client_body_temp_path /tmp/client_temp;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log    /var/log/nginx/access.log  main;
    include       /etc/nginx/conf.d/*.conf;
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile_max_chunk 512k;
    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;
    gzip  on;
    gzip_proxied any;
    gzip_vary on;
    gzip_http_version 1.1;

    server {
        listen       ${PORT};

        root /usr/share/nginx/html;
        index index.html;

        # Make site accessible from http://localhost/
        server_name _;

        error_page 404 /index.html;

        location ~ \.mp4$ {
            # nginx's own mp4 pseudo-streaming module plus native Range
            # support already handle seeking/scrubbing efficiently via
            # sendfile - no need to proxy back to ourselves through
            # proxy_cache/slice, since there's no remote/slow origin here,
            # just a local file.
            mp4;
            mp4_buffer_size     1M;
            mp4_max_buffer_size 20M;

            add_header Accept-Ranges bytes;

            # enable thread pool so large reads don't block the event loop
            aio threads=default;
        }
    }
}
EOF

tee /etc/nginx/conf.d/health-check.conf << 'EOF' >/dev/null
server {
    listen       9090;
    server_name  localhost;

    location /healthz {
        access_log off;
        error_log   off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Apply port variable
sed -i s/'${PORT}'/${PORT}/g /etc/nginx/nginx.conf

echo ""
echo "#####################"
echo "Nginx running on port $PORT"
echo "#####################"
echo ""

exec "$@"
