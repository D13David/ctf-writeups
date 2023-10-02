# BuckeyeCTF 2023

## Electronical

> I do all my ciphering electronically
> 
>  Author: jm8
>

Tags: _crypto_

## Solution
For this challenge we get a link to a small webservice. The user can input a message and let the service encrypt the message. Also the source code is exposed.

```python
from Crypto.Cipher import AES
from flask import Flask, request, abort, send_file
import math
import os

app = Flask(__name__)

key = os.urandom(32)
flag = os.environ.get('FLAG', 'bctf{fake_flag_fake_flag_fake_flag_fake_flag}')

cipher = AES.new(key, AES.MODE_ECB)

def encrypt(message: str) -> bytes:
    length = math.ceil(len(message) / 16) * 16
    padded = message.encode().ljust(length, b'\0')
    return cipher.encrypt(padded)

@app.get('/encrypt')
def handle_encrypt():
    param = request.args.get('message')

    if not param:
        return abort(400, "Bad")
    if not isinstance(param, str):
        return abort(400, "Bad")

    return encrypt(param + flag).hex()

@app.get('/source')
def handle_source():
    return send_file(__file__, "text/plain")

@app.get('/')
def handle_home():
    return """
        <style>
            form {
                display: flex;
                flex-direction: column;
                max-width: 20em;
                gap: .5em;
            }

            input {
                padding: .4em;
            }
        </style>
        <form action="/encrypt">
            <h2><i>ELECTRONICAL</i></h2>
            <label for="message">Message to encrypt:</label>
            <input id="message" name="message"></label>
            <input type="submit" value="Submit">
            <a href="/source">Source code</a>
        </form>
    """

if __name__ == "__main__":
    app.run()
```

Ok, what do we have here? The service uses [`AES in ECB mode`](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Electronic_codebook_(ECB)). The app then concatenates the input message with the flag, padds the string to a length of multiple of 16 bytes and then encrypts the message before sending the encrypted result back. Since AES works on 16 byte (128 bit) blocks (therefore the string is padded) and we can control the blocks before the flag we can do a [`padding oracle attack`](https://en.wikipedia.org/wiki/Padding_oracle_attack).

The idea is the following. Lets imagine we are sending a 32 byte long message (for instance only 'a') and the server attaches the flag we have something like `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabctf{fake_flag_fake_flag_fake_flag_fake_flag}`. Then the message is padded to a length of multiple of 16 (bytes), so we end up with `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabctf{fake_flag_fake_flag_fake_flag_fake_flag}\x00\x00\x00`. After this the whole string is split into 16 byte blocks (`0` at the end are null bytes):

```bash
aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa
bctf{fake_flag_f
ake_flag_fake_fl
ag_fake_flag}000
```

But what if we send only a 31 byte long message? The first character of the flag would leak into the second block. As this is AES in ECB mode, same blocks are encrypted to the same ciphertext. Since we know that block 2 only differs with one character from block 1 we can bruteforce the last character for block 1 until the resulting ciphertext matches. In this case we know what the lasts character of block 2 is (since block 1 and 2 match and we know all bytes of block 1) and we know the first character of the flag. Then we repeate this procedure for the next character and so on.

```bash
# first character
aaaaaaaaaaaaaaa?
aaaaaaaaaaaaaaab
ctf{fake_flag_fa
ke_flag_fake_fla
g_fake_flag}0000

# second character
aaaaaaaaaaaaaab?
aaaaaaaaaaaaaabc
tf{fake_flag_fak
e_flag_fake_flag
_fake_flag}00000

... etc

# sixteenth character
bctf{fake_flag_f
bctf{fake_flag_f
ake_flag_fake_fl
ag_fake_flag}000
```

We proceed like this for all the remainingblocks. The script below implements exactly this and after a while we get the flag.

```python
import math
import requests

def oracle(txt) -> bytes:
    url = f"https://electronical.chall.pwnoh.io/encrypt?message={txt}"
    resp = requests.get(url).text
    return resp

block = "a"*15
flag = ""

for idx in range(1, 4):
    for x in range(15, -1, -1):
        for i in "abcdefghijklmnopqrstuvwxyz0123456789{}_":
            block1 = block + i
            block2 = 'a'*x
            resp = oracle(block1 + block2)
            if resp[0:32] == resp[idx*32:idx*32+32]:
                block = block1[1:]
                print(block)
                break
        if block[-1:] == '}':
            break
    flag += block1[-x:]

print(flag)
```

Flag `bctf{1_c4n7_b3l13v3_u_f0und_my_c0d3b00k}`