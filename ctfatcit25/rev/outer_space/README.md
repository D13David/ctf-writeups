# CTF@CIT 2025

## Outer Space

> This reminds me of Apollo 11...
>
>  Author: N/A
>
> [`outerspace`](outerspace)

Tags: _rev_

## Solution
For this challenge we get again a binary we open with `BinaryNinja` and find the main function. Main starts at `004082ec` and is rather lengthy, so let's walk through this step by step.

```c
// ...
00408322        std::string::ctor(0x2f3124e2);
00408327        *(uint32_t*)0x2f3124ba = 0x3039;
00408345        std::cout(&data_5f1bc0, "Enter server IP address: ");
0040835e        std::cin(&data_5f1ce0, 0x2f3124e2);
00408377        *(uint32_t*)client_socket = socket(2, 1, 0);
00408384        int32_t rbx;
00408384        
00408384        if (*(uint32_t*)client_socket >= 0)
00408384        {
// ...
00408384        }
00408384        else
00408384        {
00408390            sub_406819("socket");
00408395            rbx = 1;
00408384        }
// ...
```

The program prompts for a server ip address and opens a socket. Also this binary is stripped, therefore the functions need to be renamed by doing educated guessing. For instance, we can follow the call at `00408377` and see it does a `syscall` with function 41. [`Looking up`](https://filippo.io/linux-syscall-table/) the syscall we see it's calling [`sys_socket`](https://github.com/search?q=repo%3Atorvalds%2Flinux+%2FSYSCALL_DEFINE%5B%5E%2C%5D*%5Cbsocket%5Cb%2F&type=code).

We also can see the function passes `AF_INET (2)` for `domain`, `SOCK_STREAM (1)` for `type` and `0` for `protocol`. So this creates a `TCP socket` over `IPv4`.

```c
// ...
004083b3        bzero(0x2f3124d2, 0, 0x10);
004083b8        *(uint16_t*)0x2f3124d2 = 2;
004083d1        *(uint16_t*)0x2f3124d4 = htons((int16_t)*(uint32_t*)0x2f3124ba);
00408407        int32_t rax_6;
00408407        rax_6 = connect(2, sub_47f380(0x2f3124e2), 0x2f3124d6) <= 0;
00408407        
0040840c        if (!rax_6)
0040840c        {
// ...
0040840c        }
0040840c        else
0040840c        {
00408434            sub_468ce0(std::cout(&data_5f1aa0, "Invalid IP address format."), 
00408434                sub_469d50, sub_469d50);
00408441            sub_542560(*(uint32_t*)0x2f3124be);
00408446            rbx = 1;
0040840c        }
// ...
```

Next up the program fills a [`sockaddr_in`](https://man7.org/linux/man-pages/man3/sockaddr.3type.html) struct with...

```bash
sin_family = AF_INET
sin_port = 12345
sin_addr = INADDR_ANY
```

... and connects the socket to this address. After connecting the client reads input though the socket from the server.

```c
00408471        if (!(char)(sub_545060((*(uint32_t*)client_socket), 0x2f3124d2, 0x10)
00408471            >> 0x1f))
00408471        {
004084bf            sub_468ce0(std::cout(&data_5f1bc0, "Connected to server."), sub_469d50, 
004084bf                sub_469d50);
004084c4            *(uint32_t*)0x2f3124c2 = 0x400;
004084e2            j_sub_511e40(0x2f312522, 0, 0x400);
00408505            *(uint32_t*)0x2f3124c6 =
00408505                recv((*(uint32_t*)client_socket), 0x2f312522, 0x3ff, 0);
00408505            
00408512            if (*(uint32_t*)0x2f3124c6 >= 0)
00408512            {
// ...
00408512            }
00408512            else
00408512            {
0040851e                sub_406819("recv");
0040852b                sub_542560((*(uint32_t*)client_socket));
00408530                rbx = 1;
00408512            }
00408471        }
00408471        else
00408471        {
0040847d            sub_406819("connect");
0040848a            sub_542560((*(uint32_t*)client_socket));
0040848f            rbx = 1;
00408471        }
```

After reading the data from the server, the socket creats a `std::string` from the input and calls `check_input` on this. Depending on the result of the check the program sends either `Authentication failed` or `Sent authentication success message.` back to the server (hopefully along with the flag..).

```c
00408541         *(uint64_t*)0x2f3124ca = 0x2f3124b9;
0040856b         std::string::ctor(0x2f312502, 0x2f312522, 
0040856b             (int64_t)*(uint32_t*)0x2f3124c6);
0040858a         char rax_18;
0040858a         int64_t rcx_3;
0040858a         int64_t rdx_1;
0040858a         int64_t rsi_2;
0040858a         int64_t r8_1;
0040858a         int64_t r9_1;
0040858a         int64_t r10_1;
0040858a         int64_t r11_1;
0040858a         rax_18 = check_input(0x2f312502);
0040858a         
00408591         if (!rax_18)
004085f3             sub_468ce0(std::cout(&data_5f1aa0, "Authentication failed."), 
004085f3                 sub_469d50, sub_469d50);
00408591         else
00408591         {
00408593             uint64_t client_socket_1 =
00408593                 (uint64_t)(*(uint32_t*)client_socket);
0040859b             int64_t r12;
0040859b             int64_t r14;
0040859b             j_sub_a41e19((uint64_t)client_socket_1, rsi_2, rdx_1, rcx_3, 
0040859b                 r8_1, r9_1, client_socket_1, arg4, 0x2f312942, r10_1, 
0040859b                 r11_1, r12, r14);
004085c6             sub_468ce0(
004085c6                 std::cout(&data_5f1bc0, 
004085c6                     "Sent authentication success mess…"), 
004085c6                 sub_469d50, sub_469d50);
00408591         }
00408591         
00408600         close((*(uint32_t*)client_socket));
00408605         rbx = 0;
00408614         std::string::dtor(0x2f312502);
```

Check input doesn't contain too much logic. It only loads the assumed credentials and compares the input from the server.

```c
00407f8f    uint64_t check_input(int64_t* arg1)
00407f8f    {
00407f8f        void* fsbase;
00407f9c        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00407fb2        void var_48;
00407fb2        load_credentials(&var_48);
00407fc5        int32_t rax_2 = compare_credentials(arg1, &var_48);
00407fd4        std::string::dtor(&var_48);
00407fdf        *(uint64_t*)((char*)fsbase + 0x28);
00407fdf        
00407fe8        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
00407ff4            return (uint64_t)rax_2;
00407ff4        
00407fea        sub_545bf0();
00407fea        /* no return */
00407f8f    }
```

So the final piece of the puzzle is the loaded credentials. This function is not looking to bad, it's loading some `s3cr3t` value and performing a bit of xor magic on it. Anyways, since we know the program is keeping the value in memory, we also can just read it from there without going too deep into the logic.

```c
00407d45    int64_t* load_credentials(int64_t* arg1)
00407d45    {
00407d45        void* fsbase;
00407d58        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00407d6b        void var_88;
00407d6b        void* var_78 = &var_88;
00407d86        void var_68;
00407d86        std::string::ctor(&var_68, "s3cr3t");
00407d9f        void var_a6;
00407d9f        void* var_70 = &var_a6;
00407db3        sub_47d570(&var_88, &var_68);
00407dc9        void var_90;
00407dc9        sub_47d530(&var_90, &var_68);
00407de7        void var_48;
00407de7        sub_408900(&var_48, &var_90, &var_88);
00407dfc        int32_t var_a4 = 3;
00407e06        int32_t var_a0 = 0x5a;
00407e1a        std::string::ctor(arg1);
00407e1f        int64_t var_80 = 0;
00407e1f        
00407eb4        while (true)
00407eb4        {
00407eb4            int64_t rax_17;
00407eb4            rax_17 = var_80 < sub_47d5e0(&var_48);
00407eb4            
00407eb9            if (!rax_17)
00407eb9                break;
00407eb9            
00407e45            int32_t rax_4 = var_80;
00407e9a            sub_47db80(arg1, 
00407e9a                (*(uint8_t*)std::string::operator[](&var_48, var_80)
00407e9a                    ^ ((char)(rax_4 << 5) - rax_4 + 7) ^ 0x5a) + 3);
00407e9f            var_80 += 1;
00407eb4        }
00407eb4        
00407ec6        std::string::dtor(&var_48);
00407ed2        std::string::dtor(&var_68);
00407edc        *(uint64_t*)((char*)fsbase + 0x28);
00407edc        
00407ee5        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
00407f8e            return arg1;
00407f8e        
00407f7d        sub_545bf0();
00407f7d        /* no return */
00407d45    }
```

To do this, we load the program with `GDB` and set a breakpoint at `00407fc5`.

```bash
$ gdb ./outerspace
pwndbg> starti
pwndbg> break *0x00407fc5
Breakpoint 1 at 0x407fc5
pwndbg> c
Continuing.
Enter server IP address:
```

Of course, we need a server the program can communicate with. So we can use netcat to set up something real quick.

```bash
$ echo "Hello" | nc -lvnp 12345
listening on [any] 12345 ...
```

Let's continue in `gdb`:

```bash
Enter server IP address: 127.0.0.1
Connected to server.
...
──────────────────────────────────────────[ DISASM / x86-64 / set emulate on ]──────────────────────────────────────────
 ► 0x407fc5    call   0x4089e9                      <0x4089e9>

   0x407fca    mov    ebx, eax
   0x407fcc    nop
   0x407fcd    lea    rax, [rbp - 0x40]
   0x407fd1    mov    rdi, rax
   0x407fd4    call   0x47d3b0                      <0x47d3b0>

   0x407fd9    mov    eax, ebx
   0x407fdb    mov    rdx, qword ptr [rbp - 0x18]
   0x407fdf    sub    rdx, qword ptr fs:[0x28]
   0x407fe8    je     0x407fef                      <0x407fef>

   0x407fea    call   0x545bf0                      <0x545bf0>
───────────────────────────────────────────────────────[ STACK ]────────────────────────────────────────────────────────
00:0000│ rsp     0x7fffffffd6d0 —▸ 0x5f1bc0 —▸ 0x5e9c20 —▸ 0x468970 ◂— endbr64
01:0008│         0x7fffffffd6d8 —▸ 0x7fffffffd780 —▸ 0x7fffffffd790 ◂— 0xa6f6c6c6548 /* 'Hello\n' */
02:0010│ rdx rsi 0x7fffffffd6e0 —▸ 0x7fffffffd6f0 ◂— 0x8eed6070522c
03:0018│         0x7fffffffd6e8 ◂— 0x6
04:0020│         0x7fffffffd6f0 ◂— 0x8eed6070522c
05:0028│         0x7fffffffd6f8 —▸ 0x7fffffffd7a6 ◂— 0x0
06:0030│         0x7fffffffd700 —▸ 0x7fffffffd780 —▸ 0x7fffffffd790 ◂— 0xa6f6c6c6548 /* 'Hello\n' */
07:0038│         0x7fffffffd708 ◂— 0xc9db620a6f8baf00
─────────────────────────────────────────────────────[ BACKTRACE ]──────────────────────────────────────────────────────
 ► 0         0x407fc5
   1         0x40858f
   2         0x4dbd18
   3         0x4de030
   4         0x407c45
```

We can see our input on the stack and `rsi` pointing to the authentication result (`0x8eed6070522c` or `\x2c\x52\x70\x60\xed\x8e` when converted to bytes). To test this out we set up our server to send this string back after the client connects.

```bash
$ printf '\x2c\x52\x70\x60\xed\x8e' | nc -lnvp 12345
listening on [any] 12345 ...
```

Then running the client.

```bash
$ ./outerspace
Enter server IP address: 127.0.0.1
Connected to server.
Sent authentication success message.
```

This looks promising, checking back at the server we find the flag.

```bash
connect to [127.0.0.1] from (UNKNOWN) [127.0.0.1] 36802
CIT{I7T7tE3G4x5Cb2}
```

Flag `CIT{I7T7tE3G4x5Cb2}`