# Self Hosted, self contained Rickroll container.

![Docker Pulls](https://img.shields.io/docker/pulls/modem7/docker-rickroll) 
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/latest?label=latest%2Fonclick) 
[![Build Status](https://drone.modem7.com/api/badges/modem7/docker-rickroll/status.svg)](https://drone.modem7.com/modem7/docker-rickroll)
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/docker-rickroll)](https://github.com/modem7/docker-rickroll)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/modem7)

More info can be found [here](https://www.youtube.com/watch?v=dQw4w9WgXcQ).

Image is based on nginxinc/nginx-unprivileged, and all the content is local to the container.

# Container Screenshot

![image](https://user-images.githubusercontent.com/4349962/187975538-9b7ec5db-3cf4-4dfa-964c-019eba9e272f.png)

# Tags
| Tag | Description |
| :----: | --- |
| latest | Video starts automatically. 1080p AI remaster. |

# Environment Variables
| Variable | Description | Default |
| :----: | --- | --- |
| PORT | Changes the port nginx is listening on. | 8080 |
| TITLE | Browser tab title shown once the video is revealed (after the first click/keypress/etc). | Rickroll |
| PRE_TITLE | Browser tab title shown before the video is revealed. | Loading... |
| HEADLINE | Optional heading rendered over the video (e.g. a caption). Leave unset to omit it. | (none) |
| HEIGHT | CSS height of the video element. | 100vh |
| WIDTH | CSS width of the video element. | 100% |
| OBJECT_FIT | CSS `object-fit` value for the video (`cover`, `contain`, etc). | cover |
| LOOP | Whether the video loops (`true`/`false`). | true |
| VIDEO_FILE | Filename of the video to serve, relative to the web root. | video.mp4 |

# Build Arguments
The video is fetched and re-encoded into the image at *build* time (not runtime), from a 4K master video asset attached to a [GitHub Release](https://github.com/modem7/docker-rickroll/releases/tag/video-assets-v1) rather than being stored in git. Every resolution is derived from that one master via ffmpeg during the build. These only matter if you're building the image yourself.

| Build Arg | Description | Default |
| :----: | --- | --- |
| VIDEO_URL | URL the build downloads the source video from. | [video-assets-v1/video4k.mkv](https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/video4k.mkv) |
| RESOLUTION | `source` to use the master's native resolution as-is, or a target height like `2160p`/`1080p`/`720p`/`480p` to downscale via ffmpeg during the build. | 1080p |

```bash
# build the default (1080p, matches the published `latest` tag)
docker build -t rickroll:1080p .

# build the full 4K master
docker build --build-arg RESOLUTION=source -t rickroll:4k .

# build a smaller variant
docker build --build-arg RESOLUTION=720p -t rickroll:720p .
```

# Configuration example

```yaml
version: "2.4"

services:

  rickroll:
    image: modem7/docker-rickroll
    container_name: Rickroll
    ports:
      - 8080:8080
```
