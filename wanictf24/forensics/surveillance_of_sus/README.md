# WaniCTF 2024

## Surveillance_of_sus

> A PC is showing suspicious activity, possibly controlled by a malicious individual.
> 
> It seems a cache file from this PC has been retrieved. Please investigate it!
>
>  Author: Mikka
>
> [`for-Surveillance-of-sus.zip`](for-Surveillance-of-sus.zip)

Tags: _forensics_

## Solution
For this challenge we get an zip archive containing a `.bin` file that `file` does not recognize. So check it out in an hexeditor. The file starts with `RDP8bmp` that suspiciously looks like a file format marker. This is a `RDB bitmap cache`, that is used when a user connects to a system via [`RDP`](https://en.wikipedia.org/wiki/Remote_Desktop_Protocol). Image data is stored in this cache to enable fast fetching to decrease potential throughput over the wire.

The cache can be found at `%localappdata%\Microsoft\Terminal Server Client\Cache` if present.

The cache stores bitmap data in form of tiles. After the magic identifier (`RDP8bmp\x00`) come 4 bytes that specify the container version. Finally a list of tiles is stored, each tile with it's own header.

```bash
8 bytes key
2 bytes tile width
2 bytes tile height
```

The data is uncomressed 32 bit RGBA data, so every tile uses `width*height*4` bytes of data. See [`cache_dumper.c`](cache_dumper.c) as a simple implementation that dumps the contained tiles of the cache to disk.

![](Cache_chal.bin_collage.png)

With this we can use [`RdpCacheStitcher`](https://github.com/BSI-Bund/RdpCacheStitcher) for some semi-automatic tile stitching, or just do it manually with a image editing software of trust.

![](flag.png)

Flag `FLAG{RDP_is_useful_yipeee}`