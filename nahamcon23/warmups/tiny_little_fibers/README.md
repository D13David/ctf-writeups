# NahamCon 2023

## tiny little fibers

> Oh wow, it's another of everyone's favorite. But we like to try and turn the ordinary into extraordinary!
>
>  Author: @JohnHammond#6971
>
> [`tiny-little-fibers`](tiny-little-fibers)

Tags: _warmups_

## Solution
Inspecting the ordinary things:

```bash
$ file tiny-little-fibers
tiny-little-fibers: JPEG image data, JFIF standard 1.01, aspect ratio, density 1x1, segment length 16, progressive, precision 8, 2056x1371, components 3
```

Another ordinary thing to do on image files is using `exiftool`. This doesnt lead to a good result but cranking up verbosity to *extraordinary* levels leads an unknown trailer with the flag in it.

```bash
$ exiftool tiny-little-fibers -v4
...
Unknown trailer (310684 bytes at offset 0x4c134):
   4c134: 66 00 6c 00 61 00 0a 00 67 00 7b 00 32 00 0a 00 [f.l.a...g.{.2...]
   4c144: 32 00 63 00 35 00 0a 00 33 00 34 00 63 00 0a 00 [2.c.5...3.4.c...]
   4c154: 35 00 61 00 62 00 0a 00 65 00 61 00 38 00 0a 00 [5.a.b...e.a.8...]
   4c164: 34 00 62 00 66 00 0a 00 36 00 63 00 31 00 0a 00 [4.b.f...6.c.1...]
   4c174: 31 00 39 00 33 00 0a 00 65 00 32 00 36 00 0a 00 [1.9.3...e.2.6...]
   4c184: 33 00 66 00 37 00 0a 00 32 00 35 00 39 00 0a 00 [3.f.7...2.5.9...]
   4c194: 66 00 7d 00 0a 00 0a 00 00 00 00 13 a4 fe 00 14 [f.}.............]
```
Flag `flag{22c534c5abea84bf6c1193e263f7259f}`