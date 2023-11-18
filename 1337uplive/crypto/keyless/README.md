# 1337UP LIVE CTF 2023

## Keyless

> My friend made a new encryption algorithm. Apparently it's so advanced, you don't even need a key!
> 
> Author: CryptoCat
> 
> [`keyless.zip`](keyless.zip)

Tags: _crypto_

## Solution
We get the following `python` code:

```python
def encrypt(message):
    encrypted_message = ""
    for char in message:
        a = (ord(char) * 2) + 10
        b = (a ^ 42) + 5
        c = (b * 3) - 7
        encrypted_char = c ^ 23
        encrypted_message += chr(encrypted_char)
    return encrypted_message

flag = "INTIGRITI{REDACTED}"
encrypted_flag = encrypt(flag)

with open("flag.txt.enc", "w") as file:
    file.write(encrypted_flag)
```

All steps can be reversed quite easily, so we write a script to do so, and get the flag.

```python
flag = open("flag.txt.enc", "r").read()

def decrypt(message):
    result = ""
    for char in message:
        char = ord(char) ^ 23
        char = (char + 7) // 3
        char = (char - 5) ^ 42
        char = (char - 10) // 2
        result += chr(char)
    return result

print(decrypt(flag))
```

Flag `INTIGRITI{m4yb3_4_k3y_w0uld_b3_b3773r_4f73r_4ll}`