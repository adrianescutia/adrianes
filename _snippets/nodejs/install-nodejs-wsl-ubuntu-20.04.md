---
title: Node.js v12 or v14 Installation instructions in WSL Ubuntu 20
categories:
     - NodeJS WSL
---

## Node.js v12 or v14 Installation

Trying to install a package in WSL Ubuntu 20, but getting this error?:

```log
gpg: can't connect to the agent: IPC connect call failed
Error executing command, exiting
```

[Enabling WSL 2](https://github.com/microsoft/WSL/issues/5125#issuecomment-621951640) may work, but I could tested it, WSL 2 is not available for my Windows version.

For me, previous responses worked, but partially, what made [the magic](https://github.com/microsoft/WSL/issues/5125#issuecomment-625985191) in my case was:
If you get error `` [install package software properties common](https://itsfoss.com/add-apt-repository-command-not-found/).

```s
sudo apt remove gpg
sudo apt-get update -y
sudo apt-get install -y gnupg1
# In case of Error when adding "ppa" with message: add-apt-repository: command not found
sudo apt-get install software-properties-common
# Now, the hack
sudo add-apt-repository ppa:rafaeldtinoco/lp1871129
sudo apt update
wget https://launchpad.net/~rafaeldtinoco/+archive/ubuntu/lp1871129/+files/libc6_2.31-0ubuntu8+lp1871129~1_amd64.deb
sudo dpkg --install libc6_2.31-0ubuntu8+lp1871129~1_amd64.deb
sudo apt-mark hold libc6 #to avoid further update

# Edit: /var/lib/dpkg/info/libc6:amd64.postinst and remove the sleep 1 that is in nearly the last line.
```

```s
## Run `sudo apt-get install -y nodejs` to install Node.js 14.x and npm
## You may also need development tools to build native addons:
     sudo apt-get install gcc g++ make
## To install the Yarn package manager, run:
     curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
     echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
     sudo apt-get update && sudo apt-get install yarn
```


## Rollback the "hack"

```s
sudo apt-mark unhold libc6
sudo apt install ppa-purge
sudo ppa-purge ppa:rafaeldtinoco/lp1871129
sudo apt update
sudo apt upgrade
```





sudo apt install libc6=2.31-0ubuntu9 libc6-dev=2.31-0ubuntu9 libc-dev-bin=2.31-0ubuntu9 -y --allow-downgrades

sudo apt install libc6=2.31-0ubuntu8+lp1871129~1 libc6-dev=2.31-0ubuntu8+lp1871129~1 libc-dev-bin=2.31-0ubuntu8+lp1871129~1 -y --allow-downgrades

#libc6-dev : Depends: libc6 (= 2.31-0ubuntu9) but 2.31-0ubuntu8+lp1871129~1 is to be installed
