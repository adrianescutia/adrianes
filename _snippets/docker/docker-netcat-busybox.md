---
title: Small netcat server
description: A Docker image to serve TPC requests
categories:
  - Docker
---

# Very Small Docker Container to Listen TPC Requests

Create the small Docker image to serve TCP request. You can implement a mockup listener to see what your client generates to server requests.

```s
docker pull busybox
# -k              Keep connection open
docker run -d -it --rm --name my-listener-server -p 8666:80 -v /var:/var/www/ -w /var/www/ busybox /bin/nc -lk -p 80
```

## Testing with client

Check your `nc` server docker logs:

```s
$ docker logs -f my-listener-server
# You will see this messages comming as you type <ENTER> from your client below
hello
world
bye
punt!
```

Open a new terminal to connect to the server:

```s
$ nc localhost 8666
hello
world
bye
^C
```

To keep the server running/listening multiple connections:

```s
-k    Forces nc to stay listening for another connection after its current
       connection is completed.  It is an error to use this option without the
       -l option.
```

## References

* [BusyBox](https://busybox.net/downloads/BusyBox.html) - The Swiss Army Knife of Embedded Linux
