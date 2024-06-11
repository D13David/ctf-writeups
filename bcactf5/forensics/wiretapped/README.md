# BCACTF 5.0

## Wiretapped

> I've been listening to this cable between two computers, but I feel like it's in the wrong format.
> 
> Author: Marvin
> 
> [`wiretapped.wav`](wiretapped.wav)

Tags: _forensics_

## Solution
For this challenge we get a `wav` file. Nothing useful can be heard when playing the file. With binwalk we find html data and jpeg data, but nothing useful really. Opening the file with an hexeditor gives us a lot of readable text, thats unusual for sound data. It looks like a `pcap` capture, and indeed, a bit further down the road after the [`wav header`](http://soundfile.sapp.org/doc/WaveFormat/) we find a [`pcap-ng`](https://www.winpcap.org/ntar/draft/PCAP-DumpFileFormat.html#sectionshb) starts (signatured with `0A0D0D0A`). So lets delete the wav header and the few sound samples, and finally file also recognizes the file as `pcap`.

```bash
$ file wiretapped.wav
wiretapped.wav: pcapng capture file - version 1.0
```

After inspecting the capture with `Wireshark` we find this conversation:

```bash
hello there host computer 
hello there vm
do you know what the flag is
yeah i think it starts with bcactf{
ok and the rest of it?
uhh... listening_ ... i forgot the rest but i have it in an image somewhere, i'll send it to you
you still there?? it's been a long time
yeah i'm sorry i'm literally just making the flag on the fly
port 5500
ok lemme check it out
thanks i think i got it hopefully
```` 

Interesting... But no flag. In another stream (#2) we find a http request.

```bash
GET / HTTP/1.1
Host: 192.168.1.178:5500
User-Agent: curl/8.5.0
Accept: */*

HTTP/1.1 200 OK
Vary: Origin
Access-Control-Allow-Credentials: true
Accept-Ranges: bytes
Cache-Control: public, max-age=0
Last-Modified: Tue, 28 May 2024 20:02:59 GMT
ETag: W/"e9-18fc0cc83d9"
Content-Type: text/html; charset=UTF-8
Content-Length: 1726
Date: Tue, 28 May 2024 20:03:28 GMT
Connection: keep-alive
Keep-Alive: timeout=5

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body>
  <img src="rest_of_flag.jpg" alt="1">
  ....
```

Lets see if there are more streams we can follow. Stream #3 requests `rest_of_flag.jpg` but is canceled before the whole image data was transferred. Stream #4 looks better, the same request for `rest_of_flag.jpg` but not canceled this time. Lets extract the data, for this I followed stream #4 and exported raw data (only server->client part) to a file and removed the part before the image data starts (which starts with the byte sequence `FF D8 FF E0 00 10 4A 46 49 46`).

![](rest_of_flag.jpg)

Stitching this together with the first part, we found in the conversation before we get the flag.

Flag `bcactf{listening_in_a28270fb0dbfd}`