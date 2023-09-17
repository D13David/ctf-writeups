# CSAW'23

## Rebug 2

> 
> No input this time ;) Try to get the flag from the binary. When you find the answer of the program, please submit the flag in the following format: `csawctf{output}`
>
>  Author: Mahmoud Shabana
>
> [`bin.out`](bin.out)

Tags: _rev_

## Solution
This is a follow up to [`Rebug 1`](../rebug_1/README.md). It's mentioned there is not output this time so we open the file with `Ghidra and see whats going on`.

```c
undefined8 main(void)
{
  undefined8 local_28;
  undefined8 local_20;
  undefined4 local_18;
  int local_10;
  uint local_c;
  
  local_28 = 0x6e37625970416742;
  local_20 = 0x44777343;
  local_18 = 0;
  local_10 = 0xc;
  printf("That is incorrect :(");
  for (local_c = 0; (int)local_c < local_10; local_c = local_c + 1) {
    if (((local_c & 1) == 0) && (local_c != 0)) {
      printbinchar((int)*(char *)((long)&local_28 + (long)(int)local_c));
    }
  }
  return 0;
}
```

Ok, there are numbers (which are actually interpreted as `char` values), and a loop with 12 iterations over the chars. If the loop index is not zero and a odd number (lsb is set) the function `printbinchar` is called.

```c
void printbinchar(char param_1)
{
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  uint local_14;
  char local_d;
  int local_c;
  
  local_38 = 0;
  local_30 = 0;
  local_28 = 0;
  local_20 = 0;
  for (local_c = 0; local_c < 8; local_c = local_c + 1) {
    local_14 = ((int)param_1 << ((byte)local_c & 0x1f)) >> 7 & 1;
    *(uint *)((long)&local_38 + (long)local_c * 4) = local_14;
  }
  local_d = param_1;
  xoring(&local_38);
  return;
}
```

The function `printbinchar` loops 8 times and does some operations on the input and writes it to a array with 8 entries. Then the array is passed to `xoring`.

```c
undefined8 xoring(long param_1)
{
  undefined8 local_38;
  undefined8 local_30;
  undefined8 local_28;
  undefined8 local_20;
  int local_10;
  int local_c;
  
  local_28 = 0;
  local_20 = 0;
  local_38 = 0;
  local_30 = 0;
  for (local_c = 0; local_c < 4; local_c = local_c + 1) {
    *(undefined4 *)((long)&local_28 + (long)local_c * 4) =
         *(undefined4 *)(param_1 + (long)local_c * 4);
    *(undefined4 *)((long)&local_38 + (long)local_c * 4) =
         *(undefined4 *)(param_1 + ((long)local_c + 4) * 4);
  }
  for (local_10 = 0; local_10 < 4; local_10 = local_10 + 1) {
    if (*(int *)((long)&local_28 + (long)local_10 * 4) ==
        *(int *)((long)&local_38 + (long)local_10 * 4)) {
      flag[index_flag] = 0x30;
    }
    else {
      flag[index_flag] = 0x31;
    }
    index_flag = index_flag + 1;
  }
  return 0;
}
```

The first part is copying the input to two local arrays and then loops over the 4 entries. If both entries at a certain index are equal a `0` is written to `flag[index_flag]` otherwise a `1`. After this the `flag_index` is incremented.

To reproduce this, we can just try to port the code to `Python` (or whatever language), run it and print the result. But it's even easier to just use dynamic analysis here and debug the program with `gdb`.

