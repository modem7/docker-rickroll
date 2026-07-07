# syntax = docker/dockerfile:latest

# ---- Fetch the pre-transcoded video. Build-time only - baked into the
# ---- final image, never stored in git/LFS. Transcoding to the various
# ---- resolutions happens separately and infrequently, not on every image
# ---- build (see .github/workflows/video-assets.yml).
FROM --platform=$BUILDPLATFORM alpine:3.24 AS video

# hadolint ignore=DL3018
RUN apk add --no-cache curl

ARG VIDEO_URL=https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video-1080p.mp4

WORKDIR /video
RUN curl -fsSL "$VIDEO_URL" -o video.mp4

# ---- Final image ----
FROM nginxinc/nginx-unprivileged:1.31.2-alpine

USER root

ARG UID=101
ARG GID=101

# Copy files into image
COPY --link --from=video /video/video.mp4 /usr/share/nginx/html/video.mp4
COPY --link --chmod=755 scripts/*.sh /docker-entrypoint.d/

# Document what port is required
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
   cmd curl -fss http://localhost:9090/healthz || exit 1

STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]
