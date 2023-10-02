# BuckeyeCTF 2023

## replace-me

> I knew I shouldn't have gotten a cheap phone :/
> 
>  Author: rene
>
> [`dist`](dist)

Tags: _misc_

## Solution
We get a file for this challenge. Checking what this is we can call `file` on it.

```bash
$ file dist
dist: Android bootimg, kernel, ramdisk, page size: 2048, cmdline (console=ttyHSL0,115200,n8 androidboot.hardware=mako lpj=67677 user_debug=31)
```

Right, lets extract whatever binwalk finds

```bash
$ binwalk -e dist
$ _dist.extracted/
$ file 5BC000
5BC000: ASCII cpio archive (SVR4 with no CRC)
$ binwalk -e 5BC000
$ cd _5BC000.extracted/cpio-root/
$ ls
charger       file_contexts    init.mako.rc      init.usb.rc        res              sepolicy          ueventd.mako.rc
data          fstab.mako       init.mako.usb.rc  init.zygote32.rc   sbin             service_contexts  ueventd.rc
default.prop  init             init.rc           proc               seapp_contexts   sys
dev           init.environ.rc  init.trace.rc     property_contexts  selinux_version  system
```

Perfect, we have a lot to look at here. There are all kind of good information to gather, but eventually we find `/res/images/charger/battery_fail.png` giving us the flag.

![](battery_fail.png)

Flag `bctf{gr33n_r0b0t_ph0N3}`