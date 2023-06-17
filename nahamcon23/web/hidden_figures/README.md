# NahamCon 2023

## Hidden Figures

> Look at this fan page I made for the Hidden Figures movie and website! Not everything is what it seems!
>
>  Author: @JohnHammond#6971
>

Tags: _web_

## Solution
Inspecting the html code of the provided page, disabling css, inspecting svg images... Nothing leads to a result. By looking closely there are very obvious chunks of base64 encoded data attached to `img` tags.

```html
<img class="thumb-image loaded" data-image-dimensions="2004x1184" data-image-focal-point="0.5,0.5" alt="" data-load="false" data-image-id="57af21b8ebbd1aaf59948005" data-type="image" style="left: -0.104888%; top: 0%; width: 100.21%; height: 100%; position: absolute;" data-image-resolution="300w" src="data:image/png;base64,/9j/4AAQSkZJRgABAQEASABIAAD//gATQ3JlYXRlZCB3aXRo
```

Taking all the base64 chunks and decoding them leads to the same images as displayed on the page but something is different. In one of the images a unknown trailer can be found via `exiftool`.

```bash
$ exiftool 'download (4).jpg' -v4
...
Unknown trailer (23380 bytes at offset 0x3c7e):
    3c7e: 89 50 4e 47 0d 0a 1a 0a 00 00 00 0d 49 48 44 52 [.PNG........IHDR]
    3c8e: 00 00 07 3b 00 00 00 ae 08 02 00 00 00 2e d7 f7 [...;............]
    3c9e: 97 00 00 5b 1b 49 44 41 54 78 9c ed dd 77 5c 14 [...[.IDATx...w\.]
    3cae: c7 ff 3f f0 a5 77 11 6c 68 50 b1 8b 1d 83 2d 82 [..?..w.lhP....-.]
    3cbe: 5d 14 b1 44 63 89 26 b6 14 63 62 4b ec 46 4d 4c []..Dc.&..cbK.FML]
    3cce: ec 31 96 58 a2 46 8d 5d 54 ec 8a dd 60 43 b1 57 [.1.X.F.]T...`C.W]
    3cde: 9a 8a 08 88 a0 08 d2 cb 51 ee f7 c7 7d 3f fc 78 [........Q...}?.x]
    3cee: dc ce 2e 7b 5b 8e b9 e3 f5 fc cf 91 9d 7d df dc [...{[........}..]
```

There is a png hidden inside one of the images. To extract the png the following can be done

```bash
$ dd skip=15486 count=23380 if='download (4).jpg' of=flag.png bs=1
```

The offset and length is given by `exiftool`. After opening the png the flag is given.

Flag `flag{e62630124508ddb3952843f183843343}`