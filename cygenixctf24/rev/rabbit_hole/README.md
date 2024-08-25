# Cygenix CTF 2024

## Rabbit Hole

> *"In the heart of the binary, a secret slumbers."*
>
>  Author: N/A
>
> [`packed.zip`](packed.zip)

Tags: _rev_

## Solution
The challenge comes with a binary called `packed`. This looks like a strong hint, typically tools like [`UPX`](https://upx.github.io/) are used to create self extracting binaries. So we try to unpack it.

```bash
$ ./upx/upx -d packed
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2024
UPX 4.2.4       Markus Oberhumer, Laszlo Molnar & John Reiser    May 9th 2024

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
upx: packed: CantUnpackException: l_info corrupted

Unpacked 1 file: 0 ok, 1 error.
```

So bad... Maybe the binary was not packed with `UPX` in the first place. By runing `strings` on the binary we can confirm it was in fact packed with `UPX`.

```bash
$ strings packed | grep UPX
$Info: This file is packed with the UPX executable packer http://upx.sf.net $
$Id: UPX 4.24 Copyright (C) 1996-2024 the UPX Team. All Rights Reserved. $
UPX!u
UPX!
UPX!
```

So the archive is corrupted in some way. So we are checking with an hexeditor and see the UPX header is indeed corrupted at bytes EEh and EFh (check [`this`](https://github.com/upx/upx/blob/devel/src/stub/src/include/header.S) and [`this`](https://github.com/upx/upx/blob/devel/src/packhead.cpp#L179) to see header layout). So we fix quickly the identifier from `55505924` (UPY$) to `55505821` (UPX!). 

```bash
Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

000000E0  10 00 00 00 00 00 00 00 D6 F4 79 CD 55 50 59 24  ........ÖôyÍUPY$
000000F0  D4 0A 0E 16 00 00 00 00 68 3E 00 00 50 0E 00 00  Ô.......h>..P...
00000100  18 03 00 00 CE 00 00 00 02 00 00 00 F6 FB 21 FF  ....Î.......öû!ÿ
```

In total we have now

```bash
00h 55 50 58 21 identifier  UPX!
04h D4          version     212
05h 0A          format      UPX_F_LINUX_i386
06h 0E          method      M_LZMA
07h 16          level       22
.. variable length header...
```

Lets hope that no other corrupted are present:

```bash
$ ./upx/upx -d packed
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2024
UPX 4.2.4       Markus Oberhumer, Laszlo Molnar & John Reiser    May 9th 2024

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
     25067 <-      6104   24.35%   linux/amd64   packed

Unpacked 1 file.
```

This looks fine. So lets open the file with `BinaryNinja`. The main function looks something like this:

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    int64_t var_58;
    __builtin_strcpy(&var_58, "kpPGJLJGdfdsawLeojdlskanlakMKasSAAsasa_sAsSWErRTrgfDfaWiascsRfsefaEyUGHrt");
    rtx();
    int32_t var_c = 1;
    puts("error");
    return 0;
}
```

There is a string copy to the stack and a call to `rtx`: 

```c
int64_t rtx()
{
    int64_t var_58;
    __builtin_strncpy(&var_58, "j8aXNf7CGySC//FuaDyMNUxCD6GPxvx99w/Kw+yHpDMsgKtIgiMnvU8cqe9k/My+", 0x41);
    return 1;
}
```

Yet another string copy. Both strings look suspiciously like they could be interesting. Otherwise nothing is done with the values and the main function just prints `error` to the console. Sadly the strings turn out to be the rabbit hole, so after some trial and error there's nothing interesting to be found about them. 

And here is the thing again with the decompiler function of analysis tools. They tend to hide things that might be important. So we are inspecting next the `raw` instruction disassembly.

```c
int32_t main(int32_t argc, char** argv, char** envp)

55                 push    rbp {__saved_rbp}
4889e5             mov     rbp, rsp {__saved_rbp}
4881ec90000000     sub     rsp, 0x90
48b86b7050474a4c…  mov     rax, 0x474a4c4a4750706b
48ba646664736177…  mov     rdx, 0x654c776173646664
488945b0           mov     qword [rbp-0x50], rax  {0x474a4c4a4750706b}
488955b8           mov     qword [rbp-0x48 {var_50}], rdx  {0x654c776173646664}
48b86f6a646c736b…  mov     rax, 0x6e616b736c646a6f
48ba6c616b4d4b61…  mov     rdx, 0x5373614b4d6b616c
488945c0           mov     qword [rbp-0x40 {var_48}], rax  {0x6e616b736c646a6f}
488955c8           mov     qword [rbp-0x38 {var_40}], rdx  {0x5373614b4d6b616c}
48b8414173617361…  mov     rax, 0x735f617361734141
48ba417353574572…  mov     rdx, 0x5452724557537341
488945d0           mov     qword [rbp-0x30 {var_38}], rax  {0x735f617361734141}
488955d8           mov     qword [rbp-0x28 {var_30}], rdx  {0x5452724557537341}
48b8726766446661…  mov     rax, 0x6957616644666772
48ba617363735266…  mov     rdx, 0x6573665273637361
488945e0           mov     qword [rbp-0x20 {var_28}], rax  {0x6957616644666772}
488955e8           mov     qword [rbp-0x18 {var_20}], rdx  {0x6573665273637361}
48b8637352667365…  mov     rax, 0x6166657366527363
48ba457955474872…  mov     rdx, 0x74724847557945
488945ea           mov     qword [rbp-0x16 {var_20+0x2}], rax  {0x6166657366527363}
488955f2           mov     qword [rbp-0xe {var_16}], rdx  {0x74724847557945}
b800000000         mov     eax, 0x0
e8e0feffff         call    rtx
8945fc             mov     dword [rbp-0x4 {var_c}], eax  {0x1}
837dfc01           cmp     dword [rbp-0x4], 0x1
7514               jne     0x1276  {0x0}

488d059b0d0000     lea     rax, [rel data_2004]
4889c7             mov     rdi, rax  {data_2004, "error"}
e8bffdffff         call    puts
...
```

So, yes. This part we know well. There is the string copy and the call to puts. But there is more code which was not present in the decompiled code since the program skips over it with a jump to `1316h`.

```c
... continued
e9a0000000         jmp     0x1316

0fb645cb           movzx   eax, byte [rbp-0x35 {var_40+0x3}]  {0x4d}
888570ffffff       mov     byte [rbp-0x90], al  {0x4d}
0fb645bc           movzx   eax, byte [rbp-0x44 {var_50+0x4}]  {0x61}
888571ffffff       mov     byte [rbp-0x8f {var_97}], al  {0x61}
0fb645c3           movzx   eax, byte [rbp-0x3d {var_48+0x3}]  {0x6c}
888572ffffff       mov     byte [rbp-0x8e {var_96}], al  {0x6c}
0fb645bd           movzx   eax, byte [rbp-0x43 {var_50+0x5}]  {0x77}
888573ffffff       mov     byte [rbp-0x8d {var_95}], al  {0x77}
0fb645bc           movzx   eax, byte [rbp-0x44 {var_50+0x4}]  {0x61}
888574ffffff       mov     byte [rbp-0x8c {var_94}], al  {0x61}
0fb645dd           movzx   eax, byte [rbp-0x23 {var_30+0x5}]  {0x72}
888575ffffff       mov     byte [rbp-0x8b {var_93}], al  {0x72}
0fb645bf           movzx   eax, byte [rbp-0x41 {var_50+0x7}]  {0x65}
888576ffffff       mov     byte [rbp-0x8a {var_92}], al  {0x65}
0fb645d6           movzx   eax, byte [rbp-0x2a {var_38+0x6}]  {0x5f}
888577ffffff       mov     byte [rbp-0x89 {var_91}], al  {0x5f}
0fb645d0           movzx   eax, byte [rbp-0x30 {var_38}]  {0x41}
888578ffffff       mov     byte [rbp-0x88 {var_90}], al  {0x41}
0fb645c7           movzx   eax, byte [rbp-0x39 {var_48+0x7}]  {0x6e}
888579ffffff       mov     byte [rbp-0x87 {var_8f}], al  {0x6e}
0fb645bc           movzx   eax, byte [rbp-0x44 {var_50+0x4}]  {0x61}
88857affffff       mov     byte [rbp-0x86 {var_8e}], al  {0x61}
0fb645c3           movzx   eax, byte [rbp-0x3d {var_48+0x3}]  {0x6c}
88857bffffff       mov     byte [rbp-0x85 {var_8d}], al  {0x6c}
0fb645f3           movzx   eax, byte [rbp-0xd {var_16+0x1}]  {0x79}
88857cffffff       mov     byte [rbp-0x84 {var_8c}], al  {0x79}
0fb645bb           movzx   eax, byte [rbp-0x45 {var_50+0x3}]  {0x73}
88857dffffff       mov     byte [rbp-0x83 {var_8b}], al  {0x73}
0fb645e7           movzx   eax, byte [rbp-0x19 {var_28+0x7}]  {0x69}
88857effffff       mov     byte [rbp-0x82 {var_8a}], al  {0x69}
0fb645c4           movzx   eax, byte [rbp-0x3c {var_48+0x4}]  {0x73}
88857fffffff       mov     byte [rbp-0x81 {var_89}], al  {0x73}

b800000000         mov     eax, 0x0
c9                 leave    {__saved_rbp}
c3                 retn     {__return_addr}
```

This looks actually interesting. Some bytes are copied to a stack location. To see what is copied we can unpatch the `jump` (turn it to `nops`) and just run the program in `gdb` set a breakpoint to the end of main and check the stack. Lets do this:

In BinaryNinja right click the `jmp` instruction and choose `Patch->Convert to NOP`. This allows us to execute the code. There are other methods as well, we could also just set `rip` in gdb to offset `1276h`... But what ever works. Next we run the program in `gdb`.

```bash
$ gdb ./packed
pwndbg> break *main+355
Breakpoint 1 at 0x131b
pwndbg> r
pwndbg> stack 30
00:0000│ rsp 0x7fffffffdc40 ◂— 'Malware_Analysis'
```

There we have it, the value written is `Malware_Analysis`. We also could have extracted the bytes from the disassembly.

```python
data = bytearray([0x4d, 0x61, 0x6c, 0x77, 0x61, 0x72, 0x65, 0x5f, 0x41, 0x6e, 0x61, 0x6c, 0x79, 0x73, 0x69, 0x73])
print(data.decode())
```

```bash
$ python foo.py
Malware_Analysis
```

Wrapping this value to the flag format gives us the flag.

Flag `CyGenixCTF{Malware_Analysis}`