# 1337UP LIVE CTF 2023

## Impossible Mission

> Decrypt the digital enigma! Delve into the binary abyss, solve the puzzles, and seize the hidden flag. Are you up for the challenge?
> 
> Note: This challenge will unlock few more challenges!
>
> Author: DavidP, 0xM4hm0ud  
>
> [`impossible.zip`](impossible.zip)

Tags: _rev_

## Solution
We are provided with two files. One binary and one file with data in it. If we use `strings` on file `program.prg` we don't get any results.

Lets see what happens if we run the binary. If we just run it we are provided with a help output describing commandline arguments. There are some options we can choose from and we need to pass in a program file. Lets try this:

```bash
$ ./runtime program.prg
READY.
test

?SYNTAX  ERROR
READY.
```

Seems to be some kind of virtual machine where the `runtime` executes the `program.prg`. To see whats going on we can open the binary with `Ghidra`. The binary is stripped but we can easily find `main` via `_entry`. The main function looks something like this:

```c
undefined8 main(int param_1,long param_2)
{
  int iVar1;
  undefined8 local_1030;
  char local_1028 [4096];
  undefined8 local_28;
  int local_1c;
  long local_18;
  int local_10;
  int local_c;
  
  local_c = 0;
  local_10 = 0;
  local_18 = 0;
  memset(local_1028,0,0x1000);
  local_1c = 1;
  do {
    if (param_1 <= local_1c) {
      if (local_c != 0) {
        local_10 = 0;
      }
      if (local_18 == 0) {
        printf("usage: %s [options] program\n  options:\n    -a, --asm assemble source\n    -o, --ou tput set output name for assembler"
               ,"runtime");
      }
      else {
        local_28 = FUN_001041d2(local_18,&local_1030);
        if (local_10 != 0) {
          FUN_00103f87();
          FUN_00103ffa(local_28,local_1030);
          FUN_001040b8();
          FUN_00103ff3();
        }
        FUN_001042b3(local_28);
      }
      return 0;
    }
    if (**(char **)(param_2 + (long)local_1c * 8) == '-') {
      iVar1 = strcmp(*(char **)(param_2 + (long)local_1c * 8),"--asm");
      if (iVar1 != 0) {
        iVar1 = strcmp(*(char **)(param_2 + (long)local_1c * 8),"-a");
        if (iVar1 != 0) {
          iVar1 = strcmp(*(char **)(param_2 + (long)local_1c * 8),"--out");
          if (iVar1 != 0) {
            iVar1 = strcmp(*(char **)(param_2 + (long)local_1c * 8),"-o");
            if (iVar1 != 0) goto LAB_001023eb;
          }
          if (local_1c + 1 < param_1) {
            strncpy(local_1028,*(char **)(param_2 + ((long)local_1c + 1) * 8),0x1000);
            local_1c = local_1c + 1;
          }
          goto LAB_001023eb;
        }
      }
      local_c = 1;
    }
    else {
      local_18 = *(long *)(param_2 + (long)local_1c * 8);
      local_10 = 1;
    }
LAB_001023eb:
    local_1c = local_1c + 1;
  } while( true );
}
```

We can ignore most of function main as it is code that parses commandline arguments, although the different options are not doing anything meaningful. Maybe a remnant that was forgotten? Who knows... The interesting part is reached if a program name is passed as argument.

```c
local_28 = FUN_001041d2(local_18,&local_1030);
if (local_10 != 0) {
  FUN_00103f87();
  FUN_00103ffa(local_28,local_1030);
  FUN_001040b8();
  FUN_00103ff3();
}
FUN_001042b3(local_28);
```

Analyzing the functionality a bit further, we can rename the functions. From top to bottom it looks like the program file is loaded to a buffer. The vm is initialized and the buffer is loaded by the vm. Then the program is executed. All in all the cleaned up code looks like this.

```c
local_28 = load_data_from_file(local_18,&local_1030);
if (local_10 != 0) {
  initialize();
  load_program(local_28,local_1030);
  run();
  does_nothing();
}
free_buffer(local_28)
```

The function `run` is a simple loop calling a simulation step per loop cycle. Function `step` reads the next opcode from our code and uses the opcode as loopup index into a array containing function pointers. We can assume the array contains pointers to the opcode handlers. From `read8bytes` we can deduce some more informations. We see that our program counter is stored at `DAT_00108900` and our vm memory is stored at `DAT_00108908`.

