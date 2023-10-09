# SunshineCTF 2023

## BeepBoop Cryptography

> Help! My IOT device has gone sentient!
> 
> All I wanted to know was the meaning of 42!
> 
> It's also waving its arms up and down, and I...
> 
> oh no! It's free!
> 
> AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
>
> Automated Challenge Instructions
> Detected failure in challenge upload. Original author terminated. Please see attached file BeepBoop for your flag... human.
> 
>  Author: N/A
>
> [`BeepBoop`](BeepBoop)

Tags: _crypto_

## Solution
The file delivered contained a sequence of `beep` and `boop`.

```
beep beep beep beep boop beep boop beep beep boop boop beep beep boop boop beep beep boop boop beep boop beep beep beep beep boop boop beep beep beep beep boop beep boop boop boop boop beep boop boop beep boop boop boop beep beep boop beep beep boop boop beep boop beep boop boop beep boop boop beep beep boop boop boop beep boop boop boop beep beep boop beep beep boop boop beep beep boop beep boop beep boop boop boop boop beep boop beep beep boop boop boop beep boop boop beep beep boop boop beep beep beep beep boop beep boop boop beep boop boop boop beep beep boop boop beep beep boop boop boop beep boop boop boop beep beep boop beep beep beep boop beep boop boop beep boop beep boop boop boop beep beep boop beep beep boop boop beep boop beep boop boop beep boop boop beep beep boop boop boop beep boop boop boop beep beep boop beep beep boop boop beep beep boop beep boop beep boop boop boop boop beep boop beep beep boop boop boop beep boop boop beep beep boop boop beep beep beep beep boop beep boop boop beep boop boop boop beep beep boop boop beep beep boop boop boop beep boop boop boop beep beep boop beep beep beep boop beep boop boop beep boop beep boop boop boop beep beep boop beep beep boop boop beep boop beep boop boop beep boop boop beep beep boop boop boop beep boop boop boop beep beep boop beep beep boop boop beep beep boop beep boop beep boop boop boop boop beep boop beep beep boop boop boop beep boop boop beep beep boop boop beep beep beep beep boop beep boop boop beep boop boop boop beep beep boop boop beep beep boop boop boop beep boop boop boop beep beep boop beep beep boop boop boop boop boop beep boop
```

Now this looks like some binary code. If we replace beep with `0` and boop with `1` we get 

```
0000101001100110011010000110000101111011011100100110101101100111011100100110010101111010011101100110000101101110011001110111001000101101011100100110101101100111011100100110010101111010011101100110000101101110011001110111001000101101011100100110101101100111011100100110010101111010011101100110000101101110011001110111001001111101
```

```python
bits = "0000101001100110011010000110000101111011011100100110101101100111011100100110010101111010011101100110000101101110011001110111001000101101011100100110101101100111011100100110010101111010011101100110000101101110011001110111001000101101011100100110101101100111011100100110010101111010011101100110000101101110011001110111001001111101"
text = int(bits, 2)
text.to_bytes((text.bit_length()+7)//8, 'big').decode()
```

This gives us `fha{rkgrezvangr-rkgrezvangr-rkgrezvangr}` which looks like some substitution cipher ([`rot13`](https://en.wikipedia.org/wiki/ROT13) for instance). And indeed, rot13 gives us the flag.

```bash
$ echo "fha{rkgrezvangr-rkgrezvangr-rkgrezvangr}" | rot13
sun{exterminate-exterminate-exterminate}
```

Flag `sun{exterminate-exterminate-exterminate}`