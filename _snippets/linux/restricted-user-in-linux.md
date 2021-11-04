---
title: "Restrict command to user in Linux"
description: "How to restrict the commands to a user in Linux"
tags:
  - Linux
---

# Add a user with restrictions

With example below, you will be able to create a user and avoid him to execute commands you don't want.

```sh
sudo useradd -m dox -s /bin/bash
sudo passwd dox
#--> type your password here

sudo chown root. /home/dox/.bash_profile
sudo chmod 755 /home/dox/.bash_profile

#add "safe" aliases for all the commands that you would like to disable
# example:

vi ./bash_profile
# .bash_profile
alias apt-get="printf ''"
alias cp="printf ''"
alias cd="printf ''"
alias ls="printf ''"
alias ll="printf ''"
alias vi="vi -Z"
alias bash="printf ''"
```

## References

* [How to limit user commands in Linux](https://newbedev.com/how-to-limit-user-commands-in-linux)
* https://access.redhat.com/solutions/65822
* https://www.techrepublic.com/article/how-to-use-restricted-shell-to-limit-user-access-to-a-linux-system/
