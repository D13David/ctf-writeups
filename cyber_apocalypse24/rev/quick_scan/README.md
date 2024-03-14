# Cyber Apocalypse 2024

## QuickScan

> In order to escape this alive, you must carefully observe and analyze your opponents. Learn every strategy and technique in their arsenal, and you stand a chance of outwitting them. Just do it fast, before they do the same to you...
> 
> Author: clubby789
> 

Tags: _rev_

## Solution
For this challenge we get a docker container to connect to. If we do so we get the following instructions:

```bash
$ nc 94.237.49.46 58408
I am about to send you 128 base64-encoded ELF files, which load a value onto the stack. You must send back the loaded value as a hex string
You must analyze them all in under 120 seconds
Let's start with a warmup
ELF:  f0VMRgIBAQAAAAAAAAAAAAIAPgABAAAAYoIECAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAEAAOAABAAAAAAAAAAEAAAAFAAAAAAAAAAAAAAAAgAQIAAAAAACABAgAAAAASAMAAAAAAABIAwAAAAAAAAAQAAAAAAAA4snNgeYLN+VVW5pOySvRxhmvLyR0TX9xcLo8rYYzAQNkUw3x+x8+45jM+Z8Zrkwk+zRW0nVONi74kCPym0uj+MsH4UZiqrE3ZfeUepkk+WcaHE6lDknrroXSucCHRHK9WfW1C53KFoxnwIlagvAhlQA13fjeOSPWN96YutH4E1km/Rg9epB0J84iO+1PHzXkgJ2QwMDTdCAT21xfN+1l8ozM8oEwSNA+I1AVHzMapYk7JMSfeZZzUfdQC9H39tu9vxhCBFYOKEorkZjUMWo9g+gGa//4/EA6abz0d7J4DNL/0J8GPzzUOR4VuliXB8efZT0zrGdZdiIXwsyAuvbZX+DXZLru2m5VY1c4Rq6+4AIrqbk1l/NCMwEn76WbWyKXmC0hcXG5R8ck9hBG0TsGbeYMIO6yCprLyCwNJ5wmWdtXpDZRsaMPVv4sEt4rC4R8neY+5xgDwh92sMT3pHmQRk5y/kYJqFpRec6yBky72nKaVSMH2m4oHnybAx5ZK4mcVgS4UdEqy6nNzFYYwH0aQlekw3X10LglQU3apZynVCTGjr63vD5TaoJhcX2hbAM2BL+bZjAm/i3cdDXxxuQtuD8xUXts2h0n1VvXJ4G3qqhujnOxn3J56M+75+Ss3A+MbTZ2eSTir1bXMkiD7BhIjTXN/v//SInnuRgAAADzpLg8AAAADwWYYmhskHckF29ntW6bYe9360EdmJXrEN4347FooiWDFN3iFygBeCWPZw/LeIo0psAIB5bz0nCQD8lElAHjNKXija34JjDPXucx4MRjwVLBtyfUjNouk1szuPFPuBgdnYWly+bqp0kd5GDCHJyPbSy10L1pS0iOlVt3M+XpKrrvjmb0PKN5mzMYB7TF6AjP+RPc3oGoe/tikU5JqXDMlrhInPHJBLRyJW/I5CGSSU0gFSRHSLeBMWPvMdlrQrBjti1vGejFT9k8Hvjn
Expected bytes: 4204560e284a2b9198d4316a3d83e8066bfff8fc403a69bc
Bytes?
```

Right, it sends us small programs that load some bytes into memory. Our task is to send back what bytes are loaded. So lets get a few samples.

```c
08048262 48 83 ec 18     SUB        RSP,0x18
08048266 48 8d 35        LEA        RSI,[DAT_0804813a]
         cd fe ff ff
0804826d 48 89 e7        MOV        RDI,RSP
08048270 b9 18 00        MOV        ECX,0x18
         00 00
08048275 f3 a4           MOVSB.REP  RDI,RSI=>DAT_0804813a
08048277 b8 3c 00        MOV        EAX,0x3c
         00 00
0804827c 0f 05           SYSCALL
0804827e 98              CWDE
```

The program reserves 24 bytes on the stack and then copies 24 bytes (movsb rep) from a data location to the stack. Afterwards it exits. The next samples have the same structure, what changes is the number of bytes and the location of the data. This can be easily parsed though.

```python
import base64
import struct
from pwn import *

def decode(data):
     data = base64.b64decode(data)

     # read entry point from header
     entry = struct.unpack_from("<Q", data, 0x18)[0] - 0x8048000

     # read the relative offset of the data location, this can be positive
     # or negative
     offset = entry + 7
     addr = struct.unpack_from("<i", data, offset)[0] + offset + 4

     # read the number of bytes written
     offset = offset + (4 + 4)
     count = struct.unpack_from("<I", data, offset)[0]

     return data[addr:addr+count].hex()


p = remote("83.136.254.16", 58548)

for i in range(129):
    p.recvuntil(b"ELF:  ")
    data = p.recvline()[:-1].decode()
    result = decode(data)
    p.sendlineafter(b"Bytes?", result.encode())
    print("send: ", result)
p.interactive()
```

Running this, gives us the flag.

```bash
$ python foo.py
[+] Opening connection to 94.237.49.46 on port 58408: Done
send:  7c215918fb77575d78dd9331ec159408b77c9deaa3a60f72
send:  5652d0251137bafc1d21e7c35cca446b7050e105be42e209
send:  d79ff742bad48563db71b33fc81ee2ae569e37d54358db10
...
send:  d8c1619c3ab76df5e1fd74c6ad14cf17948a42e5787d85b7
[*] Switching to interactive mode
 Wow, you did them all. Here's your flag: HTB{y0u_4n4lyz3d_th3_p4tt3ns!}
 ```

Flag `HTB{y0u_4n4lyz3d_th3_p4tt3ns!}`