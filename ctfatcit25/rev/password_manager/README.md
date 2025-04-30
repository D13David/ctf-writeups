# CTF@CIT 2025

## This custom password manager should keep all my accounts super secure!

> Here we go!
>
>  Author: ronnie
>
> [`passwordmanager`](passwordmanager)

Tags: _rev_

## Solution
The challenge comes with a stripped binary. After finding the main function (at `00408767`) and a bit of cleanup for relatively obvious functions we have this code to look at (mind it's not actually `print` or `input` but probably more like `ostream::operator<<` and `istream::operator>>`, but for semantics and readability we keep it simple).

```c
00408767    void main() __noreturn
00408767    {
00408767        int32_t rdi;
00408770        int32_t var_5c = rdi;
00408773        int64_t rsi;
00408773        int64_t var_68 = rsi;
00408780        void* fsbase;
00408780        int64_t var_20 = *(uint64_t*)((char*)fsbase + 0x28);
00408780        
004087ac        while (true)
004087ac        {
004087ac            sub_468620(print(&stdout, "Welcome to my password manager!\n…"), 
004087ac                sub_469690, sub_469690);
004087ac            
004087ba            if (g_IsAuthenticated)
004087f5                sub_468620(print(print(&stdout, "Authenticated as: "), sub_545880()), 
004087f5                    sub_469690, sub_469690);
004087f5            
004087fe            void var_51;
004087fe            void* var_50_1 = &var_51;
00408819            void var_48;
00408819            std::string::ctor(&var_48, &data_5a9178);
0040883c            input(&data_612d00, &var_48);
0040883c            
00408859            if (!operator==(&var_48, u"1234"))
00408859            {
00408883                if (!operator==(&var_48, &data_5a9179[1]))
00408883                {
004088a6                    if (!operator==(&var_48, &data_5a9179[2]))
004088a6                    {
004088c7                        if (operator==(&var_48, &data_5a9179[3]))
004088ef                            sub_468620(print(&stdout, "ERROR_NOT_AUTHENTICATED"), 
004088ef                                sub_469690, sub_469690);
004088a6                    }
004088a6                    else
004088a8                        read_password();
00408883                }
00408883                else
00408885                    g_IsAuthenticated = 0;
00408859            }
00408859            else
00408860                g_IsAuthenticated = authenticateUser();
00408860            
004088fb            std::string::dtor(&var_48);
004087ac        }
00408767    }
```

The program prints a menu with four options (`1. login` `2. log out` `3. read a password` `4. write a password`) and reads input from the user. The function to write a password is not implemented but will only print `ERROR_NOT_AUTHENTICATED`, no matter if the user is authenticated or not. The functionality for Log-Out will only set a global flag to `false`, so there are two functions left that may be interesting.

```c
004082d0    uint64_t authenticateUser()

004082d0    {
004082d0        void* fsbase;
004082d9        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
004082ec        void var_51;
004082ec        void* var_50 = &var_51;
00408308        void var_48;
00408308        std::string::ctor(&var_48, sub_545880());
00408332        int32_t rbx;
00408332        
00408332        if (!operator==(&var_48, "ronnie"))
0040833b            rbx = 0;
00408332        else
00408334            rbx = 1;
00408334        
00408347        std::string::dtor(&var_48);
00408352        *(uint64_t*)((char*)fsbase + 0x28);
00408352        
0040835b        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
004083c6            return (uint64_t)rbx;
004083c6        
004083bc        sub_5456b0();
004083bc        /* no return */
004082d0    }
```

As for authentication `sub_545880` loads a string that is compared with `ronnie` which seems to be the only user that is allowed to login. `sub_545880` is rather complicated, reading from `/proc/self/loginuid`.

```c
00545a80    uint64_t sub_545a80(int64_t arg1, int64_t arg2)

00545a80    {
00545a80        void* fsbase;
00545aaf        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00545abe        int32_t file = openat("/proc/self/loginuid", 0);
00545ac6        int32_t rcx_1;
00545ac6        
00545ac6        if (file != 0xffffffff)
00545ac6        {
00545af3            while (true)
00545af3            {
00545af3                char buffer[0xc];
00545af3                int64_t bytes_read = read(file, &buffer, 0xc);
00545af8                int64_t bytes_read_1 = bytes_read;
00545af8                
00545aff                if (bytes_read != -1)
00545aff                {
00545b06                    int64_t r13;
00545b06                    r13 = bytes_read <= 0;
00545b0e                    bytes_read = bytes_read == 0xc;
00545b14                    close(file);
///...
```

Whatever the function does, it fails and causes a `SIGABRT` with `basic_string: construction from null is not valid`. Anyways... We can just try to patch out the functionality, we already know the login flag is stored at `00611cd0`. Also the username is printed in the menu, it is read by `sub_545880` and stored in `data_619c00`.

```c
//... main
004087ba            if (g_IsAuthenticated)
004087f5                sub_468620(print(print(&stdout, "Authenticated as: "), sub_545880()), 
004087f5                    sub_469690, sub_469690);
// ...

00545880    void* sub_545880()
00545880    {
00545880        int32_t rax = sub_545a80(&data_619c00, 0x21);
00545880        
005458a3        if (rax < 0)
005458bd            /* tailcall */
005458bd            return sub_545780();
005458bd        
005458aa        if (!rax)
005458aa            return &data_619c00;
005458aa        
005458b3        return nullptr;
00545880    }
```

We can just patch the login functionality completely out and set `al` to `1` so the global flag is set to `true` when the user chooses the `log-in` option.

```c
; original
0040885b  e870faffff         call    authenticateUser
00408860  88056a942000       mov     byte [rel g_IsAuthenticated], al
00408866  e989000000         jmp     0x4088f4

; patched
0040885b  90                 nop     
0040885c  90                 nop     
0040885d  90                 nop     
0040885e  b001               mov     al, 0x1
00408860  88056a942000       mov     byte [rel g_IsAuthenticated], al  {0x1}
00408866  e989000000         jmp     0x4088f4
```

The second part is the username (which is stored in `data_619c00` and read by `sub_545880`). We patch the function so that is returns `data_5a9030` instead of the username buffer, as `5a9030` stores the constant `ronnie` that was used for comparison while logging in.

```c
; original
00545880    void* sub_545880()

00545880  f30f1efa           endbr64 
00545884  55                 push    rbp {__saved_rbp}
00545885  be21000000         mov     esi, 0x21
0054588a  4889e5             mov     rbp, rsp {__saved_rbp}
0054588d  53                 push    rbx {__saved_rbx}
0054588e  488d1d6b430d00     lea     rbx, [rel data_619c00]
00545895  4889df             mov     rdi, rbx  {data_619c00}
00545898  4883ec08           sub     rsp, 0x8
0054589c  e8df010000         call    sub_545a80
005458a1  85c0               test    eax, eax
005458a3  7813               js      0x5458b8

005458a5  b800000000         mov     eax, 0x0
005458aa  480f44c3           cmove   rax, rbx  {data_619c00}
005458ae  488b5df8           mov     rbx, qword [rbp-0x8 {__saved_rbx}]
005458b2  c9                 leave    {__saved_rbp}
005458b3  c3                 retn     {__return_addr}

; patched
00545880    int64_t sub_545880() __pure

00545880  f30f1efa           endbr64 
00545884  55                 push    rbp {__saved_rbp}
00545885  be21000000         mov     esi, 0x21
0054588a  4889e5             mov     rbp, rsp {__saved_rbp}
0054588d  53                 push    rbx {__saved_rbx}
0054588e  488d1d9b370600     lea     rbx, [rel data_5a9030]
00545895  90                 nop     
; more nops
005458a9  90                 nop     
005458aa  4889d8             mov     rax, rbx  {data_5a9030, "ronnie"}
005458ad  90                 nop     
005458ae  488b5df8           mov     rbx, qword [rbp-0x8 {__saved_rbx}]
005458b2  c9                 leave    {__saved_rbp}
005458b3  c3                 retn     {__return_addr}

```c
0040863f    int64_t read_password()
0040863f    {
0040863f        void* fsbase;
00408648        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
0040865e        void account_name;
0040865e        std::string::ctor(&account_name);
00408677        print(&stdout, "Account name: ");
0040868d        input(&data_612d00, &account_name);
004086b8        int64_t* rax_2 = print(print(&stdout, &account_name), " password: ");
004086ce        void password;
004086ce        load_password_for_account(&password, &account_name);
004086ef        sub_468620(print(rax_2, &password), sub_469690, sub_469690);
004086fb        std::string::dtor(&password);
00408707        std::string::dtor(&account_name);
00408707        
00408719        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
00408766            return rax - *(uint64_t*)((char*)fsbase + 0x28);
00408766        
0040875c        sub_5456b0();
0040875c        /* no return */
0040863f    }
```

After doing this, we can login successfully (without crash) as `ronnie`.

```bash
Welcome to my password manager!
Please select an option below
=========================
1. log in
2. log out
3. read a password
4. save a password
=========================
1
Welcome to my password manager!
Please select an option below
=========================
1. log in
2. log out
3. read a password
4. save a password
=========================
Authenticated as: ronnie
```

The remaining part is `read_password`. First the program prompts the user for an `account name`. Then the password is loaded and printed to `stdout`.

```c
0040863f    int64_t read_passord()

0040863f    {
0040863f        void* fsbase;
00408648        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
0040865e        void account_name;
0040865e        std::string::ctor(&account_name);
00408677        print(&stdout, "Account name: ");
0040868d        input(&data_612d00, &account_name);
004086b8        int64_t* rax_2 = print(print(&stdout, &account_name), " password: ");
004086ce        void password;
004086ce        lookup_password_for_account(&password, &account_name);
004086ef        sub_468620(print(rax_2, &password), sub_469690, sub_469690);
004086fb        std::string::dtor(&password);
00408707        std::string::dtor(&account_name);
00408707        
00408719        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
00408766            return rax - *(uint64_t*)((char*)fsbase + 0x28);
00408766        
0040875c        sub_5456b0();
0040875c        /* no return */
0040863f    }
```

The password lookup function contains some fairly complex logic. 

```c
004083c7    int64_t* lookup_password_for_account(int64_t* account_key, int64_t* account_name)

004083c7    {
/// ...
0040841b        std::string::ctor(&alphabet, "abcdefghijklmnopqrstuvwxyzABCDEF…");
00408430        int64_t var_1428 = 0x10;
00408471        void var_1431;
00408471        void var_13a8;
00408471        sub_408c92(&var_13a8, sub_408c4a(&var_1431, account_name));
00408499        sub_408cb8(&var_1410, 0, sub_47cf20(&alphabet) - 1);
004084a8        std::string::ctor(account_key);
004084a8        
// ...
```

First off, it calls to `sub_408c4a` with the account name. This turns out to create a `MurmurHash`, we find this by looking up some constants we find (e.g. `0xc6a4a7935bd1e995`) in functions down the road. The algorithm works on 64 bit blocks, just like [`this`](https://github.com/abrandoned/murmur2/blob/5eccf83ccaa20a756d36f0688ac8b4fa94b09737/MurmurHash2.c#L74) implementation. We can verify this by calculating the hash ourself for some input with the seed `0xc70f6907`.

```c
00408c4a    int64_t sub_408c4a(int64_t value, int64_t* arg2)

00408c4a    {
00408c4a        int64_t value_1 = value;
00408c62        int64_t length = std::string::length(arg2);
00408c91        return MurmurHash64A(std::string::c_str(arg2), length, 0xc70f6907);
00408c4a    }
// ...
0040a380    int64_t sub_40a380(int64_t* arg1, int64_t arg2, int64_t arg3)

0040a380    {
0040a380        int64_t* rcx = arg1;
0040a3a2        void* r9_2 = (arg2 & 0xfffffffffffffff8) + arg1;
0040a3a5        int64_t r8_2 = (arg2 * 0xc6a4a7935bd1e995) ^ arg3;
// ..
```

The result is then passed into `sub_408c92` which in turns out (given away by constants again) to initialize a [`Mersenne Twister PRNG`](https://de.wikipedia.org/wiki/Mersenne-Twister).

```c
00408ec6    uint64_t* sub_408ec6(uint64_t* arg1, int32_t arg2)

00408ec6    {
00408ec6        *(uint64_t*)arg1 = sub_409121(arg2);
00408ec6        
00408f57        for (int64_t i = 1; i <= 0x26f; i += 1)
00408f57        {
00408f57            int64_t rax_4 = arg1[i - 1];
00408f46            arg1[i] = sub_409121((rax_4 ^ (int32_t)(rax_4 >> 0x1e)) * 0x6c078965
00408f46                + sub_40913b(i));
00408f57        }
00408f57        
00408f5d        arg1[0x270] = 0x270;
00408f6a        return arg1;
00408ec6    }
```

Back to `load_password_for_account`. The program then builds a key based on calculating random numbers in range of the alphabet length. This means we need to find a valid username. 

```c
// ...
00408471        InitMersenneTwister(&rnd, MurmurHash(&value, account_name));
00408499        SetRange(&var_1410, 0, sub_47cf20(&alphabet) - 1);
004084a8        std::string::ctor(account_key);
004084a8        
0040850f        for (int64_t i = 0; i <= 0xf; i += 1)
0040850f            string::operator+(account_key, 
0040850f                *(uint8_t*)string::operator[](&alphabet, 
0040850f                    (int64_t)sub_408ce2(&var_1410, &rnd)));
// ...
```

The sad thing, we don't have very many information. We don't know the target key and even if, it would be not enough information to reproduce the initial state of the `Mersenne Twister`. One thing that *can* be done would to brute force the 32 bit seed range for the `PRNG`. With some luck we can start at `0x7fffffff`, throw a coin and work our way up or down to half the runtime (with 50 percent chance we choose the right direction). To spare the time to start a process we can patch the `MurmurHash` function to decrement the seed on every call and the seed we can store in the, now unused, `username` storage at `data_619c00`.

```c
; before patching
00408c4a    int64_t MurmurHash(int64_t value, int64_t* arg2)

00408c4a  55                 push    rbp {__saved_rbp}
00408c4b  4889e5             mov     rbp, rsp {__saved_rbp}
00408c4e  53                 push    rbx {__saved_rbx}
00408c4f  4883ec18           sub     rsp, 0x18
00408c53  48897de8           mov     qword [rbp-0x18 {value_1}], rdi
00408c57  488975e0           mov     qword [rbp-0x20 {var_28}], rsi
00408c5b  488b45e0           mov     rax, qword [rbp-0x20 {var_28}]
00408c5f  4889c7             mov     rdi, rax
00408c62  e8c9420700         call    std::string::length
00408c67  4889c3             mov     rbx, rax
00408c6a  488b45e0           mov     rax, qword [rbp-0x20 {var_28}]
00408c6e  4889c7             mov     rdi, rax
00408c71  e85a600700         call    std::string::c_str
00408c76  4889c1             mov     rcx, rax
00408c79  b807690fc7         mov     eax, 0xc70f6907
00408c7e  4889c2             mov     rdx, rax  {0xc70f6907}
00408c81  4889de             mov     rsi, rbx
00408c84  4889cf             mov     rdi, rcx
00408c87  e8ebfdffff         call    MurmurHash64A
00408c8c  488b5df8           mov     rbx, qword [rbp-0x8 {__saved_rbx}]
00408c90  c9                 leave    {__saved_rbp}
00408c91  c3                 retn     {__return_addr}

; after patching
00408c4a    int64_t MurmurHash()

00408c4a  55                 push    rbp {__saved_rbp}
00408c4b  4889e5             mov     rbp, rsp {__saved_rbp}
00408c4e  53                 push    rbx {var_10}
00408c4f  4883ec18           sub     rsp, 0x18
00408c53  8b1da70f2100       mov     ebx, dword [rel data_619c00]
00408c59  ffc3               inc     ebx
00408c5b  891d9f0f2100       mov     dword [rel data_619c00], ebx
00408c61  b8ffffff7f         mov     eax, 0x7fffffff
00408c66  29d8               sub     eax, ebx
00408c62  90                 nop     
00408c63  90                 nop     
// ... more nops   
00408c8f  90                 nop     
00408c90  c9                 leave    {__saved_rbp}
00408c91  c3                 retn     {__return_addr}
```

Now every time we read a password the seed increments by one. We have just to keep reading for hours and hours till our flag pops up:

```py
from pwn import *

p = process("./pw")

p.sendline(b"1")                    # login

while True:
    p.sendline(b"3")                # read password
    p.sendline(b"x")                # account name, we don't care about the name now

    # check if we finally found our password
    p.recvuntil(b"x password: ")
    password = p.recvline()
    if b"CIT{" in password:
        print(password)
        break
```

Orrrr, we start guessing again and try some obvious values for the account, like... `flag`. Either way, we get the flag.

Flag `CIT{HTfzGHhJ7YrM}`