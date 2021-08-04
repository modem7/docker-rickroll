FROM nginx:1.21.1-alpine

ADD src/ /usr/share/nginx/html/
ADD conf/nginx-site.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 8080
