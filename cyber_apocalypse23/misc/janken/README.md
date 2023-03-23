# Cyber Apocalypse 2023

## Janken

> As you approach an ancient tomb, you're met with a wise guru who guards its entrance. In order to proceed, he challenges you to a game of Janken, a variation of rock paper scissors with a unique twist. But there's a catch: you must win 100 rounds in a row to pass. Fail to do so, and you'll be denied entry.
>
>  Author: N/A
>
> [`misc_janken.zip`](misc_janken.zip)

Tags: _misc_

## Solution
We are provided with some files. The interesting part is an executable that lets you play a game of rock-paper-scissors. Opening `janken` in Ghidra gives us the following code:
```c++
void game(void)

{
  int iVar1;
  time_t tVar2;
  ushort **ppuVar3;
  size_t sVar4;
  char *pcVar5;
  long in_FS_OFFSET;
  ulong local_88;
  char *local_78 [4];
  char *local_58 [4];
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  tVar2 = time((time_t *)0x0);
  srand((uint)tVar2);
  iVar1 = rand();
  local_78[0] = "rock";
  local_78[1] = "scissors";
  local_78[2] = "paper";
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  local_58[0] = "paper";
  local_58[1] = &DAT_0010252a;
  local_58[2] = "scissors";
  fwrite(&DAT_00102540,1,0x33,stdout);
  read(0,&local_38,0x1f);
  fprintf(stdout,"\n[!] Guru\'s choice: %s%s%s\n[!] Your  choice: %s%s%s",&DAT_00102083,
          local_78[iVar1 % 3],&DAT_00102008,&DAT_0010207b,&local_38,&DAT_00102008);
  local_88 = 0;
  do {
    sVar4 = strlen((char *)&local_38);
    if (sVar4 <= local_88) {
LAB_001017a2:
      pcVar5 = strstr((char *)&local_38,local_58[iVar1 % 3]);
      if (pcVar5 == (char *)0x0) {
        fprintf(stdout,"%s\n[-] You lost the game..\n\n",&DAT_00102083);
                    // WARNING: Subroutine does not return
        exit(0x16);
      }
      fprintf(stdout,"\n%s[+] You won this round! Congrats!\n%s",&DAT_0010207b,&DAT_00102008);
      if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    // WARNING: Subroutine does not return
        __stack_chk_fail();
      }
      return;
    }
    ppuVar3 = __ctype_b_loc();
    if (((*ppuVar3)[*(char *)((long)&local_38 + local_88)] & 0x2000) != 0) {
      *(undefined *)((long)&local_38 + local_88) = 0;
      goto LAB_001017a2;
    }
    local_88 = local_88 + 1;
  } while( true );
}
```

It's more or less clear whats going on. The computer chooses a random value and the player can enter his move as a string. Afterwards both values are compared and decided who won. The weak part of this is the comparison. `strstr` takes a string to be scanned as first parameter and a string containing the sequence of characters to match. If found the function returns the offset of the match inside the scanned string, otherwise the function returns NULL.

The problem is that our input is the string that is scanned, so we can easily just enter `rockpaperscissors` and the computers choice will always be found.

Writing a short [`script`](solution.py) that will play against the computer until the flag is reveiled.

```python
#!/usr/bin/env python3

from pwn import *

#context.log_level="debug"

if args.REMOTE:
    p = remote("165.232.98.59", 30874)
else:
    p = process("./janken")

p.sendlineafter(b"> ", b"1")

for i in range(0,99):
    p.sendlineafter(b"> ", b"rockscissorspaper")

p.recvuntil(b"prize:")
print(p.recvline().decode())
```

This will eventually lead to the flag `HTB{r0ck_p4p3R_5tr5tr_l0g1c_buG}`.