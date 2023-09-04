# DownUnderCTF 2023

## downunderflow

> We found this binary in the backroom, its been marked as "The All Fathers Wisdom" - See hex for further details. Not sure if its just old and hex should be text, or they mean the literal hex.
>
> Anyway can you get this 'wisdom' out of the binary for us?
>
>  Author: pix
>
> [`the-all-fathers-wisdom`](the-all-fathers-wisdom)

Tags: _rev_

## Solution
For this challenge we are provided with an executable. Opening the executable in `Ghidra` we find the `main` which prints the flag but sadly exists before doing so.

```c
void main.main(undefined8 param_1)
{
  os.exit(0);
  main.print_flag(param_1);
  return;
}
```

The function `print_flag` loops over 59 items starting with `&local_1d8` and doing `xor 0x11` for each item. 

```c
// ...
  local_1b0 = 0x31;
  local_1b8 = 0x24;
  local_1c0 = 0x24;
  local_1c8 = 0x31;
  local_1d0 = 0x25;
  local_1d8 = 0x25;
  local_1e8 = &local_1d8;
  length = 59;
  for (i = 0; puVar1 = local_1e8, offset = i, i < length; i = i + 1) {
    runtime.bounds_check_error("/home/pix/chal/main.odin",0x18,0x47,0x24,i,length);
    local_22c = *(uint *)(puVar1 + offset) ^ 0x11;
    local_228 = CONCAT88(0x4200000000000001,&local_22c);
    local_218 = CONCAT88(0x4200000000000001,&local_22c);
    local_208 = CONCAT88(1,local_218);
    fmt.printf("%c",2,local_218,1,param_1);
  }
```

This can easily be reimplemented with python to get the flag.

```python
from Crypto.Util.number import long_to_bytes

foo = [0x75,0x26,0x31,0x22,0x25,0x31,0x77,0x24,0x31,0x25,0x26,0x31,0x21,0x22,0x31,0x74,0x25,0x31,0x75,0x23,0x31,0x22,0x24,0x31,0x20,0x22,0x31,0x77,0x24,0x31,0x74,0x27,0x31,0x20,0x22,0x31,0x25,0x27,0x31,0x77,0x25,0x31,0x73,0x26,0x31,0x27,0x25,0x31,0x25,0x24,0x31,0x22,0x25,0x31,0x24,0x24,0x31,0x25,0x25]

foo = foo[::-1]

flag = ""
for i in foo:
    flag = flag + chr(i^17)

print(bytes.fromhex(flag))
```

Flag `DUCTF{Od1n_1S-N0t_C}`