# DeconstruCT.F 2023

## Two Paths

> Logan gave me this image file before disappearing..
I've been breaking my head over it for long
Can you decode it?
>
>  Author: Rakhul
>
> [`hello.jpg`](hello.jpg)

Tags: _forensics_

## Solution
For this challenge, yet another image is presented. Checking hidden content with `binwalk` reveils two more images `greenpill.jpg` and `redpill.jpg`. Greenpill is a dead end, it contains another file `flag.jpg` which only tells us this is not the flag...

```bash
binwalk -e hello.jpg
```

The redpill on the other hand gives two interesting files `morse.wav` and `secrett.zip`. The zip archive is password secured, but the wav file looks interesting. It sounds strongly like morese code (although the name gives it away). 

Decoding the audio stream [`here`](https://morsecode.world/international/decoder/audio-decoder-adaptive.html), gives the following output:

```
T H E P A S S W O R D I S T H E H O V E R C R A F T O F M O R P H E U S
```

Since `hovercraft of morpheus` did not work as password, we check what `Morpheus Hovercraft` might be. The whole `Matrix` theme hints that the password might be `Nebuchadnezzar`. And indeed, `secrett.zip` can be extracted with this password.

A new file appears `deep_secret.wav` that plays some nice music. Looking into the file and trying a few things like applying a `lowpass filter` leads to nothing. But then, there is a steganography  tool [`DeepSound`](https://jpinsoft.net/deepsound/overview.aspx) that would be fitting. Decrypting with `DeepSound` leads the flag.

Flag `dsc{u_ch053_THE_cOrr3Ct_pill!}`