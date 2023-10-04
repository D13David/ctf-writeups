# BuckeyeCTF 2023

## pong

>  Author: rene
>

Tags: _misc_

## Solution
For this challenge we get nothing except a ip address `18.191.205.48`. Since the name is `pong` we can assume that we need to `ping` the service. To check whats going on we capture the `icmp` traffic with wireshark. And in fact we get some small data payload with some interesting content. After watching the packages for a while one can see that the data send has quite a few `IDAT` chunks which could point to a png. Also some readable `xpacket` xml can be seen, all this strongly suggests it's a [`png file`](https://dev.exiv2.org/projects/exiv2/wiki/The_Metadata_in_PNG_files).

```bash
0000   48 51 c5 60 98 66 2c 91 ab b8 53 ba 08 00 45 00   HQ.`.f,...S...E.
0010   00 94 86 bc 40 00 28 01 78 e9 12 bf cd 30 c0 a8   ....@.(.x....0..
0020   b2 2b 00 00 4e 62 03 e8 00 0d e7 85 19 65 00 00   .+..Nb.......e..
0030   00 00 af 13 05 00 00 00 00 00 10 11 12 13 14 15   ................
0040   16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25   .......... !"#$%
0050   26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35   &'()*+,-./012345
0060   36 37 70 61 63 6b 65 74 20 62 65 67 69 6e 3d 22   67packet begin="
0070   ef bb bf 22 20 69 64 3d 22 57 35 4d 30 4d 70 43   ..." id="W5M0MpC
0080   65 68 69 48 7a 72 65 53 7a 4e 54 63 7a 6b 63 39   ehiHzreSzNTczkc9
0090   64 22 3f 3e 0a 3c 78 3a 78 6d 70 6d 65 74 61 20   d"?>.<x:xmpmeta 
00a0   78 6d                                             xm
```

Next we need to fetch the whole data, for this we just capture all the ping packets until we find a `IEND` chunk (afterwards the server didn't send data anymore, but we couldn't knew this beforehand) and extract the data from the `pcap`.

```bash
tshark -r capture.pcapng -Y icmp -Y ip.src==18.191.205.48 -T fields -e data | awk '{print}' ORS='\n' > packets.dat
```

Now we have the raw data but the first couple of bytes don't belong to the actual payload and are alway the same. We just dump them and build the final file by concatenating the remaining bytes per packet.

```python
lines = open("packets.dat", "r").readlines()

f = open("data.png", "wb")
for line in lines:
    b = bytes.fromhex(line)[48:]
    if len(b) == 0: continue
    f.write(b)
f.close()
```

The file sadly doesn't open, and after opening it in an hex-editor we can also see why: The [`png header section`](http://www.libpng.org/pub/png/spec/1.2/PNG-Structure.html) was missing. To fix this I copied the header of some random png and then tried to adapt width, height and color type until something interesting was visible getting us the flag.

![](data.png)

Addendum: Later it turned out that by using `ping` the first package started with sequence number 1 and therefore the image seemed corrupted as the first package with png header where not received. Using `fping` would have given a fully working png image.

Flag `bctf{pL3a$3_$t0p_p1nG1ng_M3}`