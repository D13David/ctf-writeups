# PearlCTF 2024

## byteme

> I know you are a python expert, but can you reverse this?
>
>  Author: TheAlpha
>
> [`byteme.pyc`](byteme.pyc)

Tags: _rev_

## Solution
This challange comes with a compiled python script. There are nice [`decompilers`](https://github.com/zrax/pycdc) for this, but they are mostly lacking support for really new python versions. So, not surprising, the decompiler doesn't want to work.

From the hexdump, we can see that the magic number (first four bytes are `0a0d0df0`). We can [`see`](https://github.com/python/cpython/blob/5b2f21faf388d8de5b388996cfd4f03430085764/Lib/importlib/_bootstrap_external.py#L467C21-L467C25) that this is corresponding to `Python 3.13a1 3568`. So lets grab the correct python version.

```bash
00000000  f0 0d 0d 0a 00 00 00 00  47 16 e8 65 42 25 00 00  |........G..eB%..|
```

```python
import marshal, dis

with open("byteme.pyc", "rb") as file:
    file.seek(16)
    print(dis.dis(marshal.load(file)))
```

Running this (with python 3.13), gives us a somewhat lenghty [`result`](decomp.asm). We can reverse this by hand (or we can adapt `pycdc` to support the new bytecodes). Either way, we find there are three functions that are called and every one of them gives us one part of the flag. Lets start at the top.

```python
  0           0 RESUME                   0

             # from hashlib import md5
  1           2 LOAD_CONST               0 (0)
              4 LOAD_CONST               1 (('md5',))
              6 IMPORT_NAME              0 (hashlib)
              8 IMPORT_FROM              1 (md5)
             10 STORE_NAME               1 (md5)
             12 POP_TOP

             # import time
  2          14 LOAD_CONST               0 (0)
             16 LOAD_CONST               2 (None)
             18 IMPORT_NAME              2 (time)
             20 STORE_NAME               2 (time)

             # make function for "crackme"
  4          22 LOAD_CONST               3 (<code object crackme at 0x558a3158ccd0, file "byteme.py", line 4>)
             24 MAKE_FUNCTION
             26 STORE_NAME               3 (crackme)

             # make function for "solveme"
 55          28 LOAD_CONST               4 (<code object solveme at 0x558a315b3210, file "byteme.py", line 55>)
             30 MAKE_FUNCTION
             32 STORE_NAME               4 (solveme)

             # make function for "breakme"
142          34 LOAD_CONST               5 (<code object breakme at 0x558a31538040, file "byteme.py", line 142>)
             36 MAKE_FUNCTION
             38 STORE_NAME               5 (breakme)

             # if __name__ == '__main__':
245          40 LOAD_NAME                6 (__name__)
             42 LOAD_CONST               6 ('__main__')
             44 COMPARE_OP              88 (bool(==))
             48 POP_JUMP_IF_FALSE       97 (to 246)

             # spell = crackme()
246          52 LOAD_NAME                3 (crackme)
             54 PUSH_NULL
             56 CALL                     0
             64 STORE_NAME               7 (spell)

             # answer = solveme()
247          66 LOAD_NAME                4 (solveme)
             68 PUSH_NULL
             70 CALL                     0
             78 STORE_NAME               8 (answer)

             # chain = breakme()
248          80 LOAD_NAME                5 (breakme)
             82 PUSH_NULL
             84 CALL                     0
             92 STORE_NAME               9 (chain)

             # print('Thalor has risen!')
250          94 LOAD_NAME               10 (print)
             96 PUSH_NULL
             98 LOAD_CONST               7 ('Thalor has risen!')
            100 CALL                     1
            108 POP_TOP

            # print('The prophecy has been fulfilled')
251         110 LOAD_NAME               10 (print)
            112 PUSH_NULL
            114 LOAD_CONST               8 ('The prophecy has been fulfilled')
            116 CALL                     1
            124 POP_TOP

            # print()
252         126 LOAD_NAME               10 (print)
            128 PUSH_NULL
            130 CALL                     0
            138 POP_TOP

            # print('#######################################')
253         140 LOAD_NAME               10 (print)
            142 PUSH_NULL
            144 LOAD_CONST               9 ('#######################################')
            146 CALL                     1
            154 POP_TOP

            # print('##                                 ##')
254         156 LOAD_NAME               10 (print)
            158 PUSH_NULL
            160 LOAD_CONST              10 ('##')
            162 LOAD_CONST              11 ('                                 ')
            164 LOAD_CONST              10 ('##')
            166 CALL                     3
            174 POP_TOP

            # print(f'## {spell}{answer}{chain} ##')
255         176 LOAD_NAME               10 (print)
            178 PUSH_NULL
            180 LOAD_CONST              10 ('##')
            182 LOAD_NAME                7 (spell)
            184 FORMAT_SIMPLE
            186 LOAD_NAME                8 (answer)
            188 FORMAT_SIMPLE
            190 LOAD_NAME                9 (chain)
            192 FORMAT_SIMPLE
            194 BUILD_STRING             3
            196 LOAD_CONST              10 ('##')
            198 CALL                     3
            206 POP_TOP

            # print('##                                 ##')
256         208 LOAD_NAME               10 (print)
            210 PUSH_NULL
            212 LOAD_CONST              10 ('##')
            214 LOAD_CONST              11 ('                                 ')
            216 LOAD_CONST              10 ('##')
            218 CALL                     3
            226 POP_TOP

            # print('#######################################')
257         228 LOAD_NAME               10 (print)
            230 PUSH_NULL
            232 LOAD_CONST               9 ('#######################################')
            234 CALL                     1
            242 POP_TOP
            244 RETURN_CONST             2 (None)

245     >>  246 RETURN_CONST             2 (None)
```

Or in vanilla python:

```python
from hashlib import md5
import time

def crackme():
    pass

def solveme():
    pass

def breakme():
    pass

if __name__ == '__main__':
    spell = crackme()
    answer = solveme()
    chain = breakme()

    print('Thalor has risen!')
    print('The prophecy has been fulfilled')
    print()
    print('#######################################')
    print('##                                   ##')
    print(f'## {spell}{answer}{chain} ##')
    print('##                                   ##')
    print('#######################################')
```

Next on `crackme`. Doing the transformation of disassembly to python code by hand, gives us the following:

```python
def crackme():
    print("                           o                    \n                       _---|         _ _ _ _ _ \n                    o   ---|     o   ]-I-I-I-[ \n   _ _ _ _ _ _  _---|      | _---|    \\ ` ' / \n   ]-I-I-I-I-[   ---|      |  ---|    |.   | \n    \\ `   '_/       |     / \\    |    | /^\\| \n     [*]  __|       ^    / ^ \\   ^    | |*|| \n     |__   ,|      / \\  /    `\\ / \\   | ===| \n  ___| ___ ,|__   /    /=_=_=_=\\   \\  |,  _|\n  I_I__I_I__I_I  (====(_________)___|_|____|____\n  \\-\\--|-|--/-/  |     I  [ ]__I I_I__|____I_I_| \n   |[]      '|   | []  |`__  . [  \\-\\--|-|--/-/  \n   |.   | |' |___|_____I___|___I___|---------| \n  / \\| []   .|_|-|_|-|-|_|-|_|-|_|-| []   [] | \n <===>  |   .|-=-=-=-=-=-=-=-=-=-=-|   |    / \\  \n ] []|`   [] ||.|.|.|.|.|.|.|.|.|.||-      <===> \n ] []| ` |   |/////////\\\\\\\\\\.||__.  | |[] [ \n <===>     ' ||||| |   |   | ||||.||  []   <===>\n  \\T/  | |-- ||||| | O | O | ||||.|| . |'   \\T/ \n   |      . _||||| |   |   | ||||.|| |     | |\n../|' v . | .|||||/____|____\\|||| /|. . | . ./\n.|//\\............/...........\\........../../\\\n")
    print()

    print("Welcome Warrior! You have made it till here")
    print("This is where best of the best have fallen prey to the fate")
    print()

    print("It is written that only the true Thalor can get The sword of Eldoria")
    print("Do you have what it takes to be Thalor?")
    print("Prove your mettle by bringing the sword out of the castle")
    print()

    print("Go on! unlock the castle with XEKLEIDOMA spell")
    print()

    spell = input("> ")
    print()

    if len(spell.strip()) != 12 or md5(spell.strip().encode()).hexdigest() != "9ce86143889d80b01586f8a819d20f0c":
        print("You are not THE ONE")
        print("True Thalor is a master of sorcery")
        print("Ground beneath you opens up and you fall into the depths of hell")
        exit()

    print("The door is opened!")
    print("You surely mastered sorcery")
    print()

    time.sleep(3)

    return spell
```

So we need to find a input with length of 12 characters and with the matching hashsum. Since we can assume that we need to pass in the flag, we know the first 6 characters already due to the flag format: `pearl{`. The remaining 6 characters we can bruteforce:

```python
import hashlib
import itertools

def generate_permutations():
    characters = 'abcdefghijklmnopqrstuvwxyz0123456789_'
    permutations = itertools.product(characters, repeat=6)
    return (''.join(p) for p in permutations)

def calculate_md5(text):
    return hashlib.md5(text.encode()).hexdigest()

if __name__ == "__main__":
    for permutation in generate_permutations():
        md5_hash = calculate_md5("pearl{" + permutation)
        if md5_hash in "9ce86143889d80b01586f8a819d20f0c":
            print(permutation)
            exit()
```

Running this, gives us the magic spell `pearl{e4sy_p`. The second function is `solveme` and the reconstructed code looks like the following:

```python
def solveme():
    print("\n                                            .""--..__\n                     _                     []       ``-.._\n                  .\'` `\'.                  ||__           `-._\n
  /    ,-.\\                 ||_ ```---..__     `-.\n                /    /:::\\               /|//}          ``--._  `.\n                |    |:::||              |////}                `. |\n                |    |:::||             //\'///                   -\n                |    |:::||            //  ||\'     \n                /    |:::|/        _,-//\\  ||\n               /`    |:::|`-,__,-\'`  |/  \\ ||\n             /`  |   |\'\' ||           \\   |||\n           /`    \\   |   ||            |  /||\n         |`       |  |   |)            \\ | ||\n        |          \\ |   /      ,.__    \\| ||\n        /           `         /`    `\\   | ||\n       |                     /        \\  / ||\n       |                     |        | /  ||\n       /         /           |        `(   ||\n      /          .           /
)  ||\n     |            \\          |     ________||\n    /             |          /     `-------.|\n   |\\            /          |              ||\n   \\/`-._       |           /              ||\n    //   `.    /`           |              ||\n   //`.    `. |             \\              ||\n  ///\\ `-._  )/             |              ||\n //// )   .(/               |              ||\n ||||   ,\'` )               /              //\n ||||  /                    /             || \n `\\` /`                    |             // \n     |`                     \\            ||  \n    /                        |           //  \n  /`                          \\         //   \n/`                            |        ||    \n`-.___,-.      .-.        ___,\'        (/    \n         `---\'`   `\'----\'`\n")
    print()

    print("As you walk in, you see a spectral figure Elyrian, the Guardian of Souls")
    print("He speaks to you in a voice that echoes through the chamber")
    print()

    print('"Brave warrior, before you lies the next trial on your path. Answer my riddle, and prove your worthiness to continue your quest."')
    print('\n"I am a word of ten, with numbers and letters blend,\nUnravel me, and secrets I\'ll send.\nThough cryptic in sight, I hold the code tight,\nUnlock my mystery with wit and might."\n')

    answer = input("> ")
    print()

    answer = list(map(ord, list(answer.strip())))

    try:
        assert(len(answer) == 10)
        assert(answer[6] + answer[7] + answer[8] - answer[5] == 190)
        assert(answer[6] + answer[5] + answer[5] - answer[2] == 202)
        assert(answer[9] + answer[3] + answer[2] + answer[5] == 433)
        assert(answer[7] + answer[0] - answer[0] + answer[3] == 237)
        assert(answer[1] - answer[9] - answer[5] + answer[4] == -50)
        assert(answer[2] - answer[3] + answer[1] - answer[1] == -6)
        assert(answer[8] - answer[7] - answer[6] + answer[5] == -88)
        assert(answer[0] + answer[8] - answer[5] - answer[3] == -117)
        assert(answer[5] + answer[6] + answer[8] + answer[2] == 385)
        assert(answer[5] - answer[4] - answer[5] + answer[9] == 4)
        assert(answer[2] - answer[9] + answer[5] - answer[0] == 63)
        assert(answer[2] - answer[5] + answer[4] - answer[9] == 13)
        assert(answer[8] + answer[3] + answer[7] - answer[6] == 167)
        assert(answer[6] - answer[5] - answer[0] - answer[5] == -126)
        assert(answer[2] - answer[5] - answer[6] - answer[4] == -199)
    except AssertionError:
        print("You are not worthy")
        print("Your soul has been cursed")
        print("You will seek your own death in a fortnight")
        exit()

    print("You have proven your `wit and might`")
    print("Elyrian, the Guardian of Souls, bows to you")
    print("You have unlocked the next chamber")
    print()

    time.sleep(4)

    return "".join([chr(x) for x in answer])
```

This time, the user input needs to be 10 characters and we have a whole lot of constraints that need to be fulfilled. Constraints call for `SAT`, so we use `z3` to get the answer.

```python
from z3 import *

answer = [Int(f"answer{i}") for i in range(10)]

solver = Solver()

solver.add(answer[6] + answer[7] + answer[8] - answer[5] >= 190)
solver.add(answer[6] + answer[5] + answer[5] - answer[2] >= 202)
solver.add(answer[9] + answer[3] + answer[2] + answer[5] >= 433)
solver.add((answer[7] + answer[0] - answer[0]) + answer[3] >= 237)
solver.add((answer[1] - answer[9] - answer[5]) + answer[4] >= -50)
solver.add((answer[2] - answer[3]) + answer[1] - answer[1] >= -6)
solver.add((answer[8] - answer[7] - answer[6]) + answer[5] >= -88)
solver.add(answer[0] + answer[8] - answer[5] - answer[3] >= -117)
solver.add(answer[5] + answer[6] + answer[8] + answer[2] >= 385)
solver.add((answer[5] - answer[4] - answer[5]) + answer[9] >= 4)
solver.add((answer[2] - answer[9]) + answer[5] - answer[0] >= 63)
solver.add((answer[2] - answer[5]) + answer[4] - answer[9] >= 13)
solver.add(answer[8] + answer[3] + answer[7] - answer[6] >= 167)
solver.add(answer[6] - answer[5] - answer[0] - answer[5] >= -126)
solver.add(answer[2] - answer[5] - answer[6] - answer[4] >= -199)

if solver.check() == sat:
    model = solver.model()
    print("Solution found:")
    for i in range(10):
        print(f"{chr(model[answer[i]].as_long())}", end="")
else:
    print("No solution found")
```

Running this gives us the second part of the flag: `34sy_byt3c`. One part to go... Moving on to `breakme`. The reconstructed code looks like this:

```python
def breakme():
    sword = "\n                      _..._\n                     /MMMMM\\\n                    (I8H#H8I)\n                    (I8H#H8I)\n                     \\WWWWW/\n                      I._.I\n
          I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I._.I\n                      I.,.I\n
   / /#\\ \\\n                   .dH# # #Hb.\n               _.~d#XXP I 7XX#b~,_\n            _.dXV^XP^ Y X Y ^7X^VXb._\n           /AP^   \\PY   Y   Y7/   ^VA\\\n          /8/      \\PP  I  77/      \\8\\\n         /J/        IV     VI        \\L\\\n         L|         |  \\ /  |         |J\n         V          |  | |  |          V\n                    |  | |  |\n                    |  | |  |\n
|  | |  |\n                    |  | |  |\n _                  |  | |  |                  _\n( \\                 |  | |  |                 / )\n \\ \\                |  | |  |                / /\n('\\ \\               |  | |  |               / /`)\n \\ \\ \\              |  | |  |              / / /\n('\\ \\ \\             |  | |  |             / / /`)\n \\ \\ \\ )            |  | |  |            ( / / /\n('\\ \\( )            |  | |  |            ( )/ /`)\n \\ \\ ( |            |  | |  |            | ) / /\n  \\ \\( |            |  | |  |            | )/ /\n   \\ ( |            |  | |  |            | ) /\n    \\( |            |   Y   |            | )/\n     | |            |   |   |            | |\n     J | ___...~~--'|   |   |`--~~...___ | L\n     >-+<...___     |   |   |     ___...>+-<\n    /     __   `--~.L___L___J.~--'   __     \\\n    K    /  ` --.     d===b     .-- '  \\    H\n    \\_._/        \\   // I \\   /        \\_._/\n      `--~.._     \\__\\ I //__/     _..~--'\n             `--~~..____ ____..~~--'\n
     |   T   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    |   |   |\n                    I   '   I\n                     \\     /\n                      \\   /\n                       \\ /\n                       "

    sword = sword.split("\n")
    for line in sword:
        print(line)
        time.sleep(0.1)

    print()
    print("There it is! The sword of Eldoria")
    print("Break it's shackles and show that you are the Thalor")
    print()

    chain = input("> ")

    best = [117, 84, 87, 108, 59, 85, 66, 71, 71, 30, 16]
    mod = []
    plier = 69

    for i in range(len(chain)):
        mod.append(ord(chain[i]) ^ plier)
        plier = ord(chain[i])

    if mod == best:
        print("Oh! True Thalor, you have broken the shackles")
        print("You are the chosen one")
        print("I kneel before you")
        print("Go on! Take the sword and fulfill your destiny")
        print()

        time.sleep(2)

        return chain

    print("You are not worthy")
    print("The fate has you in it's grip")
    print("You will be forgotten in the sands of time")
    exit()
```

The input is processed with some xor magic and we check if the result is identical with the values in `best`. This can be reversed easily:

```python
mod = [117, 84, 87, 108, 59, 85, 66, 71, 71, 30, 16]
plier = 69

for i in mod:
    print(chr(i^plier),end="")
    plier = i ^ plier
```

Running this, gives us the last part of the flag `0d3_d1s4sm}`. The full handcrafted decompile can be found [`here`](byteme.py).

Flag `pearl{e4sy_p34sy_byt3c0d3_d1s4sm}`