# Hack The Boo 2022

## Ghost Wrangler

> Who you gonna call?
>
>  Author: N/A
>
> [`rev_ghost_wrangler.zip`](rev_ghost_wrangler.zip)

Tags: _rev_

## Preparation

When running the file this message appears

```
$ ./ghost
|                                       _| I've managed to trap the flag ghost in this box, but it's turned invisible! Can you figure out how to reveal them?
```

## Solution

```
$ tail $(.ghost)
tail: cannot open 'HTB{h4unt3d_by_th3_gh0st5_0f_ctf5_p45t!}'$'\r''|'$'\033''[4m' for reading: No such file or directory 
```