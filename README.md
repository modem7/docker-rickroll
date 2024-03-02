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
| TITLE | Changes the title of the webpage. | Rickroll |
| HEIGHT | Changes the height of the video. | 100vh |
| WIDTH | Changes the width of the video. | 100% |
| HEADLINE | Allows for a custom body tag. | empty |

# Configuration example

```yaml
version: "2.4"

services:

  rickroll:
    image: modem7/docker-rickroll
    container_name: Rickroll
    ports:
      - 8080:8080
    environment:
      - TITLE="Rickroll" # Changes the title of the webpage
```
