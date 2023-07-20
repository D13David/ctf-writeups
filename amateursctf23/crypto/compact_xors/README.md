# AmateursCTF 2023

## Compact XORs

> I found some hex in a file called fleg, but I'm not sure how it's encoded. I'm pretty sure it's some kind of xor...
>
>  Author: skittles1412
>
> [`fleg`](fleg)

Tags: _crypto_

## Solution
The challenge is provided with hex data string. Converting the values to binary gives a suspicious picture. Every second entry is in actual printable ascii range 

```
0b1100001 a
0b0001100
0b1100001 a
0b0010101
0b1100101 e
0b0010000
0b1110010 r
0b0000001
0b1000011 C
0b0010111
0b1000110 F
0b0111101
```

This loos closely to the well known beginning of the flag format `amateursCTF{`. So the characters inbetween need to be decoded somehow. Knowing the start of the flag we can try to see what bits are missing to come from `0b0001100` to `m` for instance, which would be `0b1101101`. Looking closely, the missing bits are coming from the character before, so every character `2*n` can be decoded by doing `list[2*n] ^ list[2*n-1]`. A quick python script reveals the flag.

```python
flag = bytes.fromhex("610c6115651072014317463d73127613732c73036102653a6217742b701c61086e1a651d742b69075f2f6c0d69075f2c690e681c5f673604650364023944")

for c in range(0, len(flag)-1,2):
    print(chr(flag[c])+chr(flag[c]^flag[c+1]), end="")
```

Flag `amateursCTF{saves_space_but_plaintext_in_plain_sight_862efdf9}`