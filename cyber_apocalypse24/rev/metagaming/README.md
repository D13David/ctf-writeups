# Cyber Apocalypse 2024

## Metagaming

> You come across an enemy faction, who have banded together and gathered their resources. You'll need to outwit them, thinking outside the box - can you beat them before they even begin to run?
> 
> Author: n/a
> 
> [`rev_metagaming.zip`](rev_metagaming.zip)

Tags: _rev_

## Solution
For this challenge we get some (horrible) meta-programming-style c++ code. The code is quite lenghty but it boils down to be a VM, which is run fully at compiletime. We have the `program_t` with the `execute_one` function which executes one instruction. The instructions are quite clear visible in one big `if-else` construct.

```cpp
template<flag_t Flag, insn_t... Instructions>
struct program_t {
    using R = std::array<uint32_t, 15>;

    template<insn_t Insn>
    static constexpr void execute_one(R &regs) {
        if constexpr (Insn.opcode == 0) {
            regs[Insn.op0] = Flag.at(Insn.op1);
        } else if constexpr (Insn.opcode == 1) {
            regs[Insn.op0] = Insn.op1;
        } else if constexpr (Insn.opcode == 2) {
            regs[Insn.op0] ^= Insn.op1;
        } else if constexpr (Insn.opcode == 3) {
            regs[Insn.op0] ^= regs[Insn.op1];
...
```

A bit further down we find the program instructions:

```cpp
using program = program_t<flag, insn_t(12, 13, 10), insn_t(21, 0, 0), insn_t(0, 13, 13), insn_t(0, 14, 0), insn_t(15, 11, 12), insn_t(24, 14, 0), insn_t(5, 0, 14), insn_t(0, 14, 1), insn_t(7, 11, 11), insn_t(24, 14, 8), insn_t(5, 0, 14), insn_t(0, 14, 2), insn_t(2, 10, 11), insn_t(24, 14, 16), insn_t(18, 12, 11), insn_t(5, 0, 14), insn_t(0, 14, 3), insn_t(0, 11, 11), insn_t(24, 14, 24), insn_t(13, 10, 10), insn_t(5, 0, 14), insn_t(2, 11, 13), insn_t(21, 1, 0), insn_t(0, 14, 4), insn_t(24, 14, 0), insn_t(5, 1, 14), insn_t(6, 11, 12), insn_t(0, 14, 5), insn_t(8, 10, 10), insn_t(24, 14, 8), insn_t(11, 12, 11), ...
```

To better analyze this, I copied the instructions and put them into a python program. Also I implemented the pendant of `execute_one` to be able to print the `mnemonics` and parameters so we get a basic disassembly of this program.

```python
prg = [12, 13, 10,
21, 0, 0,
0, 13, 13,
0, 14, 0,
15, 11, 12,
24, 14, 0,
5, 0, 14,
...
18, 10, 13,
2, 9, 477834410,
19, 13, 12,
3, 0, 1,
12, 12, 12,
3, 1, 2,
11, 13, 11,
3, 2, 3,
3, 3, 4,
3, 4, 5,
1, 13, 13,
3, 5, 6,
7, 11, 11,
3, 6, 7,
4, 10, 12,
3, 7, 8,
18, 12, 12,
3, 8, 9,
21, 12, 10,
3, 9, 10]

def info(opcode, op0, op1):
    if opcode == 14 or opcode == 15:
        return ""
    match opcode:
        case 0:
            return f"= flag[{op1}]"
        case 1:
            return f"= {op1}"
        case 2:
            return f"^= {op1}"
        case 3:
             return f"^= regs[{op1}]"
        case 4:
             return f"|= {op1}"
        case 5:
            return f"|= regs[{op1}]"
        case 6:
            return f"&= {op1}"
        case 7:
            return f"&= regs[{op1}]"
        case 8:
            return f"+= {op1}"
        case 9:
            return f"+= regs[{op1}]"
        case 10:
            return f"-= {op1}"
        case 11:
            return f"-= regs[{op1}]"
        case 12:
            return f"*= {op1}"
        case 13:
            return f"*= regs[{op1}]"
        case 16:
            return f"= ror(regs[{op0}], {op1})"
        case 17:
            return f"= ror(regs[{op0}], regs[{op1}])"
        case 18:
            return f"= rol(regs[{op0}], {op1})"
        case 19:
            return f"= rol(regs[{op0}], regs[{op1}])"
        case 20:
            return f"= regs[{op1}]"
        case 21:
            return f"= 0"
        case 22:
            return f">>= {op1}"
        case 23:
            return f">>= regs[{op1}]"
        case 24:
            return f"<<= {op1}"
        case 25:
            return f"<<= regs[{op1}]"
```

The output is a mess though and with `436` lines too long to make really sense of.

```bash
regs[13] *= 10
regs[0] = 0
regs[13] = flag[13]
regs[14] = flag[0]
regs[0] |= regs[14]
regs[14] = flag[1]
regs[11] &= regs[11]
regs[14] <<= 8
regs[0] |= regs[14]
regs[14] = flag[2]
regs[10] ^= 11
regs[14] <<= 16
regs[12] = rol(regs[12], 11)
regs[0] |= regs[14]
regs[14] = flag[3]
regs[11] = flag[11]
regs[14] <<= 24
regs[10] *= regs[10]
regs[0] |= regs[14]
...
```

