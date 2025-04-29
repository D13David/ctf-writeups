# CTF@CIT 2025

## Baby Keygen

> I didn't strip this one you're welcome
>
>  Author: ronnie
>
> [`babykeygen`](babykeygen)

Tags: _rev_

## Solution
The challenge comes with a binary we open in `BinaryNinja`. The main function is rather short. The program reads a key from `stdin` and calls `check_key` on the input.

```c
00407ff5    int64_t main()
00407ff5    {
00407ff5        void* fsbase;
00407ffe        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00408014        std::string::string();
0040802d        std::operator<<<std::char_traits<char> >(&std::cout, "Enter key: ");
00408043        void var_68;
00408043        std::getline<char>(&std::cin, &var_68);
00408056        void var_48;
00408056        std::string::string(&var_48);
00408062        check_key(&var_48);
0040806e        std::string::~string();
0040807f        std::string::~string();
0040808a        *(uint64_t*)((char*)fsbase + 0x28);
0040808a        
00408093        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
004080e0            return 0;
004080e0        
004080d6        __stack_chk_fail();
004080d6        /* no return */
00407ff5    }
```

So `check_key` is where the interesting things happen. Lets have a look. First thing we note, the input is assumed to be 16 bytes wide. `BinaryNinja` doesn't do the best job here to resolve the original c++ code, but as a starting point it's fine. 

```c
00407e81    int64_t check_key(std::string arg1)
00407e81    {
00407e81        uint64_t var_60 = arg1;
00407e8e        void* fsbase;
00407e8e        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00407ead        int64_t rax_2;
00407ead        rax_2 = std::string::length() != 0x10;
00407ead        
00407eb2        if (!rax_2)
00407eb2        {
00407ed3            void var_48;
00407ed3            std::string::substr(&var_48, var_60);
00407ee9            bool rax_4 = std::operator!=<char>(&var_48, "KEY_");
00407ef7            std::string::~string();
00407ef7            
00407efe            if (!rax_4)
00407efe            {
00407f07                int64_t var_50_1 = 4;
00407f07                
00407f4b                while (true)
00407f4b                {
00407f4b                    if (var_50_1 > 0xf)
00407f4b                    {
00407f5b                        std::string::string(&var_48);
00407f67                        validate(&var_48);
00407f73                        std::string::~string();
00407f78                        break;
00407f4b                    }
00407f4b                    
00407f33                    int32_t rax_10;
00407f33                    rax_10 = !isalnum((int32_t)*(uint8_t*)std::string::operator[](var_60));
00407f33                    
00407f38                    if (rax_10)
00407f38                        break;
00407f38                    
00407f41                    var_50_1 += 1;
00407f4b                }
00407efe            }
00407eb2        }
00407eb2        
00407f81        *(uint64_t*)((char*)fsbase + 0x28);
00407f81        
00407f8a        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
00407ff4            return 0;
00407ff4        
00407fea        __stack_chk_fail();
00407fea        /* no return */
00407e81    }
```

The next line illustrates this: `std::string::substr(&var_48, var_60);`. If we look at the disassembly instead things are more clear. We can see the code copies the first 4 characters, which matches also the following tests for `KEY_`.

```c
00407ebe  488d45c0           lea     rax, [rbp-0x40 {var_48}]
00407ec2  488b75a8           mov     rsi, qword [rbp-0x58 {var_60}]
00407ec6  b904000000         mov     ecx, 0x4       ; count = 4
00407ecb  ba00000000         mov     edx, 0x0       ; pos = 0
00407ed0  4889c7             mov     rdi, rax {var_48}
00407ed3  e8086f0600         call    std::string::substr
```

Ok, what do we have by now? The key is prefixed with `KEY_` and is 16 chars in total, meaning 12 chars we don't know yet. The following loop iterates over the remaining 12 characters and checks that all of them are [`alphanumeric`](https://en.cppreference.com/w/cpp/string/byte/isalnum).

Interestingly the key generator is not very strict in what key's it accepts. We can enter any 12 characters (which are alphanumeric) and will get the flag in return.

```bash
$ ./babykeygen
Enter key: KEY_0123456789XX
CIT{41jN8BKzz388}
```

Flag `CIT{41jN8BKzz388}`