# DeconstruCT.F 2023

## Snowy Rock

> am loves puzzles and his dad working in alaska sent a message hidden within for him to uncover
Can you decode it?
>
>  Author: Rakhul
>
> [`snowy_rock_fi.jpg`](snowy_rock_fi.jpg)

Tags: _forensics_

## Solution
A image of a snowy path through the woods is given for this challenge. The image by itself doesn't contain any obvious informations. So `binwalking` the file is the next thing to check.

```bash
 binwalk -e snowy_rock_fi.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01
13250         0x33C2          TIFF image data, big-endian, offset of first image directory: 8
28624         0x6FD0          Copyright string: "Copyright (c) 1998 Hewlett-Packard Company"
248341        0x3CA15         Zip archive data, encrypted at least v2.0 to extract, compressed size: 1037, uncompressed size: 2289, name: snowyrock.txt
249548        0x3CECC         End of Zip archive, footer length: 22
```

A zip archive was hidden within the image. Sadly the archive cannot be extracted since it's password secured. Luckily the password is not too strong and can be cracked, so time to let `john` do it's magic.

```bash
$ zip2john 3CA15.zip > foo
ver 2.0 efh 5455 efh 7875 3CA15.zip/snowyrock.txt PKZIP Encr: TS_chk, cmplen=1037, decmplen=2289, crc=B0E1F308 ts=B3AC cs=b3ac type=8

$ john foo -w=/usr/share/wordlists/rockyou.txt
```

With the password `11snowbird` the zip archive can be extracted.

```txt
$ cat snowyrock.txt
Today we woke up to a revolution of snow,

its white flag waving over everything,



the landscape vanished,

not a single mouse to punctuate the blankness,



and beyond these windows


[snip]
```

This seems to be a poem [`Snow Day by Billy Collins`](https://www.poetryfoundation.org/poems/46707/snow-day). But there are very suspicious whitespaces in between the lines. A hexeditor makes the spaces and tabs visible.

```
00000000 54 6F 64 61  79 20 77 65   20 77 6F 6B  65 20 75 70                                           Today we woke up
00000010  20 74 6F 20  61 20 72 65   76 6F 6C 75  74 69 6F 6E                                            to a revolution
00000020  20 6F 66 20  73 6E 6F 77   2C 09 20 20  20 20 20 09                                            of snow,.     .
00000030  20 09 20 20  20 20 09 20   20 20 20 0A  20 20 09 20                                            .    .    .  .
00000040  20 09 20 20  20 20 20 09   20 20 20 20  20 20 09 20                                            .     .      .
00000050  20 20 20 20  09 20 20 20   20 20 20 09  20 20 20 20                                               .      .
00000060  09 20 20 20  20 20 09 20   20 09 20 20  20 20 20 20                                           .     .  .
00000070  0A 69 74 73  20 77 68 69   74 65 20 66  6C 61 67 20                                           .its white flag
00000080  77 61 76 69  6E 67 20 6F   76 65 72 20  65 76 65 72                                           waving over ever
00000090  79 74 68 69  6E 67 2C 20   20 20 20 20  20 20 09 20                                           ything,       .
000000A0  20 20 20 20  20 09 20 20   20 20 09 20  09 20 20 20                                                .    . .
000000B0  20 20 0A 20  09 20 20 20   20 20 09 20  20 20 20 20                                             . .     .
000000C0  09 20 09 09  20 20 09 20   20 20 09 20  20 20 20 20                                           . ..  .   .
000000D0  20 09 20 09  20 20 20 20   20 0A 20 20  20 20 09 20                                            . .     .    .
000000E0  20 09 20 20  20 20 20 20   20 09 20 20  20 20 20 09                                            .       .     .
000000F0  20 20 20 20  20 09 20 20   20 20 20 20  09 09 09 20                                                .      ...
00000100  20 20 20 20  09 20 20 20   20 20 20 20  0A 20 20 09                                               .       .  .
00000110  20 20 20 09  20 20 20 09   09 20 20 09  20 20 20 20                                              .   ..  .
00000120  09 20 20 09  20 20 20 20   20 09 20 20  20 20 09 20                                           .  .     .    .
```

This smells like a case for `stegsnow`.

```bash
$ stegsnow -C snowyrock.txt
OFTHA62GMFBGUX3FIJYFQZS7ONBGKX3FGM2HS7I=
```

Ok, this is base32 encoded, so adding this to the chain.

```bash
$ stegsnow -C snowyrock.txt | base32 -d
qfp{FaBj_eBpXf_sBe_e34y}
```

Looking quite good, but a bit off. Typical setup for `rot13`?

```bash
$ stegsnow -C snowyrock.txt | base32 -d | rot13
dsc{SnOw_rOcKs_fOr_r34l}
```

Flag `dsc{SnOw_rOcKs_fOr_r34l}`