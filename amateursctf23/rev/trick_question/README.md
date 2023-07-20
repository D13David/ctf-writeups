# AmateursCTF 2023

## trick question

> Which one do you hate more: decompiling pycs or reading Python bytecode disassembly? Just kidding that's a trick question.

Run with Python version `3.10`.

Flag is `amateursCTF{[a-zA-Z0-9_]+}``
>
>  Author: flocto
>
> [`trick-question.pyc`](trick-question.pyc)

Tags: _rev_

## Solution
For this challenge a `pyc` file was delivered. The file contains compiled bytecode. To start the journey the bytecode can be decompiled with [`pycdc`](https://github.com/zrax/pycdc) by calling 

```bash
pycdc trick-question.pyc > trick-question.py
```

The output still is somewhat [`obfuscated`](trick-question.py) but right at the end the code is given to deobfuscate the part above.

```python
# Source Generated with Decompyle++
# File: trick-question.pyc (Python 3.10)


b64decode = lambda x: id.__self__.__dict__['exec'](id.__self__.__dict__['__import__']('base64').b64decode(x))
r = [
    0,
    0,
    1,
# ...snip
    '2XHgxOVx4MDB8XHgwMFx4ODNceD',
    'DecRmMwgHXqFDM4xlaw',
    'DecRHMwgHX9BDM4xVOxgHXy',
    'wZFx4MDFkXHgwNFx4ODVceD',
    'DecxHMwgHXTBDM4xVOxgHXz',
    'DecRmMwgHXqFDM4xlaw',
    'DecRXYxgHXyNDM4x1a1',
    'wZFx4MDRceDE5XHgwMGRceD',
    'zXHgxOVx4MDBTXHgwMHxceD',
    'DecRmMwgHXqFDM4xlaw',
    'ya1x4MDNyXHgwZXRceD',
    'xXHg4NVx4MDJceDE5XHgwMGRceD',
    'Y2hlY2sgPSBsYW1iZGE6Tm9uZQpjb2RlID0gdHlwZShjaGVjay5fX2NvZGVfXykoMSwgMCwgMCwgNiwgNSwgNjcsIGInfFx4MDBkXHgwMGRceD']
for i in range(len(r)):
    if r[i]:
        x[i] = x[i][::-1]
print(b64decode('A'.join(x[::-1])))
```

Two things need to be changed: First `b64decode` was assigned an lambda that does in fact decode the data but executes it immediately afterwards. We don't want this, so we remove the line `b64decode = lambda ...` and instead print the decoded text to a [`file`](stage2.py).

```python
b'check = lambda:None\ncode = type(check.__code__)(1, 0, 0, 6, 5, 67, b\'|\\x00d\\x00d\\x01\\x85\\x02\\x19\\x00d\\x02k\\x03r\\x0et\\x00j\\x01j\\x02d\\x03\\x19\\x00S\\x00|\\x00d\\x04\\x19\\x00d\\x05k\\x03r\\x1at\\x00j\\x01j\\x02d\\x03\\x19\\x00S\\x00|\\x00d\\x01d\\x04\\x85\\x02\\x19\\x00}\\x00t\\x00j\\x01j\\x02d\\x06\\x19\\x00|\\x00\\x83\\x01d\\x07k\\x03r0t\\x00j\\x01j\\x02d\\x03\\x19\\x00S\\x00g\\x00}\\x01t\\x00j\\x01j\\x02d\\x08\\x19\\x00|\\x00\\x83\\x01D\\x00]\\r\\\\\\x02}\\x02}\\x03|\\x03d\\tk\\x02rG|\\x01\\xa0\\x03|\\x02\\xa1\\x01\\x01\\x00q:|\\x01g\\x00d\\n\\xa2\\x01k\\x03rT
# ... snip
, (), ())

check = type(check)(code, {\'id\': id})
if check(input("Enter the flag: ")):
    print("Correct!")
else:
    print("Incorrect.")'
```

Ok, this looks like the flag checker code. The actual code is sadly not readable but the marshalled object code can be decompiled as well with `pycdc`. For this the object needs to be dumped to a file in binary format. This can be easily done by using `marshal.dump`. 

```python
import marshal
file = open("dump.b", "wb")
marshal.dump(code,file)
file.close()
```

This file can then be decompiled by calling `pycdc -c -v 3.10 dump.b > stage3.py`.

```python
# Source Generated with Decompyle++
# File: dump.b (Python 3.10)

if input[:12] != 'amateursCTF{':
    return id.__self__.__dict__['False']
if None[-1] != '}':
    return id.__self__.__dict__['False']
input = None[12:-1]
if id.__self__.__dict__['len'](input) != 42:
    return id.__self__.__dict__['False']
underscores = None
for i, x in id.__self__.__dict__['enumerate'](input):
    if x == '_':
        underscores.append(i)
if underscores != [
    7,
    11,
    13,
    20,
    23,
    35]:
    return id.__self__.__dict__['False']
input = None.encode().split(b'_')
if input[0][::-1] != b'sn0h7YP':
    return id.__self__.__dict__['False']
if (None[1][0] + input[1][1] - input[1][2], input[1][1] + input[1][2] - input[1][0], input[1][2] + input[1][0] - input[1][1]) != (160, 68, 34):
    return id.__self__.__dict__['False']
if None.__self__.__dict__['__import__']('hashlib').sha256(input[2]).hexdigest() != '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a':
    return id.__self__.__dict__['False']
r = None.__self__.__dict__['__import__']('random')
r.seed(input[2])
input[3] = id.__self__.__dict__['list'](input[3])
r.shuffle(input[3])
if input[3] != [
    49,
    89,
    102,
    109,
    108,
    52]:
    return id.__self__.__dict__['False']
if None[4] + b'freebie' != b'0ffreebie':
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][0:4], 'little') ^ r.randint(0, 0xFFFFFFFFL) != 0xFBFF4501L:
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][4:8], 'little') ^ r.randint(0, 0xFFFFFFFFL) != 825199122:
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][8:12] + b'\x00', 'little') ^ r.randint(0, 0xFFFFFFFFL) != 0xFEEF2AA6L:
    return id.__self__.__dict__['False']
