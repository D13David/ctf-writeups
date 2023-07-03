# UIUCTF 2023

## vmwhere2

> Usage: ./chal program
>
>  Author: richard
>
> [`chal`](chal)
> [`program`](program)

Tags: _rev_

## Solution
This challenge is a continuation of [`vmwhere1`](../vmwhere1/README.md). The virtual machine is the same as before, but has three new instructions (well two new ones, but bit reverse was not used before):

```c
case 0x10: // bits reverse
{
	byte_t* rax_96 = code;
	code = (rax_96 + 1);
	byte_t rax_97 = *rax_96;
	TRACE(printf("BREV %d\n", rax_97));
	uint64_t rdx_28 = rax_97;
	if (rdx_28 > (stack - stackMem))
	{
		printf("Stack underflow in reverse at 0x%p %d", (code - incode), rdx_28);
	}
	for (int i = 0; i < (rax_97 >> 1); ++i)
	{
		char rax_107 = *(stack + (i - rax_97));
		*(stack + (i - rax_97)) = *(stack + (~i));
		*((~i) + stack) = rax_107;
	}
	break;
}
case 0x11: // bit expand
{
	TRACE(printf("BEXP\n"));
	byte_t var_30_1 = *(stack - 1);
	for (int var_28_1 = 0; var_28_1 <= 7; var_28_1 = (var_28_1 + 1))
	{
		*((stack - 1) + var_28_1) = (var_30_1 & 1);
		var_30_1 = (var_30_1 >> 1);
	}
	stack = (stack + 7);
	break;
}
case 0x12: // bit pack
{
	TRACE(printf("BPCK\n"));
	char var_2f_1 = 0;
	for (int var_24_1 = 7; var_24_1 >= 0; var_24_1 = (var_24_1 - 1))
	{
		var_2f_1 = ((var_2f_1 << 1) | ((stack - 8)[var_24_1] & 1));
	}
	*(stack - 8) = var_2f_1;
	stack = (stack - 7);
	break;
}
```

Note: I called `0x10` bit reverse, but in fact the instruction reverses a range of values on the stack. It doesn't have to be bit values, but I first encountered the instruction after `bit expand` was used. This instruction takes a value from stack and expands the value bits so instead of one item we have 8 items, for each bit one.

Ok, since we know already what the VM is doing, we check the program trace again. The start is the same as in `vmwhere1`, it prints a welcome message and an input prompt. 

Afterwards input is read, but instead of checking each character directly for validity the whole input is read, transformed in a way and stored on the stack.

```
0075 PUSH #00
0077 READ
uiuctf{00000000000000000000000000000000000000000000000000000000}

0078 BEXP		; expand the last read character bits
0079 PUSH #ff	; push ffh to stack
007b BREV 9		; reverse the first 9 items of the stack
007d BREV 8		; reverse the first 8 items of the stack
007f PUSH #00	; push 00h
```

This needs a bit of explanation. After the character value bits are expanded and written to stack the code pushes ffh to the stack. The value is used as end marker, so the program stops after processing the last bit. Since the end marker needs to be on the end, all 9 bits are reversed and afterwards the 8 chracter bits are reversed again, bringen them in original order but leaving the end marker in the correct position.

```
start:
; check if at end of bit list
0081 BREV 2			; reverse last two items on stack so next character bit is first in stack order
0083 PUSHS			; duplicate last bit value
0084 PUSH #ff		; push end marker (ffh)
0086 XOR s(2),s(1)	; check if last value is same as end marker
0087 JZ no			; if same, jump to end
008a POP			; clean up stack
008b JMP next_char:

; last character bit was processed
end:
008e POP
008f JMP
00a8 POP

next_char:
0092 BREV 2
0094 BREV 2 
0096 JZ bit_is_zero	; check if last bit zero

; bit is one --------
POP
PUSH 1
ADD
JMP merge_values

bit_is_zero:
00a0 POP			; if last bit was zero, just pop

merge_values:
00a1 PUSHS s(1)		; duplicate last stack item
00a2 PUSHS s(1)		; duplicate last stack item again
00a3 ADD s(2), s(1)
00a4 ADD s(2), s(1)
00a5 JMP start		; return to start
```

This whole part does basically a base3 encoding of the character. Translated to python it would be something like this.

```python
result = 0
for i in range(7, -1, -1):
	if (x >> i) & 1 == 1:
		result = (result + 1) * 3
	else:
		result = result * 3
	result = result % 256
return result
```

The transformed characters are stacked now neatly on the stack and the program starts to validate against it's own memory version. Here is how things are happening.

```
0973 PUSH #c6		; push the in memory value that is expected
0975 XOR c6 c6		; xor with last stack value
0976 BREV 46		; reverse list..
0978 BREV 47		; ...reverse again and fetch leading #00
097a OR	
097b BREV 46		; move result up (#00 is expected)
097d BREV 45		; bring values on stack in correct order

097f PUSH #8b
0981 XOR 8b 8b
0982 BREV 45
0984 BREV 46
0986 OR
0987 BREV 45
0989 BREV 44

...

0b9b JZ validation_ok
0b9e JMP fail
```

The same thing happens for all characters (above two are depicted). Initially top of the list contains a #00 value that is combined (with bitwise or) with the xor result. This means, if the value stays zero until all characters are checked everything is fine.

Since we have all the expected values, the flag can easily be bruteforced by iterating through a potential alphabet for each flag character and checking if the decoded version is equivalent to what is expected. Doing this for all the flag characters gives the flag.

```python
flag = [0xc6, 0x8b, 0xd9, 0xcf, 0x63, 0x60, 0xd8, 0x7b, 0xd8, 0x60, 0xf6, 0xd3, 0x7b, 0xf6, 0xd8, 0xc1, 0xcf, 0xd0, 0xf6, 0x72, 0x63, 0x75, 0xbe, 0xf6, 0x7f, 0xd8, 0x63, 0xe7, 0x6d, 0xf6, 0x63, 0xcf, 0xf6, 0xd8, 0xf6, 0xd8, 0x63, 0xe7, 0x6d, 0xb4, 0x88, 0x72, 0x70, 0x75, 0xb8, 0x75]

def decrypt(x):
    result = 0
    for i in range(7, -1, -1):
        if (x >> i) & 1 == 1:
            result = (result + 1) * 3
        else:
            result = result * 3
        result = result % 256
    return result

alphabet = "abcdefghijklmnopqrstuvwxyz0123456789_ {}"
result = ""
for item in flag:
    for c in alphabet:
        if decrypt(ord(c)) == item:
            result = c + result
            break

print(result)
```

The alphabet is restricted to lowercase letters (which was hinted on discord), numbers, underscore and curly braces.

Another possibility to bruteforce the flag is to use the VM itself for computation. Building the flag in the same fashion as decribed above and adding some code that checks the values on the stack for the currrent flag character. If the character doesn't match, restart with the next value from the alphabet, otherwise move to the next character. This as well gives the flag.

Flag `uiuctf{b4s3_3_1s_b4s3d_just_l1k3_vm_r3v3rs1ng}`