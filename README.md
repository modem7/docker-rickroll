# Self Hosted, self contained Rickroll container.

![Docker Pulls](https://img.shields.io/docker/pulls/modem7/docker-rickroll) 
![Docker Image Size (480p)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/480p?label=480p) 
![Docker Image Size (720p)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/720p?label=720p) 
![Docker Image Size (latest)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/latest?label=latest%2F1080p) 
![Docker Image Size (2160p)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/2160p?label=2160p) 
[![Build Status](https://drone.modem7.com/api/badges/modem7/docker-rickroll/status.svg)](https://drone.modem7.com/modem7/docker-rickroll)
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/docker-rickroll)](https://github.com/modem7/docker-rickroll)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/modem7)

More info can be found [here](https://www.youtube.com/watch?v=dQw4w9WgXcQ).

This is a self-hosted Rickroll container. Point someone at it - a link, a QR code, whatever your heart desires - and they get properly rickrolled: full video and audio of Rick Astley. The video starts playing the instant the page loads; sound kicks in the moment they click anything at all, no matter what it is.

Image is based on nginxinc/nginx-unprivileged, runs as a non-root user, and everything needed to serve the video is baked into the image at build time - no external dependencies at runtime.

# Quick start

```bash
docker run -d -p 8080:8080 --name rickroll modem7/docker-rickroll
```

Then visit `http://localhost:8080` - see the [Configuration example](#configuration-example) below for a docker-compose version.

Also published to GHCR if you'd rather pull from there: `ghcr.io/modem7/docker-rickroll`.

# How it works

- Every browser autoplays a muted video with zero restrictions, but every browser also actively refuses to let a page play sound without a genuine click/tap/keypress first - there's no trick or workaround for this, it's a deliberately and increasingly strictly enforced policy (the same reason YouTube and every other site with audio needs a click too). So the video autoplays muted immediately, and a decoy - a fake cookie-consent banner, a fake "Something went wrong" site error, or a stuck-loading spinner - entices that first click, which is all it takes to unmute.
- The video keeps loading/playing muted in the background the whole time so it's instantly ready, but it's completely covered by the decoy (a generic "boring website still loading" backdrop behind the cookie banner/site error, or the loading spinner's own dark screen) until the reveal - nothing looks suspicious, and nothing gives it away early.
- Only genuine clicks/taps/keypresses count for this - deliberately not mouse movement or scrolling, since browsers don't count those as real interaction either, and unmuting off one of those just gets the video paused by the browser's autoplay enforcement instead of actually unmuted.
- The video is served through nginx's mp4 module, so seeking/scrubbing and byte-range requests work properly and responses are cached.
- The video isn't stored in git. It's fetched from a GitHub Release asset at build time and baked into the image, so the shipped container is still fully self-contained and works offline - git just doesn't carry the binary around.
- Built for both linux/amd64 and linux/arm64/v8.

# Container Screenshot

![image](https://user-images.githubusercontent.com/4349962/187975538-9b7ec5db-3cf4-4dfa-964c-019eba9e272f.png)

# Tags
| Tag | Description |
| :----: | --- |
| 480p | Video starts automatically. 854x480. |
| 720p | Video starts automatically. 1280x720. |
| latest / 1080p | Video starts automatically. 1920x1080 - `latest` and `1080p` are the same image. |
| 2160p | Video starts automatically. 3840x2160. |

All tags are built from the same image - only the baked-in video resolution differs.

# Environment Variables
| Variable | Description | Default |
| :----: | --- | --- |
| PORT | Changes the port nginx is listening on. | 8080 |
| OVERLAY | Which decoy(s) can entice the first click - a comma-separated list from `cookie`, `error`, `loading`, one is picked at random per visit. Set to a single value (e.g. `cookie`) to always use just that one. | all three |
| TITLE | Browser tab title shown once the video is revealed (after the first click/keypress/etc). | Rickroll |
| PRE_TITLE | Browser tab title shown before the video is revealed. | Loading... |
| HEADLINE | Optional heading rendered over the revealed video (e.g. a caption). Leave unset to omit it. | (none) |
| HEIGHT | CSS height of the video element. | 100vh |
| WIDTH | CSS width of the video element. | 100% |
| OBJECT_FIT | CSS `object-fit` value for the video (`cover`, `contain`, etc). | cover |
| LOOP | Whether the video loops (`true`/`false`). | true |
| VIDEO_FILE | Filename of the video to serve, relative to the web root. | video.mp4 |

# Configuration example

```yaml
services:

  rickroll:
    image: modem7/docker-rickroll
    container_name: Rickroll
    ports:
      - 8080:8080
```

# Build Arguments
The video is fetched pre-transcoded from a video asset attached to a [GitHub Release](https://github.com/modem7/docker-rickroll/releases/tag/video-assets-v1) at build time, rather than being stored in git. This only matters if you're building the image yourself - the published `latest` tag already has it baked in.

| Build Arg | Description | Default |
| :----: | --- | --- |
| VIDEO_URL | URL the build downloads the (already-transcoded) video from. | [video-assets-v1/video-1080p.mp4](https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video-1080p.mp4) |

```bash
# build the default (1080p, matches the published `latest` tag)
docker build -t rickroll:1080p .

# point it at a different resolution asset instead
docker build --build-arg VIDEO_URL=https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video-720p.mp4 -t rickroll:720p .
```

Transcoding (4K master -> 2160p/1080p/720p/480p mp4s) happens separately, via a manually-triggered [GitHub Actions workflow](.github/workflows/video-assets.yml) that runs against the master video and uploads the results back to the Release. It only needs to run when the master video changes, not on every build.
