---
title: Small httpd server
description: A Docker image to serve http requests
tags:
  - Docker
---

# FROM scratch

Create the small Docker image to serve http request. You can implement mockups with this.

```s
docker pull busybox
# -f              Do not daemonize
docker run -d -it --name my-http-server -p 8080:80 -v /var:/var/www/ -w /var/www/ busybox /bin/httpd -f -h /var/www/

echo "<h1>hello world</h1>" > index.html
curl localhost:8080/index.html
```

## References

* [BusyBox](https://busybox.net/downloads/BusyBox.html) - The Swiss Army Knife of Embedded Linux
