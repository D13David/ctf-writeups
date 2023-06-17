# NahamCon 2023

## writeright

> Right, right? right? or left right? whatever.
>
>  Author: @BusesCanFly
>
> [`how_to_vesp.pdf`](how_to_vesp.pdf) [`writeright.vsp`](writeright.vsp)

Tags: _rev_

## Solution
Delivered are a howto and a '.vsp' file. Reading through the howto it becomes clear that the '.vsp' file contains a `VeSP (VEry Simple Processor)` program that needs to be reversed. The challenge is quite easy, we can just follow the instructions, step through the program (or let the program ran) and inspect the memory.

To get more insight here's the program dump with comments.

```
2000	LDA mem[0] = 0
0000
2001	LDA mem[1] = 0
0000
2001	LDA mem[1] = 4
0004
2000	LDA mem[0] = CB
00CB
0000	ADD mem[0], mem[1] -> mem[0]
3209	MOV mem[209] = mem[0]		; CF
0000
2001	LDA mem[1] = 7
0007
2000	LDA mem[0] = 6C
006C
0000	ADD mem[0] = mem[1] -> mem[0]
3180	MOV mem[180] = mem[0]		; 73
0000
2001	LDA mem[1] = 6
0006
2000	LDA mem[0] = 34
0034
0000	ADD mem[0] = mem[1]->mem[0]
312B	MOV mem[12b] = mem[0]		; 4A
0000
2001
0005
2000
00BF
0000
323B	; mem[23b] = C4
0000
2001
0007
2000
00EC
0000
3120	; mem[120] = F3
0000
2001
0003
2000
00F1
0000
3229	; mem[229] = F4
0000
2001
0005
2000
007C
0000
31D3	; mem[1d3] = 81
0000
2001
0005
2000
008B
0000
320F	; mem[20f] = 90
0000
2001
0008
2000
0018
0000
31D0	; mem[1d0] = 20
0000
2001
0003
2000
0047
0000
31D7	; mem[1d7] = 4a
0000
2001
0006
2000
008A
0000
31B8	; mem[1b8] = 90
0000
2001
0009
2000
002D
0000
317D	; mem[17d] = 36
0000
2001
0006
2000
0001
0000
31A9	; mem[1a9] = 7
0000
2001
0007
2000
009A
0000
318B	; mem[18b] = a1
0000
2001
0001
2000
00B3
0000
3200	; mem[200] = b4
0000
2001
0009
2000
0067
0000
3240	; mem[240] = 70
0000
7000
```

Its always the same sequence, adding two numbers and writing into memory. It takes a bit of guesswork that this is the hash of the flag, but if the values are concatinated and put together into 'flag{}' format this reveales the flag.

Flag `flag{cf733ac4f3f48190204a903607a1b470}`