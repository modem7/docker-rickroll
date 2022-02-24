# Self Hosted, self contained Rickroll container.

![Docker Pulls](https://img.shields.io/docker/pulls/modem7/docker-rickroll) 
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/latest?label=latest%2Fonclick) 
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/1080?label=1080%2F1080onclick) 
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/docker-rickroll/youtube?label=youtube) 
[![Build Status](https://drone.modem7.com/api/badges/modem7/docker-rickroll/status.svg)](https://drone.modem7.com/modem7/docker-rickroll)
[![GitHub last commit](https://img.shields.io/github/last-commit/modem7/docker-rickroll)](https://github.com/modem7/docker-rickroll)

More info can be found here: https://www.youtube.com/watch?v=dQw4w9WgXcQ

Image is based on Nginx stable alpine, and all the content is local to the container (bar for the Youtube tag).

# Container Screenshot

![Capture](https://user-images.githubusercontent.com/4349962/128193774-d5c98641-56d7-471f-bc69-1d0d952a0d60.png)

# Tags
| Tag | Description |
| :----: | --- |
| Latest | Video starts automatically, but muted. SD Quality. |
| Onclick | Uses an onclick method with a poster image. SD Quality. |
| Youtube | Uses an iFrame to embed a Youtube Video. SD Quality. |
| 1080/1080onclick | 1080p AI remasters of the above tags. |

# Configuration

```bash
version: "2.4"

services:

  rickroll:
    image: modem7/docker-rickroll
    container_name: Rickroll
    ports:
      - 80:80
```
