FROM nginx:stable-alpine as build-stage

COPY 1080/src/ /usr/share/nginx/html/
COPY MP4/1080/rickroll.mp4 /usr/share/nginx/html/rickroll.mp4
COPY 1080/conf/nginx-site.conf /etc/nginx/conf.d/default.conf

FROM nginx:stable-alpine
COPY --from=build-stage /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=build-stage /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 8080