# UIUCTF 2023

## vmwhere1

> Usage: ./chal program
>
>  Author: richard
>
> [`chal`](chal)
> [`program`](program)

Tags: _rev_

## Solution
The name of the challenge suggests it, this is probably another virtual machine reverse. The executable is very small, so opening it with [`https://dogbolt.org/`](dogbolt) works just fine. The main prints usage information, which are known from the description already. Then the program is loaded and afterwards run (naming where adapted).

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    void* fsbase;
    int64_t rax = *(fsbase + 0x28);
    int32_t rax_5;
    if (argc <= 1)
    {
        printf("Usage: %s <program>\n", *argv);
        rax_5 = 1;
    }
    else
    {
        int32_t programSize;
        void* program = loadProgram(argv[1], &programSize);
        if (program == 0)
        {
            printf("Failed to read program %s\n", argv[1]);
            rax_5 = 2;
        }
        else if (runProgram(program, programSize) == 0)
        {
            rax_5 = 0;
        }
        else
        {
            rax_5 = 3;
        }
    }
    *(fsbase + 0x28);
    if (rax == *(fsbase + 0x28))
    {
        return rax_5;
    }
    __stack_chk_fail();
    /* no return */
}
```

The function `loadProgram` is very straight forward, so moving on th `runProgram`.

```c
int64_t runProgram(void* arg1, int32_t arg2)
{
    void* var_20 = arg1;
    void* rax_1 = malloc(0x1000);
    void* var_18 = rax_1;
    int64_t rax_10;
    while (true)
    {
        if ((arg1 <= var_20 && var_20 < (arg1 + arg2)))
        {
            char* rax_3 = var_20;
            var_20 = &rax_3[1];
            uint32_t rax_5 = *rax_3;
            switch (rax_5)
            {
                case 0:
                {
                    rax_10 = 0;
                    break;
                    break;
                }
                case 1:
                {
                    *(var_18 - 2) = (*(var_18 - 2) + *(var_18 - 1));
                    var_18 = (var_18 - 1);
                    break;
                }
                case 2:
                {
                    *(var_18 - 2) = (*(var_18 - 2) - *(var_18 - 1));
                    var_18 = (var_18 - 1);
                    break;
                }
                case 3:
                {
                    *(var_18 - 2) = (*(var_18 - 2) & *(var_18 - 1));
                    var_18 = (var_18 - 1);
                    break;
                }
                case 4:
                {
                    *(var_18 - 2) = (*(var_18 - 2) | *(var_18 - 1));
                    var_18 = (var_18 - 1);
                    break;
                }
                case 5:
                {
                    *(var_18 - 2) = (*(var_18 - 2) ^ *(var_18 - 1));
                    var_18 = (var_18 - 1);
                    break;
                }
				/// ...
			}
		}
	}
}
```

This is a very typical program loop, reading opcodes and data from the code buffer and doing operations based on the opcode. The VM has 18 opcodes in total 0x00-0x10 and 0x28, where 0x28 is somewhat special, because it can be used to dump the VM state.

```c
void* sub_1370(int64_t arg1, int64_t arg2, int64_t arg3, int64_t arg4)
{
    int64_t var_20 = arg1;
    printf("Program counter: 0x%04lx\n", arg4);
    printf("Stack pointer: 0x%04lx\n", ((arg3 - 1) - arg2));
    void* rax_5 = puts("Stack:");
    for (int32_t var_c = 0; var_c <= 0xf; var_c = (var_c + 1))
    {
        rax_5 = (((arg3 - 1) - arg2) - var_c);
        if (rax_5 >= 0)
        {
            rax_5 = printf("0x%04lx: 0x%04x\n", (((arg3 - 1) - arg2) - var_c), *((arg3 - 1) + (-var_c)));
        }
    }
    return rax_5;
}
```

This gives us some good hints about how the VM works. It consists out of a program counter (pointing to the current instruction to execute) and a stack. Nothing else really, everything is stack based. It's beautifully easy.

With this we can start to attach context to `runProgram`. We know that `arg1` is the program code, so we can rename `var_20` and `var_18` accordingly.

```c
byte_t* code = arg1;
byte_t* stackMem = malloc(0x1000);
byte_t* stack = stackMem;
```

Afterwards we can attach more context to the instructions. For instance instruction `1` adds two values from the stack and saves it to the stack. So we write this down as a note.

```c
case 1: // add s(2), s(2), s(1)
{
	TRACE(printf("ADD %02x %02x\n", *(stack - 2), *(stack - 1)));
	*(stack - 2) = (*(stack - 2) + *(stack - 1));
	pop(stack);
	break;
}
```

Another very helpful thing is to be able to trace actual mnemonics so we can create a disassembly of the program. This is done by just printing some informations and wrapping the print in a `TRACE` macro, so tracing can be disabled or enabled at a single spot.

```c
#define DO_TRACE 0

