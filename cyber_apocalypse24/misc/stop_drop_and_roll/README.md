# Cyber Apocalypse 2024

## Stop Drop and Roll

> The Fray: The Video Game is one of the greatest hits of the last... well, we don't remember quite how long. Our "computers" these days can't run much more than that, and it has a tendency to get repetitive...
> 
> Author: ir0nstone
> 

Tags: _misc_

## Solution
This is a again a basic programming challenge. If we connect to the container we get the instructions of the game.

```bash
$ nc 83.136.253.251 54021
===== THE FRAY: THE VIDEO GAME =====
Welcome!
This video game is very simple
You are a competitor in The Fray, running the GAUNTLET
I will give you one of three scenarios: GORGE, PHREAK or FIRE
You have to tell me if I need to STOP, DROP or ROLL
If I tell you there's a GORGE, you send back STOP
If I tell you there's a PHREAK, you send back DROP
If I tell you there's a FIRE, you send back ROLL
Sometimes, I will send back more than one! Like this:
GORGE, FIRE, PHREAK
In this case, you need to send back STOP-ROLL-DROP!
Are you ready? (y/n)
```

So the program tells us a sequence of `GORGE`, `PHREAK` and `FIRE` and we have to replace each of the words to the counterparts (`STOP`, `DROP`, `ROLL`).

```python
from pwn import *

p = remote("83.136.254.199", 37958)

p.sendlineafter(b"(y/n)", b"y")
p.readuntil(b"Let's go!\n")
while True:
    foo = p.recvline().split(b",")
    print(foo)
    res = []
    for x in foo:
        if b"GORGE" in x: res.append(b"STOP")
        if b"PHREAK" in x: res.append(b"DROP")
        if b"FIRE" in x: res.append(b"ROLL")
    print(res)
    p.sendline(b"-".join(res))
```

Afer a while we get the flag.

Flag `HTB{1_wiLl_sT0p_dR0p_4nD_r0Ll_mY_w4Y_oUt!}`