# Cyber Apocalypse 2024

## Character

> Security through Induced Boredom is a personal favourite approach of mine. Not as exciting as something like The Fray, but I love making it as tedious as possible to see my secrets, so you can only get one character at a time!
> 
> Author: ir0nstone
> 

Tags: _misc_

## Solution
For this challenge we get a container we can connect to. We basically can just tell the index for the flag character we want to query and get it.

```bash
$ nc 94.237.54.161 44142
Which character (index) of the flag do you want? Enter an index: 0
Character at Index 0: H
Which character (index) of the flag do you want? Enter an index: 1
Character at Index 1: T
Which character (index) of the flag do you want? Enter an index: 2
Character at Index 2: B
```

Since we don't want to do this by hand, we write a script the build the flag for us.

```python
from pwn import *

p = remote("83.136.249.159", 32864)

index = 0
while True:
    p.sendlineafter(b"Enter an index:", str(index).encode())
    c = p.recvline()
    c = c[len(c)-2]
    print(chr(c),end="")
    if c == b'}':
        break
    index += 1
```

Flag `HTB{tH15_1s_4_r3aLly_l0nG_fL4g_i_h0p3_f0r_y0Ur_s4k3_tH4t_y0U_sCr1pTEd_tH1s_oR_els3_iT_t0oK_qU1t3_l0ng!!}`