So i checked the flag condition. There are 15 registers and every register has to hold a specific value when the program ends. The first thought was to let the program run backwards but many of the operations are not reversible easily.

```cpp
static_assert(program::registers[0] == 0x3ee88722 && program::registers[1] == 0xecbdbe2 && program::registers[2] == 0x60b843c4 && program::registers[3] == 0x5da67c7 && program::registers[4] == 0x171ef1e9 && program::registers[5] == 0x52d5b3f7 && program::registers[6] == 0x3ae718c0 && program::registers[7] == 0x8b4aacc2 && program::registers[8] == 0xe5cf78dd && program::registers[9] == 0x4a848edf && program::registers[10] == 0x8f && program::registers[11] == 0x4180000 && program::registers[12] == 0x0 && program::registers[13] == 0xd && program::registers[14] == 0x0, "Ah! Your flag is invalid.");
```

To clean up things, I started for one single register to walk backwards and print only instructions where the register was written or where any dependent registers (registers that somehow contribute to the state of the register we are looking at) where written. Lets start with register `0`.

```python
indirect_ops = [0, 3, 5, 7, 9, 11, 13, 17, 19, 20, 23, 25]

reg = 0
deps = [reg]
lines = []
for i in range(len(prg)-3, -1, -3):
    opcode = prg[i+0]
    op0 = prg[i+1]
    op1 = prg[i+2]

    if not op0 in deps:
        continue

    if opcode in indirect_ops:
        deps.append(op1)

    lines.append(f"regs[{op0}] {info(opcode, op0, op1)}")

for l in lines[::-1]:
    print(l)
```

Thats the full trace, much denser and cleaner. The structure is actually readable:

```bash
# initialize with value 0
regs[0] = 0
# get first flag character, shift 0 bytes to the left and do a bitwise or with register 0
regs[14] = flag[0]
regs[14] <<= 0
regs[0] |= regs[14]
# get second flag character, shift 8 bytes to the left and do a bitwise or with register 0
regs[14] = flag[1]
regs[14] <<= 8
regs[0] |= regs[14]
# get third flag character, shift 16 bytes to the left and do a bitwise or with register 0
regs[14] = flag[2]
regs[14] <<= 16
regs[0] |= regs[14]
# get fourth flag character, shift 24 bytes to the left and do a bitwise or with register 0
regs[14] = flag[3]
regs[14] <<= 24
regs[0] |= regs[14]
# this block can be ignored... it does not have immediate impact on register 0 anymore ----->
regs[1] = 0
regs[14] = flag[4]
regs[14] <<= 0
regs[1] |= regs[14]
regs[14] = flag[5]
regs[14] <<= 8
regs[1] |= regs[14]
regs[14] = flag[6]
regs[14] <<= 16
regs[1] |= regs[14]
regs[14] = flag[7]
regs[14] <<= 24
regs[1] |= regs[14]
# <-----

# do some weird calculations on register 0
regs[0] += 2769503260
regs[0] -= 997841014
regs[0] ^= 4065997671
regs[0] += 690011675
regs[0] += 540576667
regs[0] ^= 1618285201
regs[0] += 1123989331
regs[0] += 1914950564
regs[0] += 4213669998
regs[0] += 1529621790
regs[0] -= 865446746
regs[0] += 449019059
regs[0] += 906976959
regs[0] += 892028723
regs[0] -= 1040131328
regs[0] ^= 3854135066
regs[0] ^= 4133925041
regs[0] ^= 1738396966
regs[0] += 550277338
regs[0] -= 1043160697
regs[1] ^= 1176768057
regs[1] -= 2368952475
regs[1] ^= 2826144967
regs[1] += 1275301297
regs[1] -= 2955899422
regs[1] ^= 2241699318
regs[1] += 537794314
regs[1] += 473021534
regs[1] += 2381227371
regs[1] -= 3973380876
regs[1] -= 1728990628
regs[1] += 2974252696
regs[1] += 1912236055
regs[1] ^= 3620744853
regs[1] ^= 2628426447
regs[1] -= 486914414
regs[1] -= 1187047173
# xor with value of register 1
regs[0] ^= regs[1]
```

What the code does is, pack 4 flag characters in one register, do some calculations and then xor with the value of the next register. This process is exactly the same for every register (except for the last registers). But since there is a dependency to the register n+1 we have to go backwards to resolve the flag values. 

So starting with register 14:

```bash
...
regs[14] <<= 8
regs[14] = flag[38]
regs[14] <<= 16
regs[14] = flag[39]
regs[14] <<= 24
regs[14] = 0
```

the output is rather lengthy again, but it doesnt matter. The register is set to 0 in the last operation, so everything above can be "optimized away" for *this* register. And it also matches the expected value. The same thing for register 13 and 12.

