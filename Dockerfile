# syntax = docker/dockerfile:latest

# ---- Fetch and (optionally) transcode the source video. Build-time only -
# ---- the result is baked into the final image, never stored in git/LFS.
FROM --platform=$BUILDPLATFORM alpine:3.20 AS video

# hadolint ignore=DL3018
RUN apk add --no-cache curl ffmpeg

ARG VIDEO_URL=https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video4k.mkv
ARG RESOLUTION=1080p

WORKDIR /video
RUN curl -fsSL "$VIDEO_URL" -o source.input

# Always re-encode to a faststart-ready mp4 so any source container/codec
# (mkv, mp4, etc) works, and downscale unless RESOLUTION=source is requested.
RUN set -eu; \
    case "$RESOLUTION" in \
        source) \
            ffmpeg -y -i source.input \
                -c:v libx264 -preset medium -crf 18 \
                -c:a aac -b:a 192k \
                -movflags +faststart \
                video.mp4 ;; \
        *) \
            ffmpeg -y -i source.input -vf "scale=-2:${RESOLUTION%p}" \
                -c:v libx264 -preset medium -crf 18 \
                -c:a aac -b:a 192k \
                -movflags +faststart \
                video.mp4 ;; \
    esac

# ---- Final image ----
FROM nginxinc/nginx-unprivileged:1.31.2-alpine

USER root

ARG UID=101
ARG GID=101

# Copy files into image
COPY --link --from=video /video/video.mp4 /usr/share/nginx/html/video.mp4
COPY --link --chmod=755 scripts/*.sh /docker-entrypoint.d/
COPY --link --chmod=755 scripts/index/80-index.sh /docker-entrypoint.d/

# Change permissions to index.html
RUN chown $UID:0 /usr/share/nginx/html/index.html

# Document what port is required
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
   cmd curl -fss http://localhost:9090/healthz || exit 1

STOPSIGNAL SIGQUIT

USER $UID

CMD ["nginx", "-g", "daemon off;"]
