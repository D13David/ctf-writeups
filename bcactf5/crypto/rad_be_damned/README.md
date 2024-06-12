# BCACTF 5.0

## rad-be-damned

> My friend seems to be communicating something but I can't make out anything. Why do we live so close to Chernobyl anyways?
> 
> Author: Nikhil
> 
> [`message.py`](message.py), [`output.txt`](output.txt)

Tags: _crypto_

## Solution
For this challenge we get a python script and a output that was generated with the python script. The output looks like a sequence of bits. Lets have a look what the script does.

```python
enc_plaintext = encrypt(plaintext)
cor_text = rad(enc_plaintext)
```

The plaintext is encrypted and then put through the function `rad`.

```python
def encrypt(plaintext: str):
    enc_plaintext = ""

    for letter in plaintext:
        cp = int("10011", 2)
        cp_length = cp.bit_length()
        bin_letter, rem = ord(letter), ord(letter) * 2**(cp_length - 1)
        while (rem.bit_length() >= cp_length):
            first_pos = find_leftmost_set_bit(rem)
            rem = rem ^ (cp << (first_pos - cp_length))
        enc_plaintext += format(bin_letter, "08b") + format(rem, "0" + f"{cp_length - 1}" + "b")
        
    return enc_plaintext
```

The encryption actually is not a encryption but will calculate a `crc` for each letter of the plaintext and concatenate both the 8 bit for the letter and 4 bit for the crc, leaving us with 12 bits in total for every character.

```python
def rad(text: str):
    corrupted_str = ""
    for ind in range(0, len(text), 12):
        bit_mask = 2 ** (random.randint(0, 11))
        snippet = int(text[ind : ind + 12], base = 2)
        rad_str = snippet ^ bit_mask
        corrupted_str += format(rad_str, "012b")
    return corrupted_str
```

The `rad` function will introduce some artificial noise to the message. For every 12 bits one bit is flipped. To reconstruct the correct message we can use the same crc logic. Since we don't know where the bit error was introduces (it can be either the character or the checksum) we just iterate, for each character (remember, 12 bits), over every bit, flip it and check if the crc will match. 

```python
import textwrap

def find_leftmost_set_bit(plaintext):
    pos = 0
    while plaintext > 0:
        plaintext = plaintext >> 1
        pos += 1
    return pos

def calc_crc(data):
    cp = int("10011", 2)
    cp_length = cp.bit_length()
    rem = letter * 2**(cp_length - 1)
    while (rem.bit_length() >= cp_length):
        first_pos = find_leftmost_set_bit(rem)
        rem = rem ^ (cp << (first_pos - cp_length))
    return rem

line = open("output.txt", "r").readline()
for part in textwrap.wrap(line, 12):
    for i in range(0,12,1):
        value = int(part,2) ^ (1<<i)
        checksum = value & 0xf
        letter = (value >> 4) & 0xff
        if calc_crc(letter) == checksum:
            print(chr(letter), end="")
```

Running this script will give us the flag.

Flag `bcactf{yumMY-y311OWC4ke-x7CwKqQc5fLquE51V-jMUA-aG9sYS1jb21vLWVzdGFz}`