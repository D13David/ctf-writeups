# Cyber Apocalypse 2023

## Hunting License

> STOP! Adventurer, have you got an up to date relic hunting license? If you don't, you'll need to take the exam again before you'll be allowed passage into the spacelanes!
>
>  Author: N/A
>
> [`rev_hunting_license.zip`](rev_hunting_license.zip)

Tags: _rev_

## Solution
This challenge is a questionair we need to pass. Most information can be retrieved by decompiling the code in Ghidra and using `file` and `ldd`.

```
$ file license
license: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=5be88c3ed329c1570ab807b55c1875d429a581a7, for GNU/Linux 3.2.0, not stripped

What is the file format of the executable?
> elf
[+] Correct!

What is the CPU architecture of the executable?
> x86-64
[+] Correct!
```

```
$ ldd license
        linux-vdso.so.1 (0x00007ffebe1f4000)
        libreadline.so.8 => /lib/x86_64-linux-gnu/libreadline.so.8 (0x00007fed3dd07000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fed3db26000)
        libtinfo.so.6 => /lib/x86_64-linux-gnu/libtinfo.so.6 (0x00007fed3daf5000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fed3dd75000)

What library is used to read lines for user answers? (`ldd` may help)
> libreadline.so.8
[+] Correct!
```

```
$ gdb licence
...
pwndbg> info address main
Symbol "main" is at 0x401172 in a file compiled without debugging.

What is the address of the `main` function?
> 0x401172
[+] Correct!
```

```
pwndbg> disassemble main
Dump of assembler code for function main:
   0x0000000000401172 <+0>:     push   rbp
   0x0000000000401173 <+1>:     mov    rbp,rsp
   0x0000000000401176 <+4>:     sub    rsp,0x10
   0x000000000040117a <+8>:     mov    edi,0x402008
   0x000000000040117f <+13>:    call   0x401040 <puts@plt>
   0x0000000000401184 <+18>:    mov    edi,0x402030
   0x0000000000401189 <+23>:    call   0x401040 <puts@plt>
   0x000000000040118e <+28>:    mov    edi,0x402088
   0x0000000000401193 <+33>:    call   0x401040 <puts@plt>
   0x0000000000401198 <+38>:    call   0x401070 <getchar@plt>
   0x000000000040119d <+43>:    mov    BYTE PTR [rbp-0x1],al
   0x00000000004011a0 <+46>:    cmp    BYTE PTR [rbp-0x1],0x79
   0x00000000004011a4 <+50>:    je     0x4011c6 <main+84>
   0x00000000004011a6 <+52>:    cmp    BYTE PTR [rbp-0x1],0x59
   0x00000000004011aa <+56>:    je     0x4011c6 <main+84>
   0x00000000004011ac <+58>:    cmp    BYTE PTR [rbp-0x1],0xa
   0x00000000004011b0 <+62>:    je     0x4011c6 <main+84>
   0x00000000004011b2 <+64>:    mov    edi,0x4020dd
   0x00000000004011b7 <+69>:    call   0x401040 <puts@plt>
   0x00000000004011bc <+74>:    mov    edi,0xffffffff
   0x00000000004011c1 <+79>:    call   0x401080 <exit@plt>
   0x00000000004011c6 <+84>:    mov    eax,0x0
   0x00000000004011cb <+89>:    call   0x40128a <exam>
   0x00000000004011d0 <+94>:    mov    edi,0x4020f0
   0x00000000004011d5 <+99>:    call   0x401040 <puts@plt>
   0x00000000004011da <+104>:   mov    eax,0x0
   0x00000000004011df <+109>:   leave
   0x00000000004011e0 <+110>:   ret
End of assembler dump.

How many calls to `puts` are there in `main`? (using a decompiler may help)
> 5
[+] Correct!
```

```
(Ghidra)
iVar1 = strcmp(local_10,"PasswordNumeroUno");
if (iVar1 != 0) {
puts("Not even close!");
                // WARNING: Subroutine does not return
exit(-1);
}

What is the first password?
> PasswordNumeroUno
[+] Correct!
```

```
reverse(&var_1c, "0wTdr0wss4P", 0xb);
char* rax_4 = readline("Getting harder - what's the seco…");
if (strcmp(rax_4, &var_1c) != 0)
{}

What is the reversed form of the second password?
> 0wTdr0wss4P
[+] Correct!

What is the real second password?
> P4ssw0rdTw0
[+] Correct!
```

```
xor(&var_38, &t2, 0x11, 0x13);
char* rax_8 = readline("Your final test - give me the th…");
if (strcmp(rax_8, &var_38) == 0)
{}

What is the XOR key used to encode the third password?
> 0x13
[+] Correct!
```

```  
00404070 47              char       'G'
00404071 7b              char       '{'
00404072 7a              char       'z'
00404073 61              char       'a'
00404074 77              char       'w'
00404075 52              char       'R'
00404076 7d              char       '}'
00404077 77              char       'w'
00404078 55              char       'U'
00404079 7a              char       'z'
0040407a 7d              char       '}'
0040407b 72              char       'r'
0040407c 7f              char       7Fh
0040407d 32              char       '2'
0040407e 32              char       '2'
0040407f 32              char       '2'
00404080 13              char       13h

>>> key = [0x47, 0x7b, 0x7a, 0x61, 0x77, 0x52, 0x7d, 0x77, 0x55, 0x7a, 0x7d, 0x72, 0x7f, 0x32, 0x32, 0x32]
>>> "".join([chr(c^0x13) for c in key])
'ThirdAndFinal!!!'

What is the third password?
> ThirdAndFinal!!!
[+] Correct!

[+] Here is the flag: `HTB{l1c3ns3_4cquir3d-hunt1ng_t1m3!}`
```