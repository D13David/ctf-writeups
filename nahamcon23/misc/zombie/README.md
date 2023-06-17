# NahamCon 2023

## Zombie

> Oh, shoot, I could have sworn there was a flag here. Maybe it's still alive out there?
>
>  Author: @JohnHammond#6971
>

Tags: _misc_

## Solution
Logging in via ssh and inspecting the user folder. A file `.user-entrypoint.sh` looks interesting, the content of the file

```bash
#!/bin/bash

nohup tail -f /home/user/flag.txt >/dev/null 2>&1 & #
disown

rm -f /home/user/flag.txt 2>&1 >/dev/null

bash -i
```

The flag file is removed but right before a process is started that tails the flag file and forwards to `/dev/null`. This is interesting as the process still runs due to `nohub`. So checking the running processes

```bash
user@zombie:~$ ps aux
PID   USER     TIME   COMMAND
    1 root       0:00 /usr/sbin/sshd -D -e
    7 root       0:00 sshd: user [priv]
    9 user       0:00 sshd: user@pts/0
   10 user       0:00 {.user-entrypoin} /bin/bash /home/user/.user-entrypoint.sh
   11 user       0:00 tail -f /home/user/flag.txt
   13 user       0:00 bash -i
   18 user       0:00 ps aux
```

The process with PID 11 looks promising. So inspecting the output for this process leads the flag.

```bash
user@zombie:~$ cat /proc/11/fd/3
flag{6387e800943b0b468c2622ff858bf744}
```
Flag `flag{6387e800943b0b468c2622ff858bf744}`