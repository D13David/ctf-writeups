#!/usr/bin/env python3

from pwn import *

context.log_level="debug"

if args.REMOTE:
    p = remote("161.35.168.118", 31232)
else:
    p = process(binary.path)

p.sendlineafter(b"> ", b"1")

while True:
    line = p.recvline().decode()
    print(line)
    if "]:" in line:
        line = line.split(":")[-1][:-5].strip()
        print(line)
        try:
            foo = round(eval(line),2)
            print(foo)
            if foo >= -1337 and foo <= 1337:
                p.sendlineafter(b"> ", str(foo).encode())
            else:
                p.sendlineafter(b"> ", b"MEM_ERR")
        except ZeroDivisionError:
            p.sendlineafter(b"> ", b"DIV0_ERR")
        except SyntaxError:
            p.sendlineafter(b"> ", b"SYNTAX_ERR")
