#!/bin/sh

set -eu

PORT="${PORT:-"8080"}"

# Create nginx conf with port variable
tee /etc/nginx/nginx.conf << EOF >/dev/null
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

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log    /var/log/nginx/access.log  main;
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
        server_name  _;
        root         /usr/share/nginx/html;
        index        index.html;

        error_page 404 /index.html;

        # static files + media
        location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|tiff|ttf|svg|mp4)$ {
            # caching for mp4/videos
            aio threads=default;
            mp4;
            mp4_buffer_size     1M;
            mp4_max_buffer_size 20M;

            add_header Accept-Ranges bytes;
            add_header X-Cache-Status \$upstream_cache_status;

            proxy_buffering on;

            proxy_cache mycache;
            proxy_cache_valid any 1h;
            proxy_cache_lock on;
            proxy_cache_background_update on;
            proxy_cache_revalidate on;

            slice              1m;
            proxy_cache_key    \$host\$uri\$is_args\$ar_
