# CTF@CIT 2025

## Secure Keygen

> I made this keygen I hope u like it :)
>
>  Author: ronnie
>
> [`securekeygen`](securekeygen)

Tags: _rev_

## Solution
This is a follow up for [`Baby Keygen`](../baby_keygen/README.md). But this time things are a bit more *secure*, starting with the binary being stripped. Nevertheless, we find the `main` method.

```c
0040804d    int64_t sub_40804d()
00408056        void* fsbase
00408056        int64_t rax = *(fsbase + 0x28)
0040806c        void var_68
0040806c        sub_47a840(&var_68)
00408085        sub_467a60(&data_5f1ba0, "Enter key: ")
0040809b        sub_47deb0(&data_5f1cc0, &var_68)
004080ae        void var_48
004080ae        sub_47d9b0(&var_48, &var_68)
004080ba        sub_407eea(&var_48)
004080c6        sub_47aab0(&var_48)
004080d7        sub_47aab0(&var_68)
004080e2        *(fsbase + 0x28)
004080e2        
004080eb        if (rax == *(fsbase + 0x28))
00408138            return 0
00408138        
0040812e        sub_545710()
0040812e        noreturn
```

With the binary being stripped (any symbols are missing) we have to do some educated guesses and start renaming things:

```c
0040806c        std::string::ctor(&user_input);
00408085        std::cout(&stdout, "Enter key: ");
0040809b        std::cin(&stdin, &user_input);
004080ae        void var_48;
004080ae        sub_47d9b0(&var_48, &user_input);
004080ba        check_key(&var_48);
004080c6        std::string::dtor(&var_48);
004080d7        std::string::dtor(&user_input);
```

Let's move on with the `check_key` function. The function first concatenates the user input with a `KEY_` prefix and then calls `sub_40953c` on this. For the result the program then checks the first three characters to have the value `'0'`. 

```c
00407eea    int64_t check_key(int64_t* arg1)
00407eea    {
00407eea        int64_t rbx;
00407eee        int64_t var_10 = rbx;
00407efd        void* fsbase;
00407efd        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00407f24        void var_88;
00407f24        std::string::operator+(&var_88, "KEY_", arg1);
00407f37        void var_68;
00407f37        sub_40953c(&var_68, &var_88);
00407f52        char rax_7;
00407f52        
00407f52        if (*(uint8_t*)std::string::operator[](&var_68, 0) != '0')
00407f8b            rax_7 = 0;
00407f52        else if (*(uint8_t*)std::string::operator[](&var_68, 1) != '0')
00407f8b            rax_7 = 0;
00407f6a        else if (*(uint8_t*)std::string::operator[](&var_68, 2) != '0')
00407f8b            rax_7 = 0;
00407f82        else
00407f84            rax_7 = 1;
00407f84        
00407f92        if (rax_7)
00407f92        {
00407fa5            void var_48;
00407fa5            int64_t rcx_1;
00407fa5            int64_t rdx_2;
00407fa5            int64_t rsi_2;
00407fa5            int64_t* r8_1;
00407fa5            int64_t r9_1;
00407fa5            int64_t r10_1;
00407fa5            int64_t r11_1;
00407fa5            rcx_1 = sub_47d9b0(&var_48, arg1);
00407fb1            int64_t __saved_rbp;
00407fb1            int64_t r12;
00407fb1            int64_t r13;
00407fb1            int64_t r14;
00407fb1            int64_t r15;
00407fb1            j_sub_bd19ae(&var_48, rsi_2, rdx_2, rcx_1, r8_1, r9_1, &var_48, rbx, 
00407fb1                &__saved_rbp, r10_1, r11_1, r12, r13, r14, r15);
00407fbd            std::string::dtor(&var_48);
00407f92        }
00407f92        
00407fce        std::string::dtor(&var_68);
00407fda        std::string::dtor(&var_88);
00407fe5        *(uint64_t*)((char*)fsbase + 0x28);
00407fe5        
00407fee        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
0040804c            return 0;
0040804c        
00408042        sub_545710();
00408042        /* no return */
00407eea    }
```

