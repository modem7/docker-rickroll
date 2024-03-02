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
    proxy_temp_path /tmp/proxy_temp;
    proxy_cache_path /tmp/mycache inactive=1h levels=1:2 use_temp_path=off keys_zone=mycache:10m max_size=200m;
    client_body_temp_path /tmp/client_temp;
    fastcgi_temp_path /tmp/fastcgi_temp;
    uwsgi_temp_path /tmp/uwsgi_temp;
    scgi_temp_path /tmp/scgi_temp;

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
        # add proxy caches
        listen       ${PORT};

        root /usr/share/nginx/html;
        index index.html;

        # Make site accessible from http://localhost/
        server_name _;

        error_page 404 /index.html;

        location ~ \.flv$ {
            # enable thread pool
            aio threads=default;
            flv;
        }

        location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|tiff|ttf|svg|mp4)$ {
            mp4;
            mp4_buffer_size     1M;
            mp4_max_buffer_size 20M;
            
            add_header Accept-Ranges bytes;
            # proxy_force_ranges on;
            
            proxy_buffering on;

            # add_header X-Proxy-Cache $upstream_cache_status;
            add_header X-Cache-Status $upstream_cache_status;

            aio threads=default;
            
            # enable caching for mp4 videos
            proxy_cache mycache;
            proxy_cache_valid any 1h;
            proxy_cache_lock on;
            proxy_cache_background_update on;
            proxy_cache_revalidate on;

            # enable nginx slicing
            slice              1m;
            proxy_cache_key    $host$uri$is_args$args$slice_range;
            #proxy_cache_key    $uri$is_args$args$slice_range;
            proxy_set_header   Range $slice_range;
            proxy_http_version 1.1;

            # Immediately forward requests to the origin if we are filling the cache
            proxy_cache_lock_timeout 0s;

            # Set the 'age' to a value larger than the expected fill time
            proxy_cache_lock_age 200s;

            proxy_cache_use_stale updating;
            
            proxy_pass http://localhost:${PORT};
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