FROM nginx:stable-alpine as build-stage

COPY 4k/src/ /usr/share/nginx/html/
COPY MP4/4k/rickroll.mp4 /usr/share/nginx/html/rickroll.mp4
COPY 4k/conf/nginx-site.conf /etc/nginx/conf.d/default.conf

FROM nginx:stable-alpine
COPY --from=build-stage /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=build-stage /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 8080