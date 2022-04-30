FROM nginxinc/nginx-unprivileged:1.21.6-alpine

ARG UID=101
ARG GID=101

COPY --chown=$UID:0 --chmod=755 youtube/src/ /usr/share/nginx/html/
COPY --chown=$UID:0 --chmod=644 youtube/conf/nginx-site.conf /etc/nginx/conf.d/default.conf
COPY --chmod=755 entrypoint/10-listen-on-ipv6-by-default.sh /docker-entrypoint.d

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
    CMD curl -fSs 127.0.0.1:8080/healthz || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]