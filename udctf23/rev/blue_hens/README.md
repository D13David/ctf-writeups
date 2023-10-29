# UDCTF 2023

## Blue Hens

> Last year the feedback was "maybe not so many esolangs". I hear you. So I just wrote one. OK? The linguistic root of the word scholarly is "spare time".
> 
> **Blue Hens**
> 
> Your input is a file of code.
> 
> Each line has the word "blue" some number of times followed by the word "hens" some number of time (separated by spaces).
> 
> The number of "blues" on the line is the OPCODE the number of "hens" on that line is the ARG. The line numbers matter and they start at 1.
> 
> Our architecture has 2 variables, a register and a counter both start at 0.
> 
> OPCODES 1,2,3,4 are arithmetic operations:
> 
> 1 is SET: set the register to the ARG
> 
> 2 is ADD: add the ARG to the register
> 
> 3 is SUB: subtract ARG from the register
> 
> 4 is MUL: multiply the register by ARG
> 
> OPCODES 5,6,7 are gotos
> 
> 5 is GTL: go to line number ARG
> 
> 6 is GBL: go back ARG lines
> 
> 7 is GUL: go forward ARG lines
> 
> OPCODES 8,9,10 are control flow:
> 
> 8 is CTA: add ARG to counter
> 
> 9 is CTS: subtract ARG from counter
> 
> 10 is SKP: skip the next line IF counter is 0
> 
> OPCODE 11 is print:
> 
> 11 is PRT: print the value of the register (ascii)
>
> [`flag.bluehens`](flag.bluehens)

Tags: _rev_

## Solution

```python
mnem = {
    1 : "SET R {0:x}",
    2 : "ADD R {0:x}",
    3 : "SUB R {0:x}",
    4 : "MUL R {0:x}",
    5 : "GTL PC {0:x}",
    6 : "GBL PC {0:x}",
    7 : "GUL PC {0:x}",
    8 : "CTA C {0:x}",
    9 : "CTS C {0:x}",
    10 : "SKP {0:x}",
    11 : "PRT R {0:x}"
}

pc = 1
reg = 0
cnt = 0

code = []
lines = open("flag.bluehens", "r").readlines()
code = [(line.count("blue"), line.count("hens")) for line in lines]
code.insert(0, (0, 0))

while pc < len(code):
    op, arg = code[pc]

    m = mnem[op]
    #print(pc, m.format(arg))

    if op == 1:
        reg = arg
    elif op == 2:
        reg += arg
    elif op == 3:
        reg -= arg
    elif op == 4:
        reg *= arg
    elif op == 5:
        pc = arg
    elif op == 6:
        pc -= arg
    elif op == 7:
        pc += arg
    elif op == 8:
        cnt += arg
    elif op == 9:
        cnt -= arg
    elif op == 10:
        if cnt == 0:
            pc += 1
    elif op == 11:
        print(chr(reg), end="")

    if op < 5 or op > 7:
        pc += 1
```

Flag `UDCTF{fight_fight_fight_f0r_D3l4war3}`