c = None
for i in input[6]:
    c *= 128
    c += i
if id.__self__.__dict__['hex'](c) != '0x29ee69af2f3':
    return id.__self__.__dict__['False']
return None.__self__.__dict__['True']
```

Perfect, the full code of the flag checker. As it seems different parts of the flag are checked in different ways. So every part needs to be reversed. The first few conditions are super easy:

```python
if input[:12] != 'amateursCTF{':
    return id.__self__.__dict__['False']
if None[-1] != '}':
    return id.__self__.__dict__['False']
input = None[12:-1]
if id.__self__.__dict__['len'](input) != 42:
    return id.__self__.__dict__['False']
```

So, the flag starts with `amateursCTF{`, ends with an `}` and the part between the curly braces is 42 characters long. 

```python
underscores = None
for i, x in id.__self__.__dict__['enumerate'](input):
    if x == '_':
        underscores.append(i)
if underscores != [
    7,
    11,
    13,
    20,
    23,
    35]:
    return id.__self__.__dict__['False']
```

This part gives us the location of the underscores, this can easily be added.

```python
input = None.encode().split(b'_')
if input[0][::-1] != b'sn0h7YP':
    return id.__self__.__dict__['False']
```

Now the flag is split by underscores and the parts inbetween underscores are checked one by one. The first part again is simple: the reversed string is equal to `sn0h7YP`so the first part needs to be `PY7h0ns`.

```python
if (None[1][0] + input[1][1] - input[1][2], input[1][1] + input[1][2] - input[1][0], input[1][2] + input[1][0] - input[1][1]) != (160, 68, 34):
    return id.__self__.__dict__['False']
```

Ok, some constraints that need to be fulfilled. This can be solved with `z3` or by just brutforcing it.

```python
for i in range(0,255):
    for j in range(0,255):
        for k in range(0,255):
            x = i + j - k
            y = j + k - i
            z = k + i - j
            if x == 160 and y == 68 and z == 34:
                flag = flag + chr(i) + chr(j) + chr(k)
                break
```
The second part is `ar3`. The next part checks the `sha256` hash of the part. Since the alphabet is small and we know the part is only one character long this can also be bruteforced. The result is `4`. So far we have `amateursCTF{PY7h0ns_ar3_4_      _  _           _      }`.

```python
if None.__self__.__dict__['__import__']('hashlib').sha256(input[2]).hexdigest() != '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a':
    return id.__self__.__dict__['False']
```

The next part is shuffled a bit, luckily for us the seed is known, as it is the `4` of the previous part. So this can also be reversed.

```python
r = None.__self__.__dict__['__import__']('random')
r.seed(input[2])
input[3] = id.__self__.__dict__['list'](input[3])
r.shuffle(input[3])
if input[3] != [
    49,
    89,
    102,
    109,
    108,
    52]:
    return id.__self__.__dict__['False']
```

```python
foo = [0,1,2,3,4,5]
bar = [49,89,102,109,108,52]
r.shuffle(foo)
for i in range(0,len(foo)):
    flag = flag + chr(bar[foo.index(i)])
```

And we have `f4m1lY` for part 4.

```python
if None[4] + b'freebie' != b'0ffreebie':
    return id.__self__.__dict__['False']
```

Part 6 is literally a `freebie`, we can just copy it and have part 5 to be `0f`. Now onto the last two parts.

```python
if None.__self__.__dict__['int'].from_bytes(input[5][0:4], 'little') ^ r.randint(0, 0xFFFFFFFFL) != 0xFBFF4501L:
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][4:8], 'little') ^ r.randint(0, 0xFFFFFFFFL) != 825199122:
    return id.__self__.__dict__['False']
if None.__self__.__dict__['int'].from_bytes(input[5][8:12] + b'\x00', 'little') ^ r.randint(0, 0xFFFFFFFFL) != 0xFEEF2AA6L:
    return id.__self__.__dict__['False']
```

This splits the part in three sub-parts. The random numbers are no problem, since we have the `seed`, so this can be reversed like so:
```python
flag = flag + (r.randint(0, 0xFFFFFFFF) ^ 0xFBFF4501).to_bytes(4, 'little').decode()
flag = flag + (r.randint(0, 0xFFFFFFFF) ^ 825199122).to_bytes(4, 'little').decode()
flag = flag + (r.randint(0, 0xFFFFFFFF) ^ 0xFEEF2AA6).to_bytes(4, 'little').decode()
flag = flag + "_"
```

Concatenated this gives `N0Nv3nom0us` as part 6. The last part is doing some transformation which is reversible like...
```python
for i in input[6]:
    c *= 128
    c += i
if id.__self__.__dict__['hex'](c) != '0x29ee69af2f3':
    return id.__self__.__dict__['False']
```

```python
c = 0x29ee69af2f3
foo = []
while c > 0:
    foo.append(chr(c % 128))
    c //= 128
flag = flag + "".join(foo[::-1])
```

... so. And there we have it, the full flag.

Flag `amateursCTF{PY7h0ns_ar3_4_f4m1lY_0f_N0Nv3nom0us_Sn4kes}`