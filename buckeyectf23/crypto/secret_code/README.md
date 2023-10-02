# BuckeyeCTF 2023

## Secret Code

> Here's your flag again: `1:10:d0:10:42:41:34:20:b5:40:03:30:91:c5:e1:e3:d2:a2:72:d1:61:d0:10:e3:a0:43:c1:01:10:b1:b1:b0:b1:40:9`` LOL you `snub_wrestle`. Good luck trying to undo my xor key I used on each character of the flag.
> 
>  Author: jm8
>

Tags: _crypto_

## Solution
From the description we can assume that `snub_wrestle` is the xor key. What we have to do is to xor the encrypted flag again with this key. After some confusion and trial and error it turned out that the colons needed to be just removed, so the first byte would be `0x11` rather than `0x01` (if the colons where byte seperators). After this the remaining part is straight forward.

```python
foo = bytes.fromhex("110d01042413420b540033091c5e1e3d2a272d161d010e3a043c10110b1b1b0b1409")
key = b"snub_wrestle"

for i, c in enumerate(foo):
    print(chr(c^key[i%len(key)]), end="")
```

Flag `bctf{d0n't_lo0k_uP_snub_wResTling}`