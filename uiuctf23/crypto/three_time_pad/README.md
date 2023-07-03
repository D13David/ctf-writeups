# UIUCTF 2023

## Three-Time Pad

> "We've been monitoring our adversaries' communication channels, but they encrypt their data with XOR one-time pads! However, we hear rumors that they're reusing the pads...\n\nEnclosed are three encrypted messages. Our mole overheard the plaintext of message 2. Given this information, can you break the enemy's encryption and get the plaintext of the other messages?"
>
>  Author: Pomona
>
> [`c1`](c1)
> [`c2`](c2)
> [`c3`](c3)
> [`p2`](p2)

Tags: _crypto_

## Solution
This challenge uses a [`One-Time Pad`](https://en.wikipedia.org/wiki/One-time_pad). While the `OTP` is uncrackeable it relies on using a single-use pre-shared key. In this challenge the key is reused this basically breaks the whole security.

Since we have the original message for `c2` we can easily recreate the key by just xoring  `c2` and `p2`. This works since xor operations are commutative (order doesnt matter), self-inverse (xor the same value is always 0) and 0 is the identity (0 xor any value is the value again).

`p2 ⊕ k = c2`\
`p2 ⊕ k ⊕ p2 = c2 ⊕ p2`\
`(p2 ⊕ p2) ⊕ k = c2 ⊕ p2`\
`0 ⊕ k = c2 ⊕ p2`\
`k = c2 ⊕ p2`

After the key is recreated the messages for `c1` and `c3` can be retrieved with the same idea by removing the `key` part by xoring `c1` and `c3` with the `key`.

```python
from pwn import *
p = open("p2", "rb").read()
c2 = open("c2", "rb").read()
c1 = open("c1", "rb").read()
c3 = open("c3", "rb").read()
print(p)
print(xor(c1,xor(p,c2)))
print(xor(c3,xor(p,c2)))
```

```bash
$ python solve.py
b'printed on flammable material so that spies could'
b'before computers, one-time pads were sometimes\x1d\x96\xf7'
b'uiuctf{burn_3ach_k3y_aft3r_us1ng_1t}\xdbU(e5\x96S:\x1c\xa6\xe6>\x9f'
```

Flag `uiuctf{burn_3ach_k3y_aft3r_us1ng_1t}`