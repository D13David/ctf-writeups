# Cyber Apocalypse 2024

## The PROM

> After entering the door, you navigate through the building, evading guards, and quickly locate the server room in the basement. Despite easy bypassing of security measures and cameras, laser motion sensors pose a challenge. They're controlled by a small 8-bit computer equipped with AT28C16 a well-known EEPROM as its control unit. Can you uncover the EEPROM's secrets?
> 
> Author: n/a
> 

Tags: _hardware_

## Solution
This time, we don't have any files attached to the challenge. If we spawn the container and connect to it we get the following:

```bash

      AT28C16 EEPROMs
       _____   _____
      |     \_/     |
A7   [| 1        24 |] VCC
A6   [| 2        23 |] A8
A5   [| 3        22 |] A9
A4   [| 4        21 |] !WE
A3   [| 5        20 |] !OE
A2   [| 6        19 |] A10
A1   [| 7        18 |] !CE
A0   [| 8        17 |] I/O7
I/O0 [| 9        16 |] I/O6
I/O1 [| 10       15 |] I/O5
I/O2 [| 11       14 |] I/O4
GND  [| 12       13 |] I/O3
      |_____________|

> help

Usage:
  method_name(argument)

EEPROM COMMANDS:
  set_address_pins(address)  Sets the address pins from A10 to A0 to the specified values.
  set_ce_pin(volts)          Sets the CE (Chip Enable) pin voltage to the specified value.
  set_oe_pin(volts)          Sets the OE (Output Enable) pin voltage to the specified value.
  set_we_pin(volts)          Sets the WE (Write Enable) pin voltage to the specified value.
  set_io_pins(data)          Sets the I/O (Input/Output) pins to the specified data values.
  read_byte()                Reads a byte from the memory at the current address.
  write_byte()               Writes the current data to the memory at the current address.
  help                       Displays this help menu.

Examples:
  set_ce_pin(3.5)
  set_io_pins([0, 5.1, 3, 0, 0, 3.1, 2, 4.2])

>
```

So, we have a `EEPROM` that we can program. Quickly searching the internet we [`find`](http://cva.stanford.edu/classes/cs99s/datasheets/at28c16.pdf) some useful [`documentation`](https://leap.tardate.com/playground/eeprom/at28c16/peprogrammer/). So we could try to read data.

A read operation of the `AT28C16` has the following setup:

```bash
PIN     State
CE      low
OE      low
WE      high
A0-10   memory address input
IO0-7   data output
```

From the documentation we see that low input voltage for CE and OE should have a max of 0.8V and the high input voltage for WE a min of 2.0V. 

So, with this setup we can read the whole ram, but sadly nothing only zero-bytes come back.

```python
from pwn import *

p = remote("94.237.53.26", 48492)

p.sendlineafter(b">", b"set_ce_pin(0.0)")
p.sendlineafter(b">", b"set_oe_pin(0.0)")
p.sendlineafter(b">", b"set_we_pin(4.0)")

foo = []

for i in range(0x7e0, 0x800):
    digits = [int(digit)*4 for digit in bin(i)[2:].rjust(11,"0")]
    p.sendlineafter(b">", f"set_address_pins({digits})".encode())
    p.sendlineafter(b">", b"read_byte()")
    value = int(p.recvline().split()[1][2:],16)
    if value != 0:
        foo.append(value)

for x in foo:
    print(chr(x), end="")
```

```bash
$ python foo.py
[+] Opening connection to 94.237.53.26 on port 48492: Done
­[*] Closed connection to 94.237.53.26 port 48492
```

Sad, but reading a bit further research shows, we can do other things. For instance reading the `Device Identification`.

> The chip provides 32 bytes of device identification memory between addresses 0x7E0 to 0x7FF (2016 to 2047).
> 
> I haven’t tried reading or writing the device info yet, but this is how I believe it works:
> 
> To read or write these addresses, A9 needs to be raised to 12 ± 0.5V. Note that only the OE and A9 pins are tolerant of voltages to 13.5V. All other pins have maximum ratings of -0.6V to +6.25V with respect to ground.
> 
> If A9 is raised to normal voltages (to +6.25V), then the normal memory between 0x7E0 to 0x7FF is accessed for read and write.
[`source`](
https://leap.tardate.com/playground/eeprom/at28c16/peprogrammer/)

Lets try this, update `A9` to 12V and re-run the script:

```python
...
for i in range(0x7e0, 0x800):
    digits = [int(digit)*4 for digit in bin(i)[2:].rjust(11,"0")]
    digits[1] = 12
    p.sendlineafter(b">", f"set_address_pins({digits})".encode())
...
```

```bash
$ python foo.py
[+] Opening connection to 94.237.53.26 on port 48492: Done
­TB{AT28C16_EEPROM_s3c23t_1d!!!}[*] Closed connection to 94.237.53.26 port 48492
```

Flag `HTB{AT28C16_EEPROM_s3c23t_1d!!!}`