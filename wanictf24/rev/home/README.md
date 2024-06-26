# WaniCTF 2024

## home

> The function that processes the FLAG has been obfuscated. You don't want to read it... do you?
>
>  Author: Mikka
>
> [`rev-home.zip`](rev-home.zip)

Tags: _rev_

## Solution
For this challenge we get a binary to reverse. After opening the binary in `Binary Ninja` we find the main function calls `constructFlag` after doing some checks. The first check done is to see if [`getcwd`](https://man7.org/linux/man-pages/man3/getcwd.3.html) returns `Service`. Since `getcwd` returns `a null-terminated string containing an absolute pathname that is the current working directory of the calling process` the check is bound to fail. 

The second check is actually a anti debugging measurement. Calling `ptrace(PTRACE_TRACEME, 0, 0, 0)` which will fail if a debugger is attached. If both checks pass, the function calls `constructFlag`.

We could patch the program to pass through both tests, the problem is that `constructFlag` does not actually print the flag but only `Processing completed!`, leaving the flag somewhere in memory. Also the function is somewhat obfuscated, so directly reversing is not fun at all. Since we don't have any further dependencies for `constructFlag` we actually can just call the function directly. For this we start the program with `gdb` and set `rip` to `constructFlag`.

```bash
pwndbg> break main
pwndbg> r
pwndbg> disassemble constructFlag
   0x00005555555551b0 <+0>:     push   rbp
   0x00005555555551b1 <+1>:     mov    rbp,rsp
   0x00005555555551b4 <+4>:     push   r15
   0x00005555555551b6 <+6>:     push   r14
   0x00005555555551b8 <+8>:     push   r13
   0x00005555555551ba <+10>:    push   r12
   0x00005555555551bc <+12>:    push   rbx
   0x00005555555551bd <+13>:    sub    rsp,0x158
   0x00005555555551c4 <+20>:    lea    rax,[rip+0xe45]        # 0x555555556010
   0x00005555555551cb <+27>:    mov    ecx,0xb0
   0x00005555555551d0 <+32>:    mov    edx,ecx
   0x00005555555551d2 <+34>:    lea    rsi,[rbp-0x110]
   0x00005555555551d9 <+41>:    mov    rdi,rsi
   0x00005555555551dc <+44>:    mov    rsi,rax
   0x00005555555551df <+47>:    call   0x555555555070 <memcpy@plt>
   0x00005555555551e4 <+52>:    mov    DWORD PTR [rbp-0x114],0x0
   0x00005555555551ee <+62>:    mov    DWORD PTR [rbp-0x120],0x7c46699a
   0x00005555555551f8 <+72>:    mov    eax,DWORD PTR [rbp-0x120]
   0x00005555555551fe <+78>:    mov    ecx,eax
   0x0000555555555200 <+80>:    sub    ecx,0xa2245c7a
   0x0000555555555206 <+86>:    mov    DWORD PTR [rbp-0x124],eax
   0x000055555555520c <+92>:    mov    DWORD PTR [rbp-0x128],ecx
   0x0000555555555212 <+98>:    je     0x555555555860 <constructFlag+1712>
   0x0000555555555218 <+104>:   jmp    0x55555555521d <constructFlag+109>
...
   0x00005555555558e7 <+1847>:  call   0x555555555050 <printf@plt>
   0x00005555555558ec <+1852>:  xor    ecx,ecx
   0x00005555555558ee <+1854>:  mov    DWORD PTR [rbp-0x180],eax
   0x00005555555558f4 <+1860>:  mov    eax,ecx
   0x00005555555558f6 <+1862>:  add    rsp,0x158
   0x00005555555558fd <+1869>:  pop    rbx
   0x00005555555558fe <+1870>:  pop    r12
   0x0000555555555900 <+1872>:  pop    r13
   0x0000555555555902 <+1874>:  pop    r14
   0x0000555555555904 <+1876>:  pop    r15
   0x0000555555555906 <+1878>:  pop    rbp
   0x0000555555555907 <+1879>:  ret
   0x0000555555555908 <+1880>:  mov    DWORD PTR [rbp-0x120],0xde3c30d3
   0x0000555555555912 <+1890>:  jmp    0x555555555972 <constructFlag+1986>
   0x0000555555555917 <+1895>:  xor    eax,eax
   0x0000555555555919 <+1897>:  movsxd rcx,DWORD PTR [rbp-0x11c]
   0x0000555555555920 <+1904>:  mov    edx,DWORD PTR [rbp+rcx*4-0x110]
   0x0000555555555927 <+1911>:  mov    esi,DWORD PTR [rbp-0x11c]
   0x000055555555592d <+1917>:  sub    eax,esi
   0x000055555555592f <+1919>:  add    edx,eax
   0x0000555555555931 <+1921>:  mov    dil,dl
   0x0000555555555934 <+1924>:  movsxd rcx,DWORD PTR [rbp-0x11c]
   0x000055555555593b <+1931>:  mov    BYTE PTR [rbp+rcx*1-0x60],dil
   0x0000555555555940 <+1936>:  mov    DWORD PTR [rbp-0x120],0xe26ff5c7
   0x000055555555594a <+1946>:  jmp    0x555555555972 <constructFlag+1986>
   0x000055555555594f <+1951>:  mov    eax,DWORD PTR [rbp-0x11c]
   0x0000555555555955 <+1957>:  add    eax,0x67ac8c74
   0x000055555555595a <+1962>:  add    eax,0x1
   0x000055555555595d <+1965>:  sub    eax,0x67ac8c74
   0x0000555555555962 <+1970>:  mov    DWORD PTR [rbp-0x11c],eax
   0x0000555555555968 <+1976>:  mov    DWORD PTR [rbp-0x120],0xa2245c7a
   0x0000555555555972 <+1986>:  jmp    0x5555555551f8 <constructFlag+72>
pwndbg> break *constructFlag+1847
```

We want to set a breakpoint right where `constructFlag` prints it's message. For this we start the process, but break when entering main and then disassemble the function `constructFlag` to find the correct address to break. The print is called at `+1847` in `constructFlag` so we set a breakpoint there.

```bash
pwndbg> set $rip=constructFlag
pwndbg> c
──────────────────────────────────────────[ DISASM / x86-64 / set emulate on ]──────────────────────────────────────────
   0x5555555558e7 <constructFlag+1847>    call   printf@plt                <printf@plt>
        format: 0x5555555560c0 ◂— 'Processing completed!'
        vararg: 0x0

   0x5555555558ec <constructFlag+1852>    xor    ecx, ecx
   0x5555555558ee <constructFlag+1854>    mov    dword ptr [rbp - 0x180], eax
   0x5555555558f4 <constructFlag+1860>    mov    eax, ecx
   0x5555555558f6 <constructFlag+1862>    add    rsp, 0x158
   0x5555555558fd <constructFlag+1869>    pop    rbx
   0x5555555558fe <constructFlag+1870>    pop    r12
   0x555555555900 <constructFlag+1872>    pop    r13
   0x555555555902 <constructFlag+1874>    pop    r14
   0x555555555904 <constructFlag+1876>    pop    r15
   0x555555555906 <constructFlag+1878>    pop    rbp
```

After this we set the instruction pointer `rip` to `constructFlag` and just continue. When the breakpoint is hit we just need to find the flag. For instance checking the stack.

```bash
pwndbg> stack 40
00:0000│ rsp 0x7fffffffdb48 ◂— 0x200000200
01:0008│     0x7fffffffdb50 ◂— 0x0
02:0010│     0x7fffffffdb58 ◂— 0x1071e0df0892b214
03:0018│     0x7fffffffdb60 ◂— 0x1f69edd600000000
04:0020│     0x7fffffffdb68 ◂— 0x2ab2678f20643858
05:0028│     0x7fffffffdb70 ◂— 0x2e8006df
06:0030│     0x7fffffffdb78 ◂— 0x1dc4574500000000
07:0038│     0x7fffffffdb80 ◂— 0x2357111b1f234c27
08:0040│     0x7fffffffdb88 ◂— 0x25f63ff2248d202e
09:0048│     0x7fffffffdb90 ◂— 0x3669e62e2ec6bfbb
0a:0050│     0x7fffffffdb98 ◂— 0x538f5686467343cd
0b:0058│     0x7fffffffdba0 ◂— 0x19341ee5f6ee574
0c:0060│     0x7fffffffdba8 ◂— 0x2c019341ee
0d:0068│     0x7fffffffdbb0 ◂— 0x2c0000002c /* ',' */
0e:0070│     0x7fffffffdbb8 ◂— 0x4d00000046 /* 'F' */
0f:0078│     0x7fffffffdbc0 ◂— 0x4a00000043 /* 'C' */
10:0080│     0x7fffffffdbc8 ◂— 0x4d0000007f
11:0088│     0x7fffffffdbd0 ◂— 0x7e00000075 /* 'u' */
12:0090│     0x7fffffffdbd8 ◂— 0x6d00000067 /* 'g' */
13:0098│     0x7fffffffdbe0 ◂— 0x6f00000073 /* 's' */
14:00a0│     0x7fffffffdbe8 ◂— 0x860000006b /* 'k' */
15:00a8│     0x7fffffffdbf0 ◂— 0x840000007d /* '}' */
16:00b0│     0x7fffffffdbf8 ◂— 0x780000006f /* 'o' */
17:00b8│     0x7fffffffdc00 ◂— 0x8700000077 /* 'w' */
18:00c0│     0x7fffffffdc08 ◂— 0x7d00000073 /* 's' */
19:00c8│     0x7fffffffdc10 ◂— 0x890000007b /* '{' */
1a:00d0│     0x7fffffffdc18 ◂— 0x780000007d /* '}' */
1b:00d8│     0x7fffffffdc20 ◂— 0x710000004e /* 'N' */
1c:00e0│     0x7fffffffdc28 ◂— 0x9700000067 /* 'g' */
1d:00e8│     0x7fffffffdc30 ◂— 0x6b00000072 /* 'r' */
1e:00f0│     0x7fffffffdc38 ◂— 0x8300000089
1f:00f8│     0x7fffffffdc40 ◂— 0x9000000073 /* 's' */
20:0100│     0x7fffffffdc48 ◂— 0x8600000074 /* 't' */
21:0108│     0x7fffffffdc50 ◂— 0x8100000068 /* 'h' */
22:0110│     0x7fffffffdc58 ◂— 0x5d00000081
23:0118│     0x7fffffffdc60 ◂— 0x2b000000a7
24:0120│     0x7fffffffdc68 ◂— 'FLAG{How_did_you_get_here_4VKzTLibQmPaBZY4}'
25:0128│     0x7fffffffdc70 ◂— '_did_you_get_here_4VKzTLibQmPaBZY4}'
26:0130│     0x7fffffffdc78 ◂— '_get_here_4VKzTLibQmPaBZY4}'
27:0138│     0x7fffffffdc80 ◂— 'e_4VKzTLibQmPaBZY4}'
```

Flag `FLAG{How_did_you_get_here_4VKzTLibQmPaBZY4}`