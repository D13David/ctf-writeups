# Cyber Apocalypse 2024

## Cubicle Riddle

> Navigate the haunting riddles that echo through the forest, for the Cubicle Riddle is no ordinary obstacle. The answers you seek lie within the whispers of the ancient trees and the unseen forces that govern this mystical forest. Will your faction decipher the enigma and claim the knowledge concealed within this challenge, or will the forest consume those who dare to unravel its secrets? The fate of your faction rests in you.
> 
> Author: n/a
> 
> [`misc_cubicle_riddle.zip`](misc_cubicle_riddle.zip)

Tags: _misc_

## Solution
This challenge is a small gambling game. We are on a journey through a dense thick forest while finding an obsidian cube. We can approach the cube and we have to answer to an riddle. If we answer correct, we get the flag. The code in question looks like this:

```python
...
self.req.sendall(b"> Riddler:" + self.riddler.ask_riddle().encode())
self.req.sendall(b"\n(Answer wisely) > ")
answer: str = self.req.recv(4096).decode()
if self.riddler.check_answer(self._format_answer(answer)):
...
```

Riddler itself is an interesting class that creates an python function bytecode. The main logic for the function is the input we give, so we basically can write the function on our own. Except, we have to pass in valid python bytecode. The outcome of the function can be seen in `check_answer`, the riddler holds an array of 10 random integers, every integer in range [-1000,1000] and our function needs to send back an tuple with the minimum and maximum value of this array.

```python
import types
from random import randint


class Riddler:

    max_int: int
    min_int: int
    co_code_start: bytes
    co_code_end: bytes
    num_list: list[int]

    def __init__(self) -> None:
        self.max_int = 1000
        self.min_int = -1000
        self.co_code_start = b"d\x01}\x01d\x02}\x02"
        self.co_code_end = b"|\x01|\x02f\x02S\x00"
        self.num_list = [randint(self.min_int, self.max_int) for _ in range(10)]

    def ask_riddle(self) -> str:
        return """ 'In arrays deep, where numbers sprawl,
        I lurk unseen, both short and tall.
        Seek me out, in ranks I stand,
        The lowest low, the highest grand.

        What am i?'
        """

    def check_answer(self, answer: bytes) -> bool:
        _answer_func: types.FunctionType = types.FunctionType(
            self._construct_answer(answer), {}
        )
        return _answer_func(self.num_list) == (min(self.num_list), max(self.num_list))

    def _construct_answer(self, answer: bytes) -> types.CodeType:
        co_code: bytearray = bytearray(self.co_code_start)
        co_code.extend(answer)
        co_code.extend(self.co_code_end)

        code_obj: types.CodeType = types.CodeType(
            1,
            0,
            0,
            4,
            3,
            3,
            bytes(co_code),
            (None, self.max_int, self.min_int),
            (),
            ("num_list", "min", "max", "num"),
            __file__,
            "_answer_func",
            "_answer_func",
            1,
            b"",
            b"",
            (),
            (),
        )
        return code_obj
```

First we need to see what the code start and end actually are:

```python
>>> dis.dis(b"d\x01}\x01d\x02}\x02")
          0 LOAD_CONST               1
          2 STORE_FAST               1
          4 LOAD_CONST               2
          6 STORE_FAST               2
>>> dis.dis(b"|\x01|\x02f\x02S\x00")
          0 LOAD_FAST                1
          2 LOAD_FAST                2
          4 BUILD_TUPLE              2
          6 RETURN_VALUE
```

From our `CodeType` creation we know the indice of the local variables and constant:

Constants
```bash
0       None
1       max_int (1000)
2       min_int (-1000)
```

Variables
```bash
0       num_list
1       min
2       max
3       num
```

So the code actually does the following

```python
min = 1000
max = -1000
# our code goes here
return (min, max)
```

The code we want to inject could be this (since we have variable `num`):
```python
for num in num_list:
    if num < min: min = num
    if num > max: max = num
```

```python
>>> def get_min_max(num_list):
...     min = 1000
...     max = -1000
...     for num in num_list:
...             if num < min: min = num
...             if num > max: max = num
...     return (min, max)
...
>>> get_min_max([44, 23, -40, 51])
(-40, 51)
```

Good, this works. So lets get the bytecode (there is a nice [`article`](https://tech.blog.aknin.name/2010/07/03/pythons-innards-code-objects/) describing this topic further).

```python
>>> get_min_max.__code__.co_code
b'\x97\x00d\x01}\x01d\x02}\x02|\x00D\x00]\x12}\x03|\x03|\x01k\x00\x00\x00\x00\x00r\x02|\x03}\x01|\x03|\x02k\x04\x00\x00\x00\x00r\x02|\x03}\x02\x8c\x13|\x01|\x02f\x02S\x00'
```

Before sending this, we need to remove the start and end code as the programm attaches them automatically, so we are left with `|\x00D\x00]\x12}\x03|\x03|\x01k\x00\x00\x00\x00\x00r\x02|\x03}\x01|\x03|\x02k\x04\x00\x00\x00\x00r\x02|\x03}\x02\x8c\x13`. The application itself wants a list of integer values.

```python
>>> byte_code = b"|\x00D\x00]\x12}\x03|\x03|\x01k\x00\x00\x00\x00\x00r\x02|\x03}\x01|\x03|\x02k\x04\x00\x00\x00\x00r\x02|\x03}\x02\x8c\x13"
>>> [b for b in byte_code]
[124, 0, 68, 0, 93, 18, 125, 3, 124, 3, 124, 1, 107, 0, 0, 0, 0, 0, 114, 2, 124, 3, 125, 1, 124, 3, 124, 2, 107, 4, 0, 0, 0, 0, 114, 2, 124, 3, 125, 2, 140, 19]
```

Passig the sequence of numbers as answer, gives us the flag.

```bash
(Answer wisely) > 124, 0, 68, 0, 93, 18, 125, 3, 124, 3, 124, 1, 107, 0, 0, 0, 0, 0, 114, 2, 124, 3, 125, 1, 124, 3, 124, 2, 107, 4, 0, 0, 0, 0, 114, 2, 124, 3, 125, 2, 140, 19

___________________________________________________________

Upon answering the cube's riddle, its parts spin in a

dazzling display of lights. A resonant voice echoes through

the woods that says... HTB{r1ddle_m3_th1s_r1ddle_m3_th4t}
___________________________________________________________
```

Flag `HTB{r1ddle_m3_th1s_r1ddle_m3_th4t}`