# Cyber Apocalypse 2023

## Remote computation

> The alien species use remote machines for all their computation needs. Pandora managed to hack into one, but broke its functionality in the process. Incoming computation requests need to be calculated and answered rapidly, in order to not alarm the aliens and ultimately pivot to other parts of their network. Not all requests are valid though, and appropriate error messages need to be sent depending on the type of error. Can you buy us some time by correctly responding to the next 500 requests?
>
>  Author: N/A
>

Tags: _misc__

## Solution
When connecting to the container we get a small UI. Apparently we have to solve some simple equations with some rules for error handling.
```bash
$ nc 188.166.152.84 30834
[-MENU-]
[1] Start
[2] Help
[3] Exit
> 2

Results
---
All results are rounded
to 2 digits after the point.
ex. 9.5752 -> 9.58

Error Codes
---
* Divide by 0:
This may be alien technology,
but dividing by zero is still an error!
Expected response: DIV0_ERR

* Syntax Error
Invalid expressions due syntax errors.
ex. 3 +* 4 = ?
Expected response: SYNTAX_ERR

* Memory Error
The remote machine is blazingly fast,
but its architecture cannot represent any result
outside the range -1337.00 <= RESULT <= 1337.00
Expected response: MEM_ERR

[-MENU-]
[1] Start
[2] Help
[3] Exit
>
```

Manual imput surely is too slow:
```bash
> 1

[*] Receiving Requests...

[001]: 23 + 24 * 26 / 21 / 16 + 9 / 28 - 9 + 19 / 12 * 12 * 19 + 16 / 21 - 20 = ?
> 357.94

[!] Too slow
```

So we need a quick [`script for this`](solution.py).
```python
#!/usr/bin/env python3

from pwn import *

context.log_level="debug"

if args.REMOTE:
    p = remote("161.35.168.118", 31232)
else:
    p = process(binary.path)

p.sendlineafter(b"> ", b"1")

while True:
    line = p.recvline().decode()
    print(line)
    if "]:" in line:
        line = line.split(":")[-1][:-5].strip()
        print(line)
        try:
            foo = round(eval(line),2)
            print(foo)
            if foo >= -1337 and foo <= 1337:
                p.sendlineafter(b"> ", str(foo).encode())
            else:
                p.sendlineafter(b"> ", b"MEM_ERR")
        except ZeroDivisionError:
            p.sendlineafter(b"> ", b"DIV0_ERR")
        except SyntaxError:
            p.sendlineafter(b"> ", b"SYNTAX_ERR")
```

And after all the questions are answered we get the flag `HTB{d1v1d3_bY_Z3r0_3rr0r}`.