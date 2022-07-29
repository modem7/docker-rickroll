# syntax = docker/dockerfile:latest

FROM nginxinc/nginx-unprivileged:1.23.1-alpine as build-stage

COPY --link SD/src/ /usr/share/nginx/html/
COPY --link MP4/SD/rickroll.mp4 /usr/share/nginx/html/rickroll.mp4
COPY --link SD/conf/nginx-site.conf /etc/nginx/conf.d/default.conf

FROM nginxinc/nginx-unprivileged:1.23.1-alpine

ARG UID=101
ARG GID=101

COPY --link --chown=$UID:0 --chmod=755 --from=build-stage /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --link --chown=$UID:0 --chmod=644 --from=build-stage /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
    CMD curl -fSs 127.0.0.1:8080/healthz || exit 1

STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]