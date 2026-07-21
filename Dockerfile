# syntax = docker/dockerfile:latest@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89

# ---- Fetch the pre-transcoded video. Build-time only - baked into the
# ---- final image, never stored in git/LFS. Transcoding to the various
# ---- resolutions happens separately and infrequently, not on every image
# ---- build (see .github/workflows/video-assets.yml). Rebuilt
# ---- automatically on every push to master that touches this file (see
# ---- .github/workflows/ghcr-publish.yml and .drone.yml).
FROM --platform=$BUILDPLATFORM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS video

# hadolint ignore=DL3018
RUN apk add --no-cache curl

ARG VIDEO_URL=https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video-1080p.mp4

WORKDIR /video
RUN curl -fsSL "$VIDEO_URL" -o video.mp4

# ---- Final image ----
FROM nginxinc/nginx-unprivileged:1.31.3-alpine@sha256:18d67281256ded39ff65e010ae4f831be18f19356f83c60bc546492c7eb6dd23

USER root

ARG UID=101
ARG GID=101

# Copy files into image
COPY --link --from=video /video/video.mp4 /usr/share/nginx/html/video.mp4
COPY --link --chmod=755 scripts/*.sh /docker-entrypoint.d/
COPY --link --chmod=755 scripts/index/80-index.sh /docker-entrypoint.d/

# Change permissions to index.html so the non-root entrypoint can
# overwrite it at container start
RUN chown $UID:0 /usr/share/nginx/html/index.html

# Document what port is required
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
   cmd curl -fss http://localhost:9090/healthz || exit 1

STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]
