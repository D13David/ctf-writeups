# SunshineCTF 2023

## DDR

>All the cool robots are playing Digital Dance Robots, a new rythmn game that... has absolutely no sound! Robots are just that good at these games... until they crash because they can't count to 256. Can you beat the high score and earn a prize?
> 
>  Author: N/A
>

Tags: _scripting_

## Solution
For this challenge we get a service we can netcat to. If we do so we get 

```bash
$ nc chal.2023.sunshinectf.games 23200
Welcome to DIGITAL DANCE ROBOTS!

       -- INSTRUCTIONS --
 Use the WASD keys to input the
 arrow that shows up on screen.
 If you beat the high score of
     255, you win a FLAG!

   -- Press ENTER To Start --


⇩⇧⇦⇩⇨⇦⇩⇧⇦⇨⇦⇧⇨⇦⇦⇦⇩⇨⇨⇩⇨⇩⇦⇧⇦⇩⇨⇩⇧⇨⇧⇧⇦⇨⇨⇦⇦⇩⇨⇧⇨⇨⇧⇨⇨⇨⇩⇦⇩⇩
You lose... better luck next time!
Score: 1
```

The timeout is way to short so we can manually translate the arrows to `wasd`, but we can do it with an script. And sure enough, after a while we get the flag.

```python
from pwn import *

p = remote("chal.2023.sunshinectf.games", 23200)

p.recvuntil(b"ENTER")
p.sendline(b"")
p.recvline()
p.recvline()
for i in range(0, 256):
    print(i)
    foo = p.recvline().decode("utf-8")
    bar = b""
    for x in foo:
        if x == "⇧": bar += b"w"
        if x == "⇦": bar += b"a"
        if x == "⇩": bar += b"s"
        if x == "⇨": bar += b"d"
    p.sendline(bar)

p.interactive()
```

Flag `sun{d0_r0b0t5_kn0w_h0w_t0_d4nc3}`