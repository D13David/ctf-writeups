# AirOverflow CTF 2024

## babyrev

> have you heard of pyinstaller?
>
>  Author: hexamine
>
> [`chal.exe`](chal.exe)

Tags: _rev_

## Solution
This challenge comes with an `pyinstaller` executable, as the hint already gives away. The executable is a bundle for a python application plus dependencies in one single package. It contains a lot of framework code and wires things together, so that the application logic will run. The interesting part is, that the bundle also contains the precompiled python bytecode for the application logic. This is what we want so we are extracting the package (for instance with [`PyInstaller Extractor`](https://github.com/extremecoders-re/pyinstxtractor)).

```bash
$ python extract.py chal.exe
[+] Processing chal.exe
[+] Pyinstaller version: 2.1+
[+] Python version: 3.11
[+] Length of package: 1336887 bytes
[+] Found 10 files in CArchive
[+] Beginning extraction...please standby
[+] Possible entry point: pyiboot01_bootstrap.pyc
[+] Possible entry point: pyi_rth_inspect.pyc
[+] Possible entry point: chal.pyc
[+] Found 99 files in PYZ archive
[+] Successfully extracted pyinstaller archive: chal.exe

You can now use a python decompiler on the pyc files within the extracted directory

$ ls chal.exe_extracted/
chal.pyc                 pyimod01_archive.pyc    pyimod03_ctypes.pyc   pyi_rth_inspect.pyc  PYZ-00.pyz_extracted
pyiboot01_bootstrap.pyc  pyimod02_importers.pyc  pyimod04_pywin32.pyc  PYZ-00.pyz           struct.pyc
```

Nice, next thing is to decompile the `chal.pyc` bytecode. There are a lot of decompilers, I'll be using [`Decompyle++`](https://github.com/zrax/pycdc).

```bash
$ ~/Tools/pycdc/pycdc chal.exe_extracted/chal.pyc
# Source Generated with Decompyle++
# File: chal.pyc (Python 3.11)
...
```

This worked not completely well. Some newer python versions use opcodes which are not fully implemented. We could search for another decompiler, but as a good fallback we always can just disassemble and read the disassembly (its honestly not too complicated to read). 

```python
import codecs
import base64
import sys

def KSA(key):
Unsupported opcode: SWAP
    S = list(range(256))
    j = 0
# WARNING: Decompyle incomplete


def PRGA(S):
Unsupported opcode: RETURN_GENERATOR
    pass
# WARNING: Decompyle incomplete


def encrypt(plaintext):
Unsupported opcode: JUMP_BACKWARD
    key = 'Rivest'
    plaintext = plaintext()
    key = key()
    keystream = PRGA(KSA(key))
    enc = []
# WARNING: Decompyle incomplete

flag = input('Please enter the flag: ')
enc_flag = encrypt(flag)
if enc_flag == b'aJlQBCwh9JM2RHmXLy+PA6cUIFDC3A==':
    print('Correct!')
    return None
print('Wrong!')
``` 

TL;DR, Although in this case, the logic is more or less given away already: the user input is [`RC4`](https://en.wikipedia.org/wiki/RC4) encrypted and compared with a already encrypted (and base64 encoded) string. So all we have to do is to decrypt the same string, thankfully the encryption key is also given (`Rivest`). Lets write a small python script to decrypt the flag:

Lets
```python
from Crypto.Cipher import ARC4
from base64 import b64decode

key = b"Rivest"
message = b64decode("aJlQBCwh9JM2RHmXLy+PA6cUIFDC3A==");
cipher = ARC4.new(key)
print(cipher.decrypt(message))
``` 

Ok, what if: the decompiled code wouldn't be this clear? We could fallback to reading the [`disassembly`](chal.asm). The decompiler had issues with three functions (`KSA`, `RPGA` and `encrypt`). Lets inspect one by one.

```bash
0       RESUME                        0
2       LOAD_GLOBAL                   1: NULL + list
14      LOAD_GLOBAL                   3: NULL + range
26      LOAD_CONST                    1: 256
28      PRECALL                       1
32      CALL                          1
42      PRECALL                       1
46      CALL                          1
# S = range(256)
56      STORE_FAST                    1: S
58      LOAD_CONST                    2: 0
# j = 0
60      STORE_FAST                    2: j
62      LOAD_GLOBAL                   3: NULL + range
74      LOAD_CONST                    1: 256
76      PRECALL                       1
80      CALL                          1
90      GET_ITER
92      FOR_ITER                      64 (to 222)
# for i in range(256):
94      STORE_FAST                    3: i
96      LOAD_FAST                     2: j
# S[i]
98      LOAD_FAST                     1: S
100     LOAD_FAST                     3: i
102     BINARY_SUBSCR
# j + S[i]
112     BINARY_OP                     0 (+)
116     LOAD_FAST                     0: key
118     LOAD_FAST                     3: i
120     LOAD_GLOBAL                   5: NULL + len
132     LOAD_FAST                     0: key
134     PRECALL                       1
# len(key)
138     CALL                          1
# i % len(key)
148     BINARY_OP                     6 (%)
152     BINARY_SUBSCR
# j + S[i] + key[i % len(key)]
162     BINARY_OP                     0 (+)
166     LOAD_CONST                    1: 256
# (j + S[i] + key[i % len(key)]) % 256
168     BINARY_OP                     6 (%)
# j = (j + S[i] + key[i % len(key)]) % 256
172     STORE_FAST                    2: j
174     LOAD_FAST                     1: S
176     LOAD_FAST                     2: j
# S[j]
178     BINARY_SUBSCR
188     LOAD_FAST                     1: S
190     LOAD_FAST                     3: i
# S[i]
192     BINARY_SUBSCR
# swap values on stack
202     SWAP                          2
204     LOAD_FAST                     1: S
206     LOAD_FAST                     3: i
# S[i] = S[j]
208     STORE_SUBSCR
212     LOAD_FAST                     1: S
214     LOAD_FAST                     2: j
# S[j] = S[i]
216     STORE_SUBSCR
220     JUMP_BACKWARD                 65
222     LOAD_FAST                     1: S
# return S
224     RETURN_VALUE
``` 

So we can reconstruct the code to be:

```python
def KSA(key):
    S = range(256)
    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % len(key)]) % 256
        S[i], S[j] = S[j], S[i]

    return S
```

If we do the same exercise to `PRGA` we end up with the following:

```python
def PRGA(S):
    i = 0
    j = 0
    while True:
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]

        K = S[(S[i] + S[j]) % 256]
        yield K
```

```python
def encrypt(plaintext):
    key = 'Rivest'
    plaintext = [ord(p) for p in plaintext]
    key = [ord(k) for k in key]
    keystream = PRGA(KSA(key))
    enc = []

    for i in range(len(plaintext)):
        enc.append(plaintext[i] ^ next(keystream))

    byte_string = bytes(enc)
    b64_enc = base64.b64encode(byte_string)
    return b64_enc
```

See the full listing [`here`](chal.py).

Flag `AOFCTF{rc4_go_brrrrrr}`