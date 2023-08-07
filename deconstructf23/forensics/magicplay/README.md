# DeconstruCT.F 2023

## Magicplay

> Dwayne's mischevious nephew played around in his pc and corrupted a very important file..
Help dwayne recover it!
>
>  Author: Rakhul
>
> [`magic_play.png`](magic_play.png)

Tags: _forensics_

## Solution
This challenge comes with a file that looks like an png but opening it brings no result. Also `file` doesn't recognize it as png. Something weird is going on...

```bash
$ file magic_play.png
magic_play.png: data
```

Opening the file with an hexeditor reveals the issue: Some header id's are messed up. 
```
89 57 C4 47  0D 0A 1A 0A   00 00 00 0D  49 30 4E 52                                           .W.G........I0NR
00 00 04 C9  00 00 02 6A   08 06 00 00  00 31 08 17                                           .......j.....1..
EE 00 00 00  01 73 E6 47   42 00 AE CE  1C E9 00 00                                           .....s.GB.......
00 04 67 41  65 35 00 00   B1 8F 0B FC  61 05 00 00                                           ..gAe5......a...
00 09 68 48  59 73 00 00   16 25 00 00  16 25 01 49                                           ..hHYs...%...%.I
52 24 F0 00  00 FF A5 49   44 41 54 78  5E EC DD 07                                           R$.....IDATx^...
BC 74 57 55  36 F0 9D 50   44 A5 F7 DE  55 7A 13 69                                           .tWU6..PD...Uz.i
02 52 14 A5  2A 8A 8A A0   A0 54 05 DB  27 2A 20 16                                           .R..*....T..'* .
6C 88 62 03  B1 00 2A A0   20 45 3A D2  7B 2F 29 24                                           l.b...*. E:.{/)$
```

Every png starts with a ascii string `PNG (50 4E 47)`. Then a number of chunks are present and every chunk also is marked with a unique magic value. The first chunk is `IHDR` which needs to be always the first chunk in each and every `png` file. Also this magic value is corrupted. After fixing the magic values the file can be viewed.

```
89 50 4E 47  0D 0A 1A 0A   00 00 00 0D  49 48 44 52                                           .PNG........IHDR
00 00 04 C9  00 00 02 6A   08 06 00 00  00 31 08 17                                           .......j.....1..
EE 00 00 00  01 73 E6 47   42 00 AE CE  1C E9 00 00                                           .....s.GB.......
00 04 67 41  65 35 00 00   B1 8F 0B FC  61 05 00 00                                           ..gAe5......a...
00 09 68 48  59 73 00 00   16 25 00 00  16 25 01 49                                           ..hHYs...%...%.I
52 24 F0 00  00 FF A5 49   44 41 54 78  5E EC DD 07                                           R$.....IDATx^...
BC 74 57 55  36 F0 9D 50   44 A5 F7 DE  55 7A 13 69                                           .tWU6..PD...Uz.i
02 52 14 A5  2A 8A 8A A0   A0 54 05 DB  27 2A 20 16                                           .R..*....T..'* .
6C 88 62 03  B1 00 2A A0   20 45 3A D2  7B 2F 29 24                                           l.b...*. E:.{/)$
```

![](magic_play_fixed.png)

Flag `dsc{COrrupt3d_M4g1C_f1Ag}`