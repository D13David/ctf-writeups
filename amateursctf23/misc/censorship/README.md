# AmateursCTF 2023

## Censorship Lite

> I'll let you run anything on my python program as long as you don't try to print the flag or violate any of my other rules! Pesky CTFers...
>
>  Author: hellopir2 and flocto
>
> [`main.py`](main.py)

Tags: _misc_

## Solution
The following code is given

```python
#!/usr/local/bin/python
from flag import flag

for _ in [flag]:
    while True:
        try:
            code = ascii(input("Give code: "))
            if "flag" in code or "e" in code or "t" in code or "\\" in code:
                raise ValueError("invalid input")
            exec(eval(code))
        except Exception as err:
            print(err)
```

Input is requested from the user and then executed. But before this some filtering is done, for instance `flag` cannot be in the input as well as no `e`, `t` or any escape string. Since the whole construct is inside the `for _ in [flag]` loop, we can access the flag by just using `_`.

```python
$ nc amt.rs 31670
Give code: locals()[_]
'amateursCTF{i_l0v3_overwr1t1nG_functions..:D}'
```

Flag `amateursCTF{i_l0v3_overwr1t1nG_functions..:D}`