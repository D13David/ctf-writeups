# AmateursCTF 2023

## Censorship Lite

> I'll let you run anything on my python program as long as you don't try to print the flag or violate any of my other rules! Pesky CTFers...
>
>  Author: hellopir2 and flocto
>
> [`main.py`](main.py)

Tags: _misc_

## Solution
The challenge is a follow up of [`Censorship`]. The following code is given.

```python
#!/usr/local/bin/python
from flag import flag

for _ in [flag]:
    while True:
        try:
            code = ascii(input("Give code: "))
            if any([i in code for i in "\lite0123456789"]):
                raise ValueError("invalid input")
            exec(eval(code))
        except Exception as err:
            print(err)
```

Input is requested from the user and then executed. But before this some filtering is done, for instance `flag` cannot be in the input as well as no `e`, `t`, `i`, `l`, any escape string or any number. Since the whole construct is inside the `for _ in [flag]` loop, we can access the flag by just using `_`. 

Accessing `locals` will not work this time, since `l` is forbidden. But the python documentation explains the following:

> Without an argument, vars() acts like locals(). Note, the locals dictionary is only useful for reads since updates to the locals dictionary are ignored.

So using `vars()` instead of `locals()` gives the flag.

```python
$ nc amt.rs 31671
Give code: vars()[_]
"amateursCTF{sh0uld'v3_r3strict3D_p4r3nTh3ticaLs_1nst3aD}"'
```

Flag `amateursCTF{sh0uld'v3_r3strict3D_p4r3nTh3ticaLs_1nst3aD}`