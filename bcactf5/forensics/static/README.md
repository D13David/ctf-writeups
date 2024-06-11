# BCACTF 5.0

## Static

> Here's a copy of a mysterious video we found when infiltrating a submarine. It seems rather random, though.
> 
> 477e2ae9f514e89477ed54e40d97c7d5 (MD5) may help
> 
> Author: Marvin
> 
> [`static.mp4`](static.mp4)

Tags: _forensics_

## Solution
For this challenge we get a `MP4` video file. When playing the file we can observe a lot of noise. Checking the metadata with `exiftool` we find

```bash
$ exiftool static.mp4
..
Encoder                         : StaticMaker https://shorturl.at/AUKZm
..
```

What is `StaticMaker`, lets see what the link gives us.

> The StaticMaker ™ utility converts any binary file into a video, suitable for use in … some application somewhere, probably.
> 
> The default configuration is width=256, height=256.
> 
> The program works by:
> * Compressing the data
> * Padding to a size that is a multiple of (6*width*height) bits
> * Splitting the data into “subframes” of size (2*width*height) bits
> * Writes data to video frames, which each triplet of three consecutive subframes are written to the red, green, and blue channels of one frame, respectively
>   * Data written in row-major order
>   * 2 bits per pixel per channel
> 
> THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

Ok, its clear now we have to extract the data from the video for further inspection. The encoding process is layed out quite well, so we can write a script to do the work. We can observe that the pixel values are *around* four distinct values: 0, 85, 170 and 255. Its the 2 bit information stored in a pixels color channel, since video compression messes up the actual color the values are spread to the full 256 range. We can reconstruct this by checking the nearest of those values to the stored color value and mapping them to range 0-3.

```python
import cv2, textwrap
from PIL import Image

THRESHOLD = 4

def classify(value):
    if abs(0 - value) < THRESHOLD: return 0
    if abs(85 - value) < THRESHOLD: return 1
    if abs(170 - value) < THRESHOLD: return 2
    return 3

vidcap = cv2.VideoCapture('static.mp4')
data = bytearray()

while True:
    success, frame = vidcap.read()
    if not success:
        break

    subframes = [[],[],[]]

    height, width, channels = frame.shape

    for y in range(0, height):
        for x in range(0, width, 4):
            values = [0,0,0,0]
            for i in range(4):
                b,g,r = frame[y,x+i]
                values[0] = (values[0] << 2) | classify(r)
                values[1] = (values[1] << 2) | classify(g)
                values[2] = (values[2] << 2) | classify(b)
            for i in range(3):
                subframes[i].append(values[i])

    for i in range(3):
        data.extend(subframes[i])

open("output","wb").write(data)
```

This extracts the compressed data from bulletpoint #1. The file itself is not recognized by `file` and also in the hexeditor there is no obvious magic value at the beginning. Since we don't know how the data was compressed we can scan it with `binwalk`.

```bash
$ binwalk -e output

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
40522         0x9E4A          Zlib compressed data, default compression
```

Binwalk found a zlib compressed data chunk somewhere at offset `0x9E4A` where we can see two bytes `78 9C` which stand for `Default Compression`. So lets decompress the data quickly and see what's in there.

```bash
$ zlib-flate -uncompress < 9E4A.zlib > out
$ file out
out: POSIX tar archive
```

Ah, we have a `tar archive`, so lets extract this archive quickly.

```
$ tar -xf out
tar: Skipping to next header
tar: A lone zero block at 12920
tar: Exiting with failure status due to previous errors
$ ls
bin  dev  etc  home  lib  out
```

Looks like we have parts of a file system. Sadly extraction caused some errors, but lets see what we have.

```bash
$ tree .
.
├── bin
│   ├── arch -> /bin/busybox
│   ├── ash -> /bin/busybox
│   ├── base64 -> /bin/busybox
│   ├── bbconfig -> /bin/busybox
...
├── home
│   └── admin
│       └── Documents
│           ├── not_social_security_number.txt
│           └── social_security_number.txt
└── lib
    ├── apk
    │   ├── db
    │   │   ├── installed
    │   │   ├── lock
    │   │   ├── scripts.tar
    │   │   └── triggers
    │   └── exec
    ├── firmware
    ├── ld-musl-x86_64.so.1
    ├── libapk.so.2.14.0
    ├── libc.musl-x86_64.so.1 -> ld-musl-x86_64.so.1
    └── libcrypto.so.3

45 directories, 145 files
```

Two documents in `/home/admin/Documents` look interesting. And one gives us indeed the flag.

```bash
t home/admin/Documents/not_social_security_number.txt
bcactf{imag3_PROc3sSINg_yaY_2ea104d700c1a8}
```

Flag `bcactf{imag3_PROc3sSINg_yaY_2ea104d700c1a8}`