```bash
...
regs[13] = ror(regs[13], 10)
regs[11] += 13
regs[11] = ror(regs[11], 13)
regs[12] &= 12
regs[12] -= 12
regs[13] = rol(regs[13], regs[12])
regs[13] -= regs[11]
regs[13] = 13
```

But then register 11 comes and things get exciting:

```bash
...
regs[13] = flag[13]
regs[13] = regs[11]
regs[12] |= regs[10]
regs[12] = 0
regs[10] |= 12
regs[10] = rol(regs[10], 13)
regs[10] ^= regs[13]
regs[11] &= regs[10]
regs[11] = rol(regs[11], regs[12])
# everything above here we can ignore, since there is no immediate effect anymore on register 11
regs[11] = flag[12]
regs[11] += 13
regs[11] = ror(regs[11], 13)
regs[11] &= regs[11]
```

The code is takes `flag[12]`, adds 13 to it and does a ror (rotate bit right) of 13 bits. This can be reversed quickly, and gives us `flag[12] = v`. Lets continue with register 10, I commented out the instruction which can be ignored in this trace.

```bash
# ...
...
# ...
regs[11] = flag[12]
#regs[10] |= regs[10]
#regs[10] = flag[10]
regs[11] += 13
regs[11] = ror(regs[11], 13)
#regs[10] *= regs[11]
regs[10] = regs[11]
regs[10] = rol(regs[10], 13)
regs[10] |= 12
```

We an verify this, we know `flag[12]` and can calculate register 10 which will end up with value `0x8f` which is exactly the expectation at program stop. From now on things get more exciting, but also repetitive, since we see the pattern we saw for register 0 for all the following registers until register 9. To get the values we can bruteforce the characters. Lets take register 9 as an example:

```bash
...
# flag values 36-39 are packed into register 9 (unimportant instructions being commented out)
regs[9] = 0
regs[14] = flag[36]
regs[14] <<= 0
regs[9] |= regs[14]
#regs[11] = ror(regs[11], regs[11])
regs[14] = flag[37]
regs[14] <<= 8
regs[9] |= regs[14]
#regs[10] |= 11
regs[14] = flag[38]
regs[11] *= regs[13]
regs[14] <<= 16
regs[9] |= regs[14]
regs[14] = flag[39]
#regs[11] -= 10
regs[14] <<= 24
#regs[13] = regs[13]
regs[9] |= regs[14]
...
# calculations are done on register 9
regs[9] -= 532704100
regs[9] -= 2519542932
regs[9] ^= 2451309277
regs[9] ^= 3957445476
#regs[10] |= regs[10]
regs[9] += 2583554449
regs[9] -= 1149665327
regs[9] += 3053959226
#regs[10] = flag[10]
regs[9] += 3693780276
regs[9] ^= 609918789
regs[9] ^= 2778221635
regs[9] += 3133754553
#regs[11] += 13
regs[9] += 3961507338
regs[9] ^= 1829237263
#regs[11] = ror(regs[11], 13)
regs[9] ^= 2472519933
regs[9] += 4061630846
regs[9] -= 1181684786
#regs[10] *= regs[11]
regs[9] -= 390349075
regs[9] += 2883917626
regs[9] -= 3733394420
regs[9] ^= 3895283827
#regs[10] = regs[11]
regs[9] ^= 2257053750
regs[9] -= 2770821931
#regs[10] = rol(regs[10], 13)
regs[9] ^= 477834410
#regs[10] |= 12
# final xor with register 10
regs[9] ^= regs[10]
```

We can try to create the inverse for this method. But we also can just bruteforce the four characters. After a few seconds we have `7b0}`.

```cpp
int main()
{
    for (int i = 0; i < 255; ++i)
    {
        for (int j = 0; j < 255; ++j)
        {
            for (int k = 0; k < 255; ++k)
            {
                for (int l = 0; l < 255; ++l)
                {
                    uint32_t reg = (l << 24) | (k << 16) | (j << 8) | i;

                    reg -= 532704100,
                    reg -= 2519542932;
                    reg ^= 2451309277;
                    reg ^= 3957445476;
                    reg += 2583554449;
                    reg -= 1149665327;
                    reg += 3053959226;
                    reg += 3693780276;
                    reg ^= 609918789;
                    reg ^= 2778221635;
                    reg += 3133754553;
                    reg += 3961507338;
                    reg ^= 1829237263;
                    reg ^= 2472519933;
                    reg += 4061630846;
                    reg -= 1181684786;
                    reg -= 390349075;
                    reg += 2883917626;
                    reg -= 3733394420;
                    reg ^= 3895283827;
                    reg ^= 2257053750;
                    reg -= 2770821931;
                    reg ^= 477834410;

                    reg = reg ^ 0x8f /*reg[10]*/;

                    if (reg == 0x4a848edf /*target value of reg[9]*/)
                    {
                        printf("%c%c%c%c", i, j, k, l);
                        break;
                    }
                }
            }
        }
    }
}
```

This we do for every register 8, 7, 6, 5... until we have the full flag.

Flag `HTB{m4n_1_l0v4_cXX_TeMpl4t35_9fb60c17b0}`