#if DO_TRACE
#define TRACE(x) x
#else
#define TRACE(x)
#endif
```

A last thing is to augment stack pop instruction to override the last freed item with a constant. This way the stack doesn't contain old values and while debugging with visual studio, the stack memory can be inspected and we always know where the stack pointer is pointing to.

```c
void pop(byte_t*& stack)
{
    stack = (stack - 1);
    *stack = 0xfe;
}
```

Now this is done for all the other instructions as well and we have a full fledged understanding of what the VM can do, how data is transformed and have a some debugging functionality in place (the code with some augmentations for `vmwhere2` can be found [`here`](../vmwhere2/stack_vm.cpp)).

Ok, moving on. Now we can run the program and create a full trace. Here's a commented version. First the banner and input prompt are printed to screen.

```
; print welcome message
0001 PUSH #00		; push \00 to stack
0003 PUSH #0a		; push new line (0Ah) to stack
0005 PUSH !			; push '!' to stack
0007 PUSH 1
0009 PUSH
000b PUSH e
000d PUSH r
000f PUSH e
0011 PUSH h
0013 PUSH W
0015 PUSH M
0017 PUSH V
0019 PUSH
001b PUSH o
001d PUSH t
001f PUSH
0021 PUSH e
0023 PUSH m
0025 PUSH o
0027 PUSH c
0029 PUSH l
002b PUSH e
002d PUSH W			; message "Welcome to VMWhere 1!\n\0"
print_loop1:
002f JZ end			; jump if currentn stack item is zero
0032 PUT s(1)		; pop item from stack and print on screen
0033 JMP print_loop
end1:

; print input prompt
0036 PUSH #00
0038 PUSH #0a
003a PUSH :
003c PUSH d
003e PUSH r
0040 PUSH o
0042 PUSH w
0044 PUSH s
0046 PUSH s
0048 PUSH a
004a PUSH p
004c PUSH
004e PUSH e
0050 PUSH h
0052 PUSH t
0054 PUSH
0056 PUSH r
0058 PUSH e
005a PUSH t
005c PUSH n
005e PUSH e
0060 PUSH
0062 PUSH e
0064 PUSH s
0066 PUSH a
0068 PUSH e
006a PUSH l
006c PUSH P		; message "please enter the password:\n\00"
print_loop2:
006e JZ end2
0071 PUT s(1)
0072 JMP print_loop2
end2:
```

After this, the program reads a character and validates if the character is a valid flag character.

```
0075 PUSH #00
0077 READ		; read character from keyboard
aaaa
0078 PUSHS 97	; push character to stack ('a' = 97)
0079 PUSH #04	; push value from code segment
007b SHR		; SHR s(2), s(2) s(1)
007c XOR 61 06	; XOR s(2), s(2) s(1)
007d XOR 00 67	; XOR s(2), s(2) s(1)
007e PUSHS 103	; push value from code segment
007f PUSH r		; push s(1)
0081 XOR 67 72	; XOR s(2), s(2) s(1) - test if modified input value is same as value from code segment
0082 JZ char1	; jump if same
0085 JMP fail	; 
char1:
... check next character(s)

