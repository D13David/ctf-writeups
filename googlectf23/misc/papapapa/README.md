# Google CTF 2023

## PAPAPAPA

> Is this image really just white?
>
>  Author: N/A
>
> [`attachment.zip`](attachment.zip)

Tags: _misc_

## Solution
Provided is a jpeg image with 512x512 resolution. When opening the image seems indeed only white. All the basic investigations (`strings`, `exiftool`, ...) are not leading to any result. So the next thing is to look at the actual content in a hex editor.

Some good information on the format can be found [`here`](https://www.ccoderun.ca/programming/2017-01-31_jpeg/) and [`here`](https://yasoob.me/posts/understanding-and-writing-jpeg-decoder-in-python/). The image starts with the normal SOI (start of image marker) `FFD8` followed by the APP0 (`FFE0` marker) segment.

```
FF E0           - marker
00 10           - segment length
4A 46 49 46 00  - identifier JFIF\0
01              - version major
01              - version minor
02              - density units (2 = pixels per cm)
00 76           - horizontal density
00 76           - vertical density
00              - thumbnail x-resolution
00              - thumbnail y-resolution
```

Following this there are two DQT segments defining quantization tables for `chrominance` and `luminance` components of the color encoding.

```
FF DB 00 43 00 03 02 02 02 02 02 03 02 02 02 03 03 03 03 04 06 04 04 04 04 04 08 06 06 05 06 09 08 0A 0A 09 08 09 09 0A 0C 0F 0C 0A 0B 0E 0B 09 09 0D 11 0D 0E 0F 10 10 11 10 0A 0C 12 13 12 10 13 0F 10 10 10 FF DB 00 43 01 03 03 03 04 03 04 08 04 04 08 10 0B 09 0B 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10
```

Then comes a SOF (start of frame) segment.

```
FF C0           - marker
00 11           - length
08              - bits per pixel
02 00           - image height
02 00           - image width
03              - number of components
01 31 00        - 1=Y component, 49=sampling factor, quantization table number
02 31 01        - 2=Cb component, ...
03 31 01        - 3=Cr component
```

Following this four `Huffman tables` are given used to decompress the DCT information.

```
FF C4 00 1B 00 01 01 01 01 01 01 01 01 00 00 00 00 00 00 00 00 00 07 06 08 05 03 01 09 FF C4 00 35 10 01 00 01 04 02 02 02 02 02 01 03 02 03 09 00 00 00 02 01 03 04 05 06 07 11 12 08 13 21 22 14 31 41 15 23 51 32 42 16 24 71 09 17 33 34 52 58 61 97 D4 FF C4 00 14 01 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 FF C4 00 14 11 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
```

And then, just before image data starts the SOS (start of scan) segment:

```
FF DA           - marker
00 0C           - length 
03              - number of components (3 = color)
01 00           - 1=Y, 0=huffman table to use
02 11           - 2=Cb, ...
03 11           - 3=Cr, ...
00              - start of spectral selection or predictor selection
3F              - end of spectral selection
00              - successive approximation bit position or point transform
```

JPEG encoding works on 8x8 pixel blocks, so image side length is a multiple of 8. Another thing to note is that pixel components can have different sampling factors specified as seen in SOF. This enables JPEG to store chroma information in half resolution to achieve [`Chroma Subsampling`](https://en.wikipedia.org/wiki/Chroma_subsampling). In our case the components have all the same sampling factor, where the high nibble describing the horizontal and the low nibble the vertical factor. In this case 0x31 = 0b00110001, so the sampling factor is 3x1 causing dimensions to be padded to multiples of 24x8. This works well for the image height (512 % 8 = 0) but not for the width, which is not a multiple of 8. 

This can easily be fixed in the SOF segment. When setting the frame width to 520 the image starts to appear on the right side, setting it to 528 will display the whole flag.

```
FF C0 00 11 08 02 00 02 00 03 01 31 00 02 31 01 03 31 01
```
to
```
FF C0 00 11 08 02 00 02 10 03 01 31 00 02 31 01 03 31 01
```

Flag `CTF{rearview-monorail-mullets-brackroom-stopped}`