# CTF@CIT 2025

## Ask Nicely

> I made this program, you just have to ask really nicely for the flag!
>
>  Author: ronnie
>
> [`asknicely`](asknicely)

Tags: _rev_

## Solution
This challenge is a bit more tricky than [`Read Only`](../read_only/README.md), looking up strings doesn't easily work here. So we have to actually look into the logic of the program, for this we load the binary into `BinaryNinja`.

```c
00407d96    int64_t main()
00407d96    {
00407d96        void* fsbase;
00407d9f        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00407dd4        std::ostream::operator<<(std::operator<<<std::char_traits<char> >(&std::cout, 
00407dd4            "How badly do you want the flag?"));
00407de0        std::string::string();
00407df6        void var_68;
00407df6        std::getline<char>(&std::cin, &var_68);
00407e21        std::ostream::operator<<(std::operator<<<std::char_traits<char> >(&std::cout, 
00407e21            "Ask nicely..."));
00407e37        std::getline<char>(&std::cin, &var_68);
00407e37        
00407e54        if (!std::operator==<char>(&var_68, "pretty pretty pretty pretty pret…"))
00407ed4            std::ostream::operator<<(std::operator<<<std::char_traits<char> >(&std::cout, 
00407ed4                "that's not quite what I'm lookng…"));
00407e54        else
00407e54        {
00407e7c            std::ostream::operator<<(std::operator<<<std::char_traits<char> >(&std::cout, 
00407e7c                "Good job, I'm so proud of you!"));
00407e8f            void var_48;
00407e8f            std::string::string(&var_48);
00407e9b            give_flag(&var_48);
00407ea7            std::string::~string();
00407e54        }
00407e54        
00407ee5        std::string::~string();
00407ef0        *(uint64_t*)((char*)fsbase + 0x28);
00407ef0        
00407ef9        if (rax == *(uint64_t*)((char*)fsbase + 0x28))
00407f46            return 0;
00407f46        
00407f3c        __stack_chk_fail();
00407f3c        /* no return */
00407d96    }
```

The main function reads a line from `stdio` but doesn't process it any further. Instead the program outputs `Ask nicely...` and reads another line. The second input is compared to `pretty pretty pretty pretty pretty please with sprinkles and a cherry on top` which in turn will branch into a block that calls `give_flag`.

Running the program gives the flag.

```bash
$ ./asknicely
How badly do you want the flag?
not too badly
Ask nicely...
pretty pretty pretty pretty pretty please with sprinkles and a cherry on top
Good job, I'm so proud of you!
CIT{2G20kX09yF3F}
```

Flag `CIT{}`