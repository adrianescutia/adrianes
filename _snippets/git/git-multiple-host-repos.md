---
title: Multiple Git host or repositories
description: If you have a problem with multiple accounts for Git, here you find a solution to access with different credentials.
---

## Configuring your identities

Do you need acces to diffent repositories, public, private or private in your organization? configure your identities to access the specific host:

**Modify the ssh config**

```s
$ vi ~/.ssh/config
```

Example config:

```yaml
Host alter.github.com
  HostName github.com
  User git
  IdentityFile /home/alter-ego/.ssh/alter_github.id_rsa
  IdentitiesOnly yes

Host ego.github.com
  HostName github.com
  User git
  IdentityFile /home/alter-ego/.ssh/ego_github.id_rsa
  IdentitiesOnly yes
  
Host gitlab.com
  HostName gitlab.com
  User git
  IdentityFile /home/alter-ego/.ssh/alter-ego_gitlab.id_rsa
  IdentitiesOnly yes
```

**Clean or [start ssh agent] and add private keys:**

```s
# Start agent, if not running
$ eval `ssh-agent -s`
# delete all cached keys before
$ ssh-add -D
# Add defaul key (~/.ssh/id_rsa)
$ ssh-add
# Add alter key from example
$ ssh-add ~/.ssh/alter_github.id_rsa
# List saved keys
$ ssh-add -l
4096 SHA256:XXXXXXX+YYYYYYYYY adrianescutia@mail.com (RSA)
4096 SHA256:ZZZZZZZ/AAAAA+h0+FHo aescutias@mail.com (RSA)
```

To automatically start ssh-agent and allow a single instance to work in multiple console windows, see [Start ssh-agent on login], or even better, an [easy solution with zsh].

In your local Git repo, add the host as specified in `Host` ssh config file:

```s
cd /my/project/dir
git remote add origin git@alter.github.com:myproject/repo.git
```

**References:**

[Start ssh-agent on login]: https://stackoverflow.com/a/38980986/5078874
[start ssh agent]: https://stackoverflow.com/a/17848593/5078874
[easy solution with zsh]: https://stackoverflow.com/a/58634003/5078874