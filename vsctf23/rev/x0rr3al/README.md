# vsCTF 2023

## x0rr3al?!!

> Are you being x0rr3al with me right now?!
>
>  Author: neil
>
> [`x0rr3al`](x0rr3al)

Tags: _rev_

## Solution
For this challenge we are provided with a binary to reverse. Opening the binary with some decompiler (`BinaryNinja` via [`dogbolt`](https://dogbolt.org/) in my case) gives us the following `main`. 

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    void* fsbase;
    int64_t rax = *(fsbase + 0x28);
    if (sub_17a4() != 0)
    {
        sub_16ad();
        exit(1);
        /* no return */
    }
    if (ptrace(PTRACE_TRACEME, 0, 1, 0) == -1)
    {
        sub_16ad();
        exit(1);
        /* no return */
    }
    int32_t rax_7 = sub_1483(main, 0x200);
    sub_1355();
    sub_13f8();
    if (rax_7 != sub_1483(main, 0x200))
    {
        sub_16ad();
        exit(1);
        /* no return */
    }
    printf("p4ss m3 th3 fl4g: ");
    void var_48;
    __isoc99_scanf("%53s", &var_48);
    if (strlen(&var_48) != 0x35)
    {
        sub_156a();
    }
    else
    {
        int32_t var_58_1 = 0;
        while (true)
        {
            if (var_58_1 > 0x34)
            {
                sub_1614();
                break;
            }
            if (sub_14f7(sub_150a(*(&var_48 + var_58_1), 0)) != *((var_58_1 << 2) + &data_40a0))
            {
                sub_156a();
                break;
            }
            if (rax_7 != sub_1483(main, 0x200))
            {
                sub_16ad();
                exit(1);
                /* no return */
            }
            var_58_1 = (var_58_1 + 1);
        }
    }
    if (rax == *(fsbase + 0x28))
    {
        return 0;
    }
    __stack_chk_fail();
    /* no return */
}
```

There are a few anti debugging techniques in place, but since we reverse, as intended, we can ignore these. One thing to note here is that strings are generally obfuscated by xoring them with `0x12`. One example is `sub_16ad` which prints `st4rt r3v3rs1ng th15 ch4l1 x0rr3al!!!`. To get context we can decode the strings but it's not really needed.

```c
int64_t sub_16ad()
{
    void* fsbase;
    int64_t rax = *(fsbase + 0x28);
    int64_t var_38;
    __builtin_strncpy(&var_38, "af&`f2`!d!`a#|u2fz#\'2qz&~#2j\"``!s~333", 0x25);
    for (int32_t i = 0; i <= 0x24; i = (i + 1))
    {
        putchar((*(&var_38 + i) ^ 0x12));
    }
    putchar(0xa);
    int64_t rax_8 = (rax ^ *(fsbase + 0x28));
    if (rax_8 == 0)
    {
        return rax_8;
    }
    __stack_chk_fail();
    /* no return */
}
```

```python
>>> xor("af&`f2`!d!`a#|u2fz#\'2qz&~#2j\"``!s~333", 0x12)
b'st4rt r3v3rs1ng th15 ch4l1 x0rr3al!!!'
```

After this userinput is requested and the input is tested to have the length of `53`, otherwise the program ends with the message `c0m3 b4ck wh3n y0u ar3n't a11 t4lk!`. If a string with correct length is entered the string is checked in a loop. For each character `sub_150a` is called and the result is passed to `sub_14f7`. The final result is tested against data in `data_40a0[index]` and if the data is not equal the program again quits. (Note, the index `var_58_1` is multiplied by 4 (left shift 2) since data_40a0 holds dwords and therefore 4 bytes per entry).

Now we need to see what the both functions, `sub_150a` and `sub_14f7`, are doing and what the content of `data_40a0` actually is.

```c
char byte_4040[32] = {'~','{','k','|','n','s','\x7F',';','<','c','W','<','f','|','9','W','l',';','j','}','o','o',';','z','{','W','\0','\0','\0','\0','\0','\0'};

void sub_13f8()
{
    for (int32_t i = 0; i <= 0x19; i = (i + 1))
    {
        *((i << 2) + &data_40a0) = *(i + &data_4040);
    }
    for (int32_t i_1 = 0; i_1 <= 0x1a; i_1 = (i_1 + 1))
    {
        *(((i_1 + 0x1a) << 2) + &data_40a0) = *(i_1 + "<z;Wf8We<|k`Wn8zW|`;W;9;;?u");
    }
}
```

The array `data_40a0` is filled with some values. We can fully reconstruct this by just reimplementing `sub_13f8` which is used for initialization. Next, functions  `sub_150a` and `sub_14f7`:

```c
uint64_t sub_14f7(int32_t arg1) __pure
{
    return (arg1 ^ 0x12);
}

uint64_t sub_150a(char arg1, int32_t arg2)
{
    uint64_t rax_1;
    if (arg2 <= 3)
    {
        rax_1 = sub_150a((arg1 ^ *((arg2 * 0xb) + &data_4180)), (arg2 + 1));
    }
    else
    {
        rax_1 = arg1;
    }
    return rax_1;
}
```

The first one is easy, just implementing a xor with `0x12`. The second one is a bit longer. The function takes two arguments, if the second arguments is smaller or equal to 3 the function does a recursive call and increases the second argument by one. The character in the first argument is xored by the value at `data_4180[arg2*11]` and passed again to the recursive call. If the second argument is greater than 3 the function just returns the first argument as is. This easily can be implemented as loop, but whatever works.

Now we have another array `data_4180` we need in order to be able to reconstruct the key as the xor operations are easily revertible (bruteforce would work as well or probably even a sidechannel attack). Ok, lets look at `sub_1355` that initializes the key. Some care is needed, since the arrays `data_4180`, `data_418a`, `data_4194` and `data_419e` are all 10 bytes long and the string values leak into the following memory area but are overridden subsequently. The final key looks like this `s3cR3ts300vsctfvsctiiamfrnow0kkeyw0wkeywnow0kkeyw0wkeywwkeyw`.

```c
char* sub_1355()
{
    strcpy(&data_4180, "s3cR");
    strcat(&data_4180, "3ts3");
    strcpy(&data_418a, "vsct");
    strcat(&data_418a, "fvsctiamfrnow0kkeyw0wkeyw");
    strcpy(&data_4194, "iamfrnow0kkeyw0wkeyw");
    strcat(&data_4194, "now0kkeyw0wkeyw");
    strcpy(&data_419e, "keyw0wkeyw");
    return strcat(&data_419e, "wkeyw");
}
```

With this we finally can write a small script to reconstruct the key.

```python
byte_4040 = b'~{k|ns\x7f;<cW<f|9Wl;j}oo;z{W'
key = b"s3cR3ts300vsctfvsctiiamfrnow0kkeyw0wkeywnow0kkeyw0wkeywwkeyw"

dword_40A0 = [0]*53
for i in range(0,26):
    dword_40A0[i] = byte_4040[i]
for i in range(0,27):
    dword_40A0[i+26] = b"<z;Wf8We<|k`Wn8zW|`;W;9;;?u"[i]

def decode(c):
    for i in range(4): c = c ^ key[i*11]
    return c

for i in range(len(dword_40A0)):
    print(chr(decode(dword_40A0[i]^0x12)),end="")
```

Flag `vsctf{w34k_4nt1_d3bugg3rs_4r3_n0_m4tch_f0r_th3_31337}`