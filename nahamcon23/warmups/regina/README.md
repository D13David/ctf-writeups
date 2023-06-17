# NahamCon 2023

## Regina

> I have a tyrannosaurus rex plushie and I named it Regina! Here, you can talk to it :)
>
>  Author: @JohnHammond#6971
>

Tags: _warmups_

## Solution
After connecting to the server we are greeted by the following message:

```bash
$ ssh -p 32288 user@challenge.nahamcon.com
user@challenge.nahamcon.com's password:

/usr/local/bin/regina: REXX-Regina_3.9.4(MT) 5.00 25 Oct 2021 (64 bit)
```

Input can be typed but nothing happens. Using some typical commands and pressing `Ctrl+D` (for EOF) brings a strange message:

```
ls
sh: LS: not found
```

So something is executed. Using the hint from the description (and banner) it seems that REXX-Regina is a [Rexx interpreter](https://regina-rexx.sourceforge.io/), so we probably need to write some `Rexx` code to leak the flag.

```rexx
flag = linein("flag.txt")
say flag
^D
flag{2459b9ae7c704979948318cd2f47dfd6}
```

Flag `flag{2459b9ae7c704979948318cd2f47dfd6}`