```bash
$ gdb ./bin.out
pwndbg> starti
pwndbg> disassemble main
Dump of assembler code for function main:
   0x00005555555552a4 <+0>:     push   rbp
   0x00005555555552a5 <+1>:     mov    rbp,rsp
   0x00005555555552a8 <+4>:     sub    rsp,0x20
   0x00005555555552ac <+8>:     movabs rax,0x6e37625970416742
   0x00005555555552b6 <+18>:    mov    edx,0x44777343
   0x00005555555552bb <+23>:    mov    QWORD PTR [rbp-0x20],rax
   0x00005555555552bf <+27>:    mov    QWORD PTR [rbp-0x18],rdx
   0x00005555555552c3 <+31>:    mov    DWORD PTR [rbp-0x10],0x0
   0x00005555555552ca <+38>:    mov    DWORD PTR [rbp-0x8],0xc
   0x00005555555552d1 <+45>:    lea    rax,[rip+0xd2c]        # 0x555555556004
   0x00005555555552d8 <+52>:    mov    rdi,rax
   0x00005555555552db <+55>:    mov    eax,0x0
   0x00005555555552e0 <+60>:    call   0x555555555030 <printf@plt>
   0x00005555555552e5 <+65>:    mov    DWORD PTR [rbp-0x4],0x0
   0x00005555555552ec <+72>:    jmp    0x555555555316 <main+114>
   0x00005555555552ee <+74>:    mov    eax,DWORD PTR [rbp-0x4]
   0x00005555555552f1 <+77>:    and    eax,0x1
   0x00005555555552f4 <+80>:    test   eax,eax
   0x00005555555552f6 <+82>:    jne    0x555555555312 <main+110>
   0x00005555555552f8 <+84>:    cmp    DWORD PTR [rbp-0x4],0x0
   0x00005555555552fc <+88>:    je     0x555555555312 <main+110>
   0x00005555555552fe <+90>:    mov    eax,DWORD PTR [rbp-0x4]
   0x0000555555555301 <+93>:    cdqe
   0x0000555555555303 <+95>:    movzx  eax,BYTE PTR [rbp+rax*1-0x20]
   0x0000555555555308 <+100>:   movsx  eax,al
   0x000055555555530b <+103>:   mov    edi,eax
   0x000055555555530d <+105>:   call   0x55555555522c <printbinchar>
   0x0000555555555312 <+110>:   add    DWORD PTR [rbp-0x4],0x1
   0x0000555555555316 <+114>:   mov    eax,DWORD PTR [rbp-0x4]
   0x0000555555555319 <+117>:   cmp    eax,DWORD PTR [rbp-0x8]
   0x000055555555531c <+120>:   jl     0x5555555552ee <main+74>
   0x000055555555531e <+122>:   mov    eax,0x0
   0x0000555555555323 <+127>:   leave
   0x0000555555555324 <+128>:   ret
End of assembler dump.
pwndbg> break *0x000055555555531e
Breakpoint 1 at 0x55555555531e
```

First we run `gdb` with the `binary`. With `starti` we run the application and immediately break at the entry. Since we want to set a breakpoint to the end of main we disassemble main and copy the address before the `leave` instruction and set a breakpoint there. Afterwards we hit `c` to continue.

```bash
pwndbg> c
...
00:0000│ rsp 0x7fffffffde30 ◂— 'BgApYb7nCswD'
01:0008│     0x7fffffffde38 ◂— 0x44777343 /* 'CswD' */
02:0010│     0x7fffffffde40 ◂— 0x0
03:0018│     0x7fffffffde48 ◂— 0xc0000000c /* '\x0c' */
04:0020│ rbp 0x7fffffffde50 ◂— 0x1
05:0028│     0x7fffffffde58 —▸ 0x7ffff7def18a (__libc_start_call_main+122) ◂— mov    edi, eax
06:0030│     0x7fffffffde60 ◂— 0x0
07:0038│     0x7fffffffde68 —▸ 0x5555555552a4 (main) ◂— push   rbp
...
```

We can see all sorts of things, e.g. on the stack is the input string (the numbers we saw in the disassembly) `BgApYb7nCswD`. But we want to know what is written to the global variable `flag`. We can do this by using `x` (inspect) with `/s` (string) on `&flag`.

```bash
pwndbg> x/s &flag
0x555555558030 <flag>:  "01011100010001110000"
```

Surrounding this by `csawctf{}` will give us the flag.

Flag `csawctf{01011100010001110000}`