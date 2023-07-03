# UIUCTF 2023

## First class mail

> Jonah posted a picture online with random things on a table. Can you find out what zip code he is located in? Flag format should be uiuctf{zipcode}, ex: uiuctf{12345}.
>
>  Author: N/A
>
> [`chal.jpg`](chal.jpg)

Tags: _osint_

## Solution
Here again we have a image to look at

![](chal.jpg)

There's a lot to see, but nothing too interesting. Since we are searching for a zipcode the envelopes are most interesting. But on the one in the forground nothing can be seen. The one in the background has some kind of barcode on it.

This seems to be a [`POSTNET barcode`](https://www.barcode.ro/tutorials/barcodes/postnet.html). On the page there is a good description how it works. In short, the barcode has 52 bars in total, the bars on the left and right are called frame bars and between the frame bars are digits. Every digit is represented with 5 bars. The encoding is as follows.

```
1   ■ ■ ■ █ █
2   ■ ■ █ ■ █
3   ■ ■ █ █ ■
4   ■ █ ■ ■ █
5   ■ █ ■ █ ■
6   ■ █ █ ■ ■
7   █ ■ ■ ■ █
8   █ ■ ■ █ ■
9   █ ■ █ ■ ■
0   █ █ ■ ■ ■
```

There are multiple flavours for US delivery address coding, this one is a 5-digit ZIP + 4 code. The lasts digit is a check digit. The first 9 digits are summed up and the check is the rest needed to sum to a multiple of 10.

The bar code on the envelope looks like this `█   ■ █ █ ■ ■   █ █ ■ ■ ■   ■ █ █ ■ ■   ■ █ █ ■ ■   ■ ■ ■ █ █   ■ ■ ■ █ █   ■ ■ ■ █ █   ■ ■ █ ■ █   ■ ■ █ █ ■   ■ █ ■ ■ █   █` split by digits and frame bars. If decoded we have `6066111234`, where `4` is the checkcode: `6+0+6+6+1+1+1+2+3 = 26`, adding the check digit we end up with `30` which obiously is a multiple of 10. So the actual ZIP value is `60661-1123`.

A quick google search for `60661-1123 zipcode` brings `Chicago, IL 60661-1123` that seems like a match. The flag with this long zipcode doesn't work though, using only the first part gives the flag. 

Flag `uiuctf{60661}`