One missing thing is function `sub_40953c`. As things are getting quickly pretty annoying with statically reversing stripped binaries, we take a good shot and try to run the program in a debugger, just to see what the function returns to us.

What we want to do is to set a breakpoint right after the function returns. For instance `0x00407f3c` is a good fit.

```bash
$ gdb ./securekeygen
pwndbg> starti
...
pwndbg> break *0x00407f3c
Breakpoint 1 at 0x407f3c
pwndbg> c
Continuing.
Enter key: abcdef
...
──────────────────────────────────────────[ DISASM / x86-64 / set emulate on ]──────────────────────────────────────────
 ► 0x407f3c    lea    rax, [rbp - 0x60]
   0x407f40    mov    esi, 0
   0x407f45    mov    rdi, rax
   0x407f48    call   0x47b040                      <0x47b040>

   0x407f4d    movzx  eax, byte ptr [rax]
   0x407f50    cmp    al, 0x30
   0x407f52    jne    0x407f8b                      <0x407f8b>

   0x407f54    lea    rax, [rbp - 0x60]
   0x407f58    mov    esi, 1
   0x407f5d    mov    rdi, rax
   0x407f60    call   0x47b040                      <0x47b040>
───────────────────────────────────────────────────────[ STACK ]────────────────────────────────────────────────────────
00:0000│ rsp 0x7fffffffda90 —▸ 0x7fffffffdb30 —▸ 0x7fffffffdb40 ◂— 0x666564636261 /* 'abcdef' */
01:0008│     0x7fffffffda98 —▸ 0x7fffffffdb50 —▸ 0x7fffffffdb60 ◂— 0x666564636261 /* 'abcdef' */
02:0010│     0x7fffffffdaa0 —▸ 0x7fffffffdab0 ◂— 'KEY_abcdef'
03:0018│     0x7fffffffdaa8 ◂— 0xa /* '\n' */
04:0020│     0x7fffffffdab0 ◂— 'KEY_abcdef'
05:0028│     0x7fffffffdab8 ◂— 0xafefdfcfb006665 /* 'ef' */
06:0030│ rax 0x7fffffffdac0 —▸ 0xe5b370 ◂— '7726baaa2f52daf69394ccc3cb8ecb804b05a1d630140e5c97f176c6a0eb6596'
07:0038│     0x7fffffffdac8 ◂— 0x40 /* '@' */
─────────────────────────────────────────────────────[ BACKTRACE ]──────────────────────────────────────────────────────
 ► 0         0x407f3c
   1         0x4080bf
   2         0x4db458
   3         0x4dd770
   4         0x407ac5
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
pwndbg>
```

We can see the value right on the stack where `rax` is pointing (0x7fffffffdac0). The result looks suspiciously like a hash, a `sha256` hash to be specific. To verify this we test to hash `KEY_abcdef` ourself.

```bash
$ echo -n "KEY_abcdef" | sha256sum
7726baaa2f52daf69394ccc3cb8ecb804b05a1d630140e5c97f176c6a0eb6596  -
```

Looks good. So we need to find a `key` which produces a hash that starts with `000`. This should be easy enough, we just write a tiny python script that finds us such a key:

```py
import hashlib

num = 0
while True:
    key = f"KEY_{num}"
    hash_hex = hashlib.sha256(key.encode()).hexdigest()
    if hash_hex.startswith("000"):
        print(f"Found match: {num} -> {hash_hex}")
        exit()
    num += 1
```

Running this script gives us quickly a matching input:

```bash
$ python foo.py
Found match: 299 -> 00077f28a95588d146a349d513255e4b634eb4676aa5d3e9fb23851abd0d4e72
```

Entering this number is key gives us the flag.

```bash
$ ./securekeygen
Enter key: 299
CIT{w4tUcLj95fpq}
```

Flag `CIT{w4tUcLj95fpq}`