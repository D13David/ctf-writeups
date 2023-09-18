# CSAW'23

## What is going on?

> 
> The HudsonHustle company has contacted you as they are not able to figure out why they can not access any of their files. Can you figure out what is going on?
> 

Tags: __ir__

## Solution
This is a series of challenges simulating analysis and forensics of a incidence response. For the challenges three files are provided, one network traffic capture (`pcap`) and two VMware4 disk images.

After unpacking the files we can start investigation. Since there is no hint whatsoever we can try to run the images with `VirtualBox`. Since we don't have the credencials for `John Snow` we need to find another entry point. We can mount the disk.

```bash
$ guestmount -a win10.vmdk -m /dev/sda2 --ro /mnt/foo/
$ cd /mnt/foo
# ls -la
total 1443416
drwxrwxrwx 1 root root       4096 Sep 19  2023  .
drwxr-xr-x 6 root root       4096 Sep  9 12:06  ..
drwxrwxrwx 1 root root       4096 Sep 10 20:30 '$Recycle.Bin'
drwxrwxrwx 1 root root          0 Sep 19  2023 '$WinREAgent'
drwxrwxrwx 1 root root       4096 Sep 19  2023  Config.Msi
lrwxrwxrwx 2 root root         14 Sep 10 16:51 'Documents and Settings' -> /sysroot/Users
-rwxrwxrwx 2 root root       8192 Sep 19  2023  DumpStack.log.tmp
-rwxrwxrwx 1 root root    1594326 Sep 10 20:37  hahaha.png
-rwxrwxrwx 1 root root 1207959552 Sep 19  2023  pagefile.sys
drwxrwxrwx 1 root root          0 Dec  7  2019  PerfLogs
drwxrwxrwx 1 root root       4096 Sep 10 20:37  ProgramData
drwxrwxrwx 1 root root       8192 Sep 19  2023 'Program Files'
drwxrwxrwx 1 root root       4096 Sep 10 14:15 'Program Files (x86)'
drwxrwxrwx 1 root root          0 Sep 10 16:51  Recovery
-rwxrwxrwx 1 root root  268435456 Sep 19  2023  swapfile.sys
drwxrwxrwx 1 root root       4096 Sep 10 13:51 'System Volume Information'
drwxrwxrwx 1 root root       4096 Sep 10 20:30  Users
drwxrwxrwx 1 root root      16384 Sep 19  2023  Windows
```

Lets start with that funny looking png `hahaha.png`. Opening it gives us the first flag.

![](hahaha.png)

Flag `csawctf{h4ck1N6_7R41N5_F0r_D4y5!}`