```c
void run(void)
{
  int iVar1;
  
  do {
    iVar1 = step();
  } while (iVar1 != 0);
  return;
}

bool step(void)
{
  code *pcVar1;
  byte bVar2;
  
  bVar2 = read8bytes();
  pcVar1 = *(code **)(&DAT_001080c0 + (long)(int)(uint)bVar2 * 8);
  if (pcVar1 == (code *)0x0) {
    panic();
  }
  (*pcVar1)();
  return DAT_00108900 != -1;
}

undefined read8bytes(void)
{
  uint uVar1;
  
  if (0xcffe < ProgramCounter) {
    panic();
  }
  uVar1 = (uint)ProgramCounter;
  ProgramCounter = ProgramCounter + 1;
  return (&VmMemory)[(int)uVar1];
}
```

Going back to `load_program` we can see that our program counter is initialized with `0xc000`, we can assume this is the base address our program is loaded to.

```c
bool load_program(void *param_1,size_t param_2)
{
  if ((long)param_2 < 0x1001) {
    memcpy(&DAT_00114908,param_1,param_2);
    FUN_0010269e(0xffff);
    ProgramCounter = 0xc000;
  }
  return (long)param_2 < 0x1001;
}
```

Knowing where to find the opcode handler lookup table we can retype the array to `void*` and can start reversing the opcode handlers. For instance the function at index `8` writes a value to the `vm memory` at index `DAT_00108906 + 0x100`. This could be a `push` operation. We can rename `DAT_00108906` to `StackPointer`.

```c
void push(undefined param_1)
{
  (&VmMemory)[(int)(StackPointer + 0x100)] = param_1;
  StackPointer = StackPointer - 1;
  return;
}
```

The function at index `9` reads 8 bytes and does a bitwise `or` with what is at `DAT_00108902`. We rename this to `OR`and move on.

```c
void OR(void)
{
  byte bVar1;
  
  bVar1 = read8bytes();
  DAT_00108902 = bVar1 | DAT_00108902;
  FUN_001025fa(0x80,DAT_00108902 & 0x80);
  FUN_001025fa(2,DAT_00108902 == 0);
  return;
}
```

