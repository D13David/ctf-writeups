# CSAW'23

## Linear Aggressor

> 
> Wall Street Traders dropped a new model! I hope no one can steal it.
>
>  Author: Tydut
>

Tags: __misc__

## Solution
We get a service link for this challenge where we can connect to with netcat. After doing so the service prints the following information:

```bash
$ nc misc.csaw.io 3000
Wall Street Bros dropped a new model!
Give me 30 numbers and I will give you a linear regression prediction.
Enter your input:
```

Next, setting up a small script that sends 30 numbers to the service, so we can inspect the results. One of the things I like to do is to send a list of all the same numbers and then change one thing at a time and check how the result changes. So we send 30 `0` we service responds with `125`. Next we set the last number to `1` (29*`0`, 1*`1`) and the result is `224`.

```bash
numbers                         result
000000000000000000000000000000  125
000000000000000000000000000001  224
000000000000000000000000000010  240
```

But what to do with the numbers. One thing is to check for the difference, for instance `224-125 = 99` and that is the ascii code for `c`. Nice, this looks promising, since our flag starts with `c` as well. Lets check the next one: `240-224 = 16`, thats not a printable character. So lets see how the third row differs from the first one: `240-125 = 115` that is the ascii code for `s`. Now, thats to much for coincidence, lets adapt the script:

```python
from pwn import *

base = 125

flag = ""

for idx in range(30):
    p = remote("misc.csaw.io", 3000)

    numbers = [b"0"]*30
    numbers[idx] = b"1"

    print(b"".join(numbers).decode(),end=" ")
    for i in range(30):
        p.sendline(numbers[i])

    p.recvuntil(b"Your result is:\r\n")
    result = int(p.recvline())
    char = chr(result-125)
    print(f"{result} => {char}")
    flag += char

    p.close()

print(flag)
```

Running the script gives us the flag.

```bash
$ python solve.py SILENT=1
100000000000000000000000000000 224 => c
010000000000000000000000000000 240 => s
001000000000000000000000000000 222 => a
000100000000000000000000000000 244 => w
000010000000000000000000000000 224 => c
000001000000000000000000000000 241 => t
000000100000000000000000000000 227 => f
000000010000000000000000000000 248 => {
000000001000000000000000000000 234 => m
000000000100000000000000000000 173 => 0
000000000010000000000000000000 225 => d
000000000001000000000000000000 176 => 3
000000000000100000000000000000 174 => 1
000000000000010000000000000000 220 => _
000000000000001000000000000000 178 => 5
000000000000000100000000000000 241 => t
000000000000000010000000000000 176 => 3
000000000000000001000000000000 177 => 4
000000000000000000100000000000 174 => 1
000000000000000000010000000000 230 => i
000000000000000000001000000000 235 => n
000000000000000000000100000000 228 => g
000000000000000000000010000000 220 => _
000000000000000000000001000000 230 => i
000000000000000000000000100000 178 => 5
000000000000000000000000010000 220 => _
000000000000000000000000001000 223 => b
000000000000000000000000000100 177 => 4
000000000000000000000000000010 225 => d
000000000000000000000000000001 250 => }
csawctf{m0d31_5t341ing_i5_b4d}
```

Flag `csawctf{m0d31_5t341ing_i5_b4d}`