FROM nginx:stable-alpine

COPY src/ /usr/share/nginx/html/
COPY conf/nginx-site.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 8080
