# WaniCTF 2024

## I_wanna_be_a_streamer

> Sorry Mom, I'll work as a streamer.
> Watch my stream once in a while.
> (H.264 is used for video encoding.)
> 
>  Author: kaki005
>
> [`for-I-wanna-be-a-streamer.zip`](for-I-wanna-be-a-streamer.zip)

Tags: _forensics_

## Solution
This challenge comes with a zip archive. After extracting the archive we find a `pcap` network traffic capture.

After opening the capture with `WireShark` we can see a lot of [`RTP`](https://en.wikipedia.org/wiki/Real-time_Transport_Protocol) packages.

```bash
...
51	8.607892	192.168.0.105	192.168.0.100	RTP	93	PT=DynamicRTP-Type-96, SSRC=0x4823, Seq=6335, Time=3710872343
52	8.607892	192.168.0.105	192.168.0.100	RTP	60	PT=DynamicRTP-Type-96, SSRC=0x4823, Seq=6336, Time=3710872343, Mark
53	8.607892	192.168.0.105	192.168.0.100	RTP	60	PT=DynamicRTP-Type-96, SSRC=0x4823, Seq=6337, Time=3710872347
54	8.607892	192.168.0.105	192.168.0.100	RTP	76	PT=DynamicRTP-Type-96, SSRC=0x4823, Seq=6338, Time=3710872347
55	8.607892	192.168.0.105	192.168.0.100	RTP	1471	PT=DynamicRTP-Type-96, SSRC=0x4823, Seq=6339, Time=3710872347
56	8.607892	192.168.0.105	192.168.0.100	RTP	1472	PT=DynamicRTP-Type-96, SSRC=0x4823, Seq=6340, Time=3710872347
...
```

The raw `RTP` packages are not of much use for us, since we are actually interested in the `payload` they transfer. But the description gave us an hint, a videostream with `H.264 encoding` was transferred. So lets decode the package payload for exactly this (`right-click on one of the packages -> Decode As... -> choose H.264 in the dialog for 'Current'`).

This looks better, now we can see the actuall payload. To extract the full stream we can use this [`plugin`](https://github.com/volvet/h264extractor). After installing it, choose `Tools -> Extract h264 stream from RTP` and the stream will be extracted and stored in the documents folder.

To watch the video, there is one final step we need to do. Most video players will not be able to play the raw video stream, so we use [`FFpeg`](https://ffmpeg.org/) to convert the stream to a `mp4` that we can play.

```bash
$ ffmpeg -i stream.raw -c copy video.mp4
```

And here we go, opening the file with any video player gives us the flag.

![](flag.png)

Flag `FLAG{Th4nk_y0u_f0r_W4tching}`