fail:
0495 PUSH #00	; print fail message
0497 PUSH #0a
0499 PUSH !
049b PUSH d
049d PUSH r
049f PUSH o
04a1 PUSH w
04a3 PUSH s
04a5 PUSH s
04a7 PUSH a
04a9 PUSH p
04ab PUSH
04ad PUSH t
04af PUSH c
04b1 PUSH e
04b3 PUSH r
04b5 PUSH r
04b7 PUSH o
04b9 PUSH c
04bb PUSH n
04bd PUSH I
04bf JZ no
04c2 PUT #49
04c3 JMP
04bf JZ no
04c2 PUT #6e
04c3 JMP
04bf JZ no
04c2 PUT #63
04c3 JMP
04bf JZ no
04c2 PUT #6f
04c3 JMP
04bf JZ no
04c2 PUT #72
04c3 JMP
04bf JZ no
04c2 PUT #72
04c3 JMP
04bf JZ no
04c2 PUT #65
04c3 JMP
04bf JZ no
04c2 PUT #63
04c3 JMP
04bf JZ no
04c2 PUT #74
04c3 JMP
04bf JZ no
04c2 PUT #20
04c3 JMP
04bf JZ no
04c2 PUT #70
04c3 JMP
04bf JZ no
04c2 PUT #61
04c3 JMP
04bf JZ no
04c2 PUT #73
04c3 JMP
04bf JZ no
04c2 PUT #73
04c3 JMP
04bf JZ no
04c2 PUT #77
04c3 JMP
04bf JZ no
04c2 PUT #6f
04c3 JMP
04bf JZ no
04c2 PUT #72
04c3 JMP
04bf JZ no
04c2 PUT #64
04c3 JMP
04bf JZ no
04c2 PUT #21
04c3 JMP
04bf JZ no
04c2 PUT #0a
04c3 JMP
04bf JZ yes
04c6 RET
```

All right, there you have it. The code takes a input character, shifts it by a value (always 4 in this program), so we end up with the high nibble of the character value. Then the high nibble is xored with the character value and this is xored with the previous iteration value. If translated to python it looks like this:

```python
prev = 0
for c in flag:
    c = ((ord(c) >> 4)^ord(c))^prev
    prev = c
	#if not isvalid(c):
	#	print("incorrect password!")
	#	exit()
```

This can be reversed, and if we have a list of all the encrypted flag characters we can reconstruct the flag.
```python
buffer = []
for i in range(len(foo)-1, 0, -1):
    c = encryptedFlag[i] ^ encryptedFlag[i-1]
    buffer.append(chr((c>>4)^c))
```

And indeed we have the list, right in the code. The sequence of bytes is always the same 
```
05		XOR s(2), s(2) s(1)
0F		PUSH s(1)
0A XX	PUSH XX
```

So we can just scan the program code for `0F 0F 0A` and take the next byte. This gives us the following values `[0x72,0x1D,0x6F,0x0a,0x79,0x19,0x65,0x02,0x77,0x47,0x1d,0x63,0x50,0x22,0x78,0x4f,0x15,0x60,0x50,0x37,0x5d,0x07,0x76,0x1d,0x47,0x37,0x59,0x69,0x1c,0x2c,0x76,0x5c,0x3d,0x4a,0x39,0x63,0x02,0x32,0x5a,0x6a,0x1f,0x28,0x5b,0x6b,0x09,0x53,0x20,0x4e,0x7c,0x08,0x52,0x32,0x00,0x37,0x56,0x7d,0x07]`. Running the python script above on it gives the flag.

Flag `uiuctf{ar3_y0u_4_r3al_vm_wh3r3_(gpt_g3n3r4t3d_th1s_f14g)}`