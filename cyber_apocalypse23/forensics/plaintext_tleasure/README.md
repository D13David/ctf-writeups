# Cyber Apocalypse 2023

## Plaintext Tleasure

> Threat intelligence has found that the aliens operate through a command and control server hosted on their infrastructure. Pandora managed to penetrate their defenses and have access to their internal network. Because their server uses HTTP, Pandora captured the network traffic to steal the server's administrator credentials. Open the provided file using Wireshark, and locate the username and password of the admin.
>
>  Author: N/A
>
> [`forensics_plaintext_treasure.zip`](forensics_plaintext_treasure.zip)

Tags: _forensics_

## Solution
Delivered is a network packet capture we can look at. The title of the challenge suggests plain text so the first thing is to run `strings` on the file:

```
$ strings capture.pcap | grep HTB
HTB{th3s3_4l13ns_st1ll_us3_HTTP}
```

Flag `HTB{th3s3_4l13ns_st1ll_us3_HTTP}`