After a while the functionality of the vm opcodes should become clear. We find that, opcodes use 8 bytes. Then, depending on the opcode are 0, 1 or 2 bytes of instruction parameters. Another conclusion we might draw is (also the input prompt gives this away as an hint) that this vm is implementing a [`6502 instruction set`](https://www.masswerk.at/6502/6502_instruction_set.html). With this at hand we write a small [`disassembler`](disasm.py) so we can make sense out of the program image. 

One thing to note is that values might not be recognized but the program starts with a `JMP` skipping some parts of the binary. These parts typically hold data, so we either can trace the flow and decide which parts are not reached or we just guess the initial jump skips the data section. Now we have the disassembly we need to understand the functionality and attach some comments.

```bash
00ae LDX 3
00b0 JSR ffc9     ; ffc9 is kernal routine CHKOUT, channel 3 (screen) is set as output channel

00b3 LDA 2e
00b5 STA fb
00b7 LDA c0
00b9 STA fc       ; store 16 bit address $c02e to zero page at $fb, $fc
00bb JSR c099     ; call subroutine at $c099
```

The subroutine at `$99` (remember our base address is `$c000`) was not dumped, so there is more code before the program start. We readjust our offset manually and continue.

Subroutine `$c099`.
```bash
0099 LDY ff       ; initialize Y 
009b INY          ; increment, Y will wrap around to `0`
009c LDA (fb), y  ; load 16 bit address from zero page at $fb,$fc
009e ASL
009f BCC 2
00a1 ORA 1
00a3 ASL
00a4 BCC 2
00a6 ORA 1
00a8 JSR ffd2     ; ffd2 is kernal routine CHROUT, this prints the value at AC to screen
00ab BNE ee       ; if character was not `\x00` we are not finished
00ad RTS
```

This routine prints a string to screen. But there is a bit of bit shifting going on. We can translate this to the following python code (string is taken from the hexdump offset $03 to $1C):

```python
string = [0xD4, 0x55, 0xD0, 0xD0, 0x51, 0xD4, 0xD4, 0x8B, 0x8B, 0x8B, 0x08, 0xD4, 0x12, 0x55, 0x15, 0x15, 0x52, 0x93, 0xD1, 0x08, 0x11, 0xD3, 0xD5, 0x93, 0x8B, 0x82]

for x in string:
    b = (x & 0x80) >> 7
    x = ((x << 1) & 0xff) | b
    b = (x & 0x80) >> 7
    x = ((x << 1) & 0xff) | b
    print(chr(x),end="")
```

Calling this gives us:

```bash
$ python decode_string.py
SUCCESS... SHUTTING DOWN.
```

Perfect, this way we can decode all string from the data section. All in all we get:

```bash
SUCCESS... SHUTTING DOWN.
?SYNTAX  ERROR
READY.
```

Ok, we knew these strings already, and no flag.. Lets continue analyzing the dissassembly.

```bash
00be LDX 0
00c0 LDA 0
00c2 STA c07c       ; store `0` to `$c07c`
00c5 JSR ffcf       ; ffcf is kernal routine CHRIN, this reads a character from keyboard

00c8 CMP d
00ca BEQ 21
00cc CMP a
00ce BEQ 1d         ; check if the character is carriage return or newline. if so we leave the input loop

00d0 PHA            ; store LDA on stack
00d1 LDA c07c       ; load LDA with value at `$c07c`
00d4 CMP 46         ; compare if with 70
00d6 PLA            ; restore LDA
00d7 BEQ 14         ; if the value at `$c07c` equals 46, we leave the input loop

00d9 CMP 20
00db BMI e8
00dd CMP 7e
00df BPL e4         ; compare input value to be in range $20-$7e so printable character range

00e1 STA c036, x    ; store the user input value in memory
00e4 INX            ; increment X
00e5 INC c07c       ; increment value at `$c07c`, we can assume this is the input length stored in a variable
00e8 JMP c0c5       ; jump back to input loop start
```

The part reads user input and stores the input in memory. Only readable characters are accepted and the maximum user input is 70. Ok, moving on...

```bash
00eb some var
00ec some var
00ed LDX ff         ; loads $ff to X
00ef INX            ; increment X, X will wrap around to `0`
00f0 LDA c07d, x    ; load value from `$c07d` at index X
00f3 CMP 0          ; check loaded byte against `0`
00f5 BNE f8         ; if byte was not `0` continue counting

00f7 TXA            ; copy X to AC
00f8 CMP c07c       ; compare length of string at `$c07d` against user input length
00fb BNE 35         ; if not equal jump to $0132 (relative jump offset)
```

This first calculates the length of a string stored at `$c07d` and compares the length against the user input length. We can assume the flag is stored in memory at `$c07d` and this code compares the input length against flag length. Since we now know where the flag is stored, we should try to decode it with our string decoding functionality we found before.

```bash
$ python decode_string.py
R^ÁJ   rú¥a<¸ï©Ø\¼,7
```

Well... no. So we continue with our analysis. Lets see where the code jumps to if the string length doesn't match. This should be the fail handler.

```bash
0132 LDA a
0134 JSR ffd2       ; output newline to screen
0137 LDA 1e
0139 STA fb
013b LDA c0
013d STA fc         ; store address of string `?SYNTAX  ERROR`
013f JSR c099       ; call print subroutine
0142 JMP c0ae       ; jump back to start
```

Yes, this prints the `?SYNTAX  ERROR` error message. The remaining code is getting short, but this should be the interesting part.

```bash
00fd LDX 0          ; load `0` to X
00ff LDA c07d, x    ; read flag character at offset X to register AC
0102 CMP 0          ; check if we reached the string end
0104 BEQ 1b         ; jump out of the loop, if we did
0106 STX c0eb       ; store X to temporary variable
0109 EOR c0eb       ; xor AC with current offset (X)

010c ASL
010d ADC 80
010f ROL
0110 ASL
0111 ADC 80
0113 ROL            ; do some bit twiddles to swap high/low nibble of byte

0114 EOR c036,      ; xor AC with user input at offset X
0117 ORA c0ec       ; bitwise or AC with value at `$c0ec`
011a STA c0ec       ; store result in `$c0ec`
011d INX            ; move to next character
011e JMP c0ff       ; jump back to loop start

0121 LDA c0ec
0124 BNE c          ; check if value at `$c0ec` is zero, if not we jump to fail handler

0126 LDA 3
0128 STA fb
012a LDA c0
012c STA fc         ; load address of string `SUCCESS... SHUTTING DOWN.`
012e JSR c099       ; call print subroutine
0131 RTS
```

Ok, here we have it. The code loops over the flag and user input, decodes one character of the flag and compares it against the current user input character. The comparison is tracked for each character of a string as a bitmask and at the end the code checks if the bitmask is still zero, meaning the user input matches with the flag. With this we can grab the encoded flag bytes and try to decode them with a small script.

```python
data = [0x94, 0xE5, 0x47, 0x97, 0x70, 0x20, 0x92, 0x42, 0x9C, 0xBE, 0x69, 0x58, 0x0F, 0x2E, 0xFB, 0x6A, 0xC4, 0x26, 0xE7, 0x36, 0x17, 0x23, 0xA0, 0x20, 0x2F, 0x0B, 0xCD]
flag = ""

for i, c in enumerate(data):
    # xor with key
    c ^= i
    # swap nibbles
    c = ((c & 0x0F) << 4 | (c & 0xF0) >>4)
    flag = flag + chr(c)

print(flag)
```

And yes, running this will finally give us the flag.

Flag `INTIGRITI{6502_VMs_R0ckss!}`
