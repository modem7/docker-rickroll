FROM nginx:mainline-alpine as build-stage

COPY src/ /usr/share/nginx/html/
COPY MP4/rickroll.mp4 /usr/share/nginx/html/rickroll.mp4
COPY conf/nginx-site.conf /etc/nginx/conf.d/default.conf

FROM nginx:mainline-alpine
COPY --from=build-stage /usr/share/nginx/html/ /usr/share/nginx/html/
COPY --from=build-stage /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 8080