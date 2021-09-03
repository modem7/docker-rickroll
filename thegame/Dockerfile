FROM nginx:mainline-alpine as build-stage

COPY thegame/src/ /usr/share/nginx/html/
COPY MP4/1080/rickroll.mp4 /usr/share/nginx/html/rickroll.mp4
COPY thegame/conf/nginx-site.conf /etc/nginx/conf.d/default.conf

FROM nginx:mainline-alpine
COPY --from=build-stage /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=build-stage /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
    CMD curl -fSs 127.0.0.1:80/healthz || exit 1