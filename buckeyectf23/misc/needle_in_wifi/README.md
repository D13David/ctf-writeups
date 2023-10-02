# BuckeyeCTF 2023

## Needle in the Wifi Stack

>  Author: arcsolstice
>
> [`frames.pcap`](frames.pcap)

Tags: _misc_

## Solution
For this challenge we get a network capture. Checking with wireshark we find a lot of broadcast packets like this. The `SSID` value strongly looks like `base64` encoded data so we check if this is the case.

```bash
1   0.000000 22:22:22:22:22:22 → Broadcast    802.11 120 Beacon frame, SN=0, FN=0, Flags=........, BI=100, SSID=bG9vMDBvMDBvbzBvMG9vb3Q3YSB0cjRm
2   0.029637 22:22:22:22:22:22 → Broadcast    802.11 140 Beacon frame, SN=0, FN=0, Flags=........, BI=100, SSID=N2hpcyBpcyBub3QgdGgzIG5lN3dvcmsg
3   0.041307 22:22:22:22:22:22 → Broadcast    802.11 100 Beacon frame, SN=0, FN=0, Flags=........, BI=100, SSID=d2lmaSBpNSBteSBwYTVzaW9uCg==
```

```bash
$ echo "bG9vMDBvMDBvbzBvMG9vb3Q3YSB0cjRm" | base64 -d
loo00o00oo0o0ooot7a tr4f
$ echo "N2hpcyBpcyBub3QgdGgzIG5lN3dvcmsg" | base64 -d
7his is not th3 ne7work
```

This looks good, so somewhere here must be the flag. But its a total of `101000` packets an we don't want to do this manually. We can let `tshark` fetch the `SSID` field by calling `-T fields -e wlan.ssid` and just have to decode and grep for the flag.

```bash
$ tshark -r frames.pcap -T fields -e wlan.ssid | base64 -d | grep bctf
bctf{tw0_po1nt_4_g33_c0ng3s7i0n}
```

Flag `bctf{tw0_po1nt_4_g33_c0ng3s7i0n}`