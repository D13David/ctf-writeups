# BCACTF 5.0

## Cha-Cha Slide

> I made this cool service that lets you protect your secrets with state-of-the-art encryption. It's so secure that we don't even tell you the key we used to encrypt your message!
> 
> Author: Thomas
> 
> [server.py`](server.py)

Tags: _crypto_

## Solution
The challenge comes with a short python script. The server is hosted and we can connect via netcat. If we do so, we can enter a message and the server gives us the encrypted message back. Also we get the encrypted secret message and are asked to enter the secret message in decrypted form.

```bash
Secret message:
d0b33a93af34250b2cb9ec299230586cf673296cc959e7852e75e60ed7c9c40c

Enter your message:
abc

Encrypted:
83e969

Enter decrypted secret message:
def

Incorrect!
```

Lets check out how things work in code. The function `encrypt_msg` uses [`ChaCha20`]https://protonvpn.com/blog/chacha20) with `key` and `nonce` being some global variables.

```python
def encrypt_msg(plaintext):
    cipher = ChaCha20.new(key=key, nonce=nonce)
    return cipher.encrypt(plaintext.encode()).hex()
```

They are defined at the start of the script with some random values. The problem is that the `nonce` is reused for any message. The [`documentation`](https://pycryptodome.readthedocs.io/en/latest/src/cipher/chacha20.html) even highlights the fact.

> The cipher requires a nonce, which must not be reused across encryptions performed with the same key.

```python
key = urandom(32)
nonce = urandom(12)

secret_msg = urandom(16).hex()
```

We can retrieve the keystream if we know the plaintext message by just doing the encrypted message xor the plaintext. Since the nonce was reused the keystream is identical for any of the message, therefore we can decrypt the secret by just doing an xor with the retrieved keystream.

Lets try this. Lets run the program again. 

```bash
Secret message:
02594410b09c85720f0ef4a64d25d1e8b37953e5c6e10dcabe71ddcc6039db08
```

We know the encrypted message is `02594410b09c85720f0ef4a64d25d1e8b37953e5c6e10dcabe71ddcc6039db08` so the flag must be 32 bytes long (we get the encrpted result as hex-string). We can now send 32 bytes of any data, we take 32 'a' characters here.

```bash
Enter your message:
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

Encrypted:
540f1010e1cadd715c0da7a21b7286ebe62c04e094e10d99ee73dd98366ad858
```

```python
from pwn import xor

encrypted_secret = bytes.fromhex("02594410b09c85720f0ef4a64d25d1e8b37953e5c6e10dcabe71ddcc6039db08")
encrypted_message = bytes.fromhex("540f1010e1cadd715c0da7a21b7286ebe62c04e094e10d99ee73dd98366ad858")
message = b"a" * 32

# retrieve the keystream
keystream = xor(message, encrypted_message)

# decrypt the secret
print(xor(keystream, encrypted_secret).decode())
```

Running this gives us the secret `775a079b2b2e766b446d3aa21ca572b1`. So, lets see if the program will accept it.

```bash
Enter decrypted secret message:
775a079b2b2e766b446d3aa21ca572b1

bcactf{b3_C4rEFu1_wItH_crypT0Gr4phy_7d12be3b}
```

Flag `bcactf{b3_C4rEFu1_wItH_crypT0Gr4phy_7d12be3b}`