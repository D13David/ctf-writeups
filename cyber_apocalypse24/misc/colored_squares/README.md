# Cyber Apocalypse 2024

## Colored Squares

> In the heart of an ancient forest stands a coloured towering tree, its branches adorned with countless doors. Each door, when opened, reveals a labyrinth of branching paths, leading to more doors beyond. As you venture deeper into the maze, the forest seems to come alive with whispered secrets and shifting shadows. With each door opened, the maze expands, presenting new choices and challenges at every turn. Can you understand what's going on and get out of this maze?
> 
> Author: aris
> 
> [`misc_colored_squares.zip`](misc_colored_squares.zip)

Tags: _misc_

## Solution
We get a zip archive full of heaps of folders, but no files. This sure looks like [`Folders Language`](https://esolangs.org/wiki/Folders). There is a nice [`implementation`](https://github.com/rottytooth/Folders/tree/main) that also transpiles folders code to c#. Since I had trouble extracting the archive on windows, I wrote an (incomplete) folder to pseudocode [`transpiler`](transpiler.py), that is just feature complete enough to handle this specific case. Running it gave the following pseudocode:

```python
print("Enter the flag in decimal (one character per line) :\n")

_0 = input()
_1 = input()
_2 = input()
_3 = input()
_4 = input()
_5 = input()
_6 = input()
_7 = input()
_8 = input()
_9 = input()
_10 = input()
_11 = input()
_12 = input()
_13 = input()
_14 = input()
_15 = input()
_16 = input()
_17 = input()
_18 = input()
_19 = input()
_20 = input()
_21 = input()

if ((_7-_18)==(_8-_9))
 if ((_6+_10)==((_16+_20)+12))
  if ((_8*_14)==((_13*_18)*2))
   if (_19==_6)
    if ((_9+1)==(_17-1))
     if ((_11//(_5+7))==2)
      if ((_5+(_2//2))==_1)
       if ((_16-9)==(_13+4))
        if ((_12//3)==17)
         if (((_4-_5)+_12)==(_14+20))
          if (((_12*_15)//_14)==24)
           if (_18==(173-_4))
            if (_6==(63+_5))
             if ((32*_16)==(_7*_0))
              if (125==_21)
               if ((_3-_2)==57)
                if ((_17-_15)==(_18+1))
                 print("Good job! :)")
```

So, another case for [`z3`](https://ericpony.github.io/z3py-tutorial/guide-examples.htm). With a bit of manual help it was able to retrieve the flag.

```python
from z3 import *

_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21 = Ints('_0 _1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21')

solver = Solver()

solver.add(_0 == ord('H'))
solver.add(_1 == ord('T'))
solver.add(_2 == ord('B'))
solver.add(_3 == ord('{'))
solver.add(_5 == ord('3'))
solver.add(_6 == ord('r'))
solver.add(_11 == ord('t'))
solver.add(_12 == ord('3'))
solver.add(_19 == ord('r'))
solver.add(_21 == ord('}'))
solver.add(_10 == ord('y'))
solver.add((_7-_18)==(_8-_9))
solver.add((_6+_10)==((_16+_20)+12))
solver.add((_8*_14)==((_13*_18)*2))
solver.add((_9+1)==(_17-1))
solver.add((_16-9)==(_13+4))
solver.add(((_4-_5)+_12)==(_14+20))
solver.add(((_12*_15)/_14)==24)
solver.add(_18==(173-_4))
solver.add((32*_16)==(_7*_0))
solver.add((_17-_15)==(_18+1))

for var in [_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21]:
    solver.add(var >= 32)

if solver.check() == sat:
    model = solver.model()
    for var in [_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21]:
        print(chr(model[var].as_long()),end="")
```

Flag `HTB{z3r0_byt3_f0ld3rs}`