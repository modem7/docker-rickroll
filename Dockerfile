# syntax = docker/dockerfile:latest

FROM nginxinc/nginx-unprivileged:1.27.1-alpine

USER root

ARG UID=101
ARG GID=101

# Copy files into image
COPY --link MP4/1080/*.mp4 /usr/share/nginx/html/
COPY --link --chmod=755 scripts/*.sh /docker-entrypoint.d/
COPY --link --chmod=755 scripts/index/80-index.sh /docker-entrypoint.d/

# Change permissions to index.html
RUN chown $UID:0 /usr/share/nginx/html/index.html

# Document what port is required
EXPOSE 8080

healthcheck --interval=30s --timeout=10s --retries=3 --start-period=10s \
   cmd curl -fss http://localhost:9090/healthz || exit 1

STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]