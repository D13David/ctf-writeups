# Google CTF 2023

## WRITE-FLAG-WHERE

> This challenge is not a classical pwn
In order to solve it will take skills of your own
An excellent primitive you get for free
Choose an address and I will write what I see
But the author is cursed or perhaps it's just out of spite
For the flag that you seek is the thing you will write
ASLR isn't the challenge so I'll tell you what
I'll give you my mappings so that you'll have a shot.
>
>  Author: N/A
>
> [`attachment.zip`](attachment.zip)

Tags: _pwn_

## Solution
This challenge is providing an executable and a libc library package for local use. Opening the `elf` in Ghidra the following code is decompiled.

```c
undefined8 main(void)

{
  int iVar1;
  ssize_t sVar2;
  undefined8 local_78;
  undefined8 local_70;
  undefined8 local_68;
  undefined8 local_60;
  undefined8 local_58;
  undefined8 local_50;
  undefined8 local_48;
  undefined8 local_40;
  uint local_2c;
  __off64_t local_28;
  int local_20;
  undefined4 local_1c;
  int local_18;
  int local_14;
  int local_10;
  int local_c;
  
  local_c = open("/proc/self/maps",0);
  read(local_c,maps,0x1000);
  close(local_c);
  local_10 = open("./flag.txt",0);
  if (local_10 == -1) {
    puts("flag.txt not found");
  }
  else {
    sVar2 = read(local_10,flag,0x80);
    if (0 < sVar2) {
      close(local_10);
      local_14 = dup2(1,0x539);
      local_18 = open("/dev/null",2);
      dup2(local_18,0);
      dup2(local_18,1);
      dup2(local_18,2);
      close(local_18);
      alarm(0x3c);
      dprintf(local_14,
              "This challenge is not a classical pwn\nIn order to solve it will take skills of your  own\nAn excellent primitive you get for free\nChoose an address and I will write what  I see\nBut the author is cursed or perhaps it\'s just out of spite\nFor the flag that  you seek is the thing you will write\nASLR isn\'t the challenge so I\'ll tell you what \nI\'ll give you my mappings so that you\'ll have a shot.\n"
             );
      dprintf(local_14,"%s\n\n",maps);
      while( true ) {
        dprintf(local_14,
                "Give me an address and a length just so:\n<address> <length>\nAnd I\'ll write it wh erever you want it to go.\nIf an exit is all that you desire\nSend me nothing and I  will happily expire\n"
               );
        local_78 = 0;
        local_70 = 0;
        local_68 = 0;
        local_60 = 0;
        local_58 = 0;
        local_50 = 0;
        local_48 = 0;
        local_40 = 0;
        sVar2 = read(local_14,&local_78,0x40);
        local_1c = (undefined4)sVar2;
        iVar1 = __isoc99_sscanf(&local_78,"0x%llx %u",&local_28,&local_2c);
        if ((iVar1 != 2) || (0x7f < local_2c)) break;
        local_20 = open("/proc/self/mem",2);
        lseek64(local_20,local_28,0);
        write(local_20,flag,(ulong)local_2c);
        close(local_20);
      }
                    /* WARNING: Subroutine does not return */
      exit(0);
    }
    puts("flag.txt empty");
  }
  return 1;
}
```

First `/proc/self/maps` and `flag.txt` are opened and read. Afterwards the banner and the process memory map is printed. This is a lot of information we will need later. 

```bash
$ nc wfw1.2023.ctfcompetition.com 1337
== proof-of-work: disabled ==
This challenge is not a classical pwn
In order to solve it will take skills of your own
An excellent primitive you get for free
Choose an address and I will write what I see
But the author is cursed or perhaps it's just out of spite
For the flag that you seek is the thing you will write
ASLR isn't the challenge so I'll tell you what
I'll give you my mappings so that you'll have a shot.
558e733d1000-558e733d2000 r--p 00000000 00:11e 810424                    /home/user/chal
558e733d2000-558e733d3000 r-xp 00001000 00:11e 810424                    /home/user/chal
558e733d3000-558e733d4000 r--p 00002000 00:11e 810424                    /home/user/chal
558e733d4000-558e733d5000 r--p 00002000 00:11e 810424                    /home/user/chal
558e733d5000-558e733d6000 rw-p 00003000 00:11e 810424                    /home/user/chal
558e733d6000-558e733d7000 rw-p 00000000 00:00 0
7f3a75ace000-7f3a75ad1000 rw-p 00000000 00:00 0
7f3a75ad1000-7f3a75af9000 r--p 00000000 00:11e 811203                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f3a75af9000-7f3a75c8e000 r-xp 00028000 00:11e 811203                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f3a75c8e000-7f3a75ce6000 r--p 001bd000 00:11e 811203                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f3a75ce6000-7f3a75cea000 r--p 00214000 00:11e 811203                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f3a75cea000-7f3a75cec000 rw-p 00218000 00:11e 811203                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f3a75cec000-7f3a75cf9000 rw-p 00000000 00:00 0
7f3a75cfb000-7f3a75cfd000 rw-p 00000000 00:00 0
7f3a75cfd000-7f3a75cff000 r--p 00000000 00:11e 811185                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f3a75cff000-7f3a75d29000 r-xp 00002000 00:11e 811185                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f3a75d29000-7f3a75d34000 r--p 0002c000 00:11e 811185                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f3a75d35000-7f3a75d37000 r--p 00037000 00:11e 811185                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f3a75d37000-7f3a75d39000 rw-p 00039000 00:11e 811185                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7fff752e4000-7fff75305000 rw-p 00000000 00:00 0                          [stack]
7fff75366000-7fff7536a000 r--p 00000000 00:00 0                          [vvar]
7fff7536a000-7fff7536c000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0                  [vsyscall]


Give me an address and a length just so:
<address> <length>
And I'll write it wherever you want it to go.
If an exit is all that you desire
Send me nothing and I will happily expire
```

The interesting part is in the following loop. It gives the user the opportunity to write the flag on any memory address. As this happens within a loop one good spot to write the flag to is the location where the `Give me an address and a length...` message is stored, so in the next iteration the program will print the flag instead of the message. This can be done by inspecting the `ds` in Ghidra or just grepping for the string.

```bash
$ grep --byte-offset --only-matching --text "Give me" chal
8672:Give me
```
For the real address in memory, this offset needs to be added to the image offset which we can just copy from the memory mapping: `0x558e733d1000 + 0x21e0 = 0x558e733d31e0"

Providing this as an input, will give the flag:
```
0x558e733d31e0 111
CTF{Y0ur_j0urn3y_is_0n1y_ju5t_b39innin9}
```

Flag `CTF{Y0ur_j0urn3y_is_0n1y_ju5t_b39innin9}`