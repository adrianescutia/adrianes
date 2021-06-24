---
title: "curl: (60) SSL certificate problem"
description: "Solve this error with openssl when curl is unable to get local issuer certificate"
tags:
  - Linux
---

# CA certificate store update

Here are the steps to solve this error when "curl fails to verify the legitimacy of the server and therefore 
could not establish a secure connection to it"

Let's say you try to download something using `curl` or install [hub]() using [brew], then, you get an error like:  
```sh
==> Downloading https://ghcr.io/v2/linuxbrew/core/ncurses/manifests/6.2
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

Then, let **ghcr.io** being the server.

```sh
cd ~
# Download the cert:
openssl s_client -showcerts -servername ghcr.io  -connect server:443 > cacert.pem
# type "quit", followed by the "ENTER" key / or Ctrl+C
# see the data in the certificate:
openssl x509 -inform PEM -in cacert.pem -text -out certdata-ghcr.io.txt
cat certdata-ghcr.io.txt
# If you want to trust the certificate, you can add it to your CA certificate store
# move the file to certificate store directory:
sudo mv cacert.pem /usr/local/share/ca-certificates/cacert-ghcr.io.crt
sudo update-ca-certificates
# done !
```

## References

* [SSL Certificate Verification](https://curl.se/docs/sslcerts.html)