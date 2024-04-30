# AirOverflow CTF 2024

## compressed

> Trust me, I compressed my code so hard to hide the actual implementation that I don't think you can ever find it.
>
>  Author: TheFlash2k
>
> [`compressed.tar`](compressed.tar)

Tags: _rev_

## Solution
After upacking the `tar` archive (and unpacking again) we end up with an binary. Inspecting with `Ghidra` gives us a very small `main` function:

```c
undefined8
main(undefined8 param_1,undefined8 *param_2,size_t *param_3,uchar *param_4,size_t param_5)
{
  decrypt((EVP_PKEY_CTX *)payload,(uchar *)0x5de,param_3,param_4,param_5);
  Py_SetProgramName(*param_2);
  Py_Initialize();
  PyRun_SimpleStringFlags(payload,0);
  Py_Finalize();
  return 0;
}
```

What happens here is that the program runs a python script. The script is given with the program data but somehow encrypted. Lets check out `decrypt`:

```c
int decrypt(EVP_PKEY_CTX *ctx,uchar *out,size_t *outlen,uchar *in,size_t inlen)
{
  int local_c;
  
  for (local_c = 0; local_c < (int)out; local_c = local_c + 1) {
    ctx[local_c] = (EVP_PKEY_CTX)((byte)ctx[local_c] ^ (byte)key);
  }
  return local_c;
}
```

Ok, some simple xor enncryption with a single byte key. We can just grab the `payload` (Ghidra allows to special copy to a python byte-string) data and decrypt the python program ourself (the key is also in the data section and has value `0x41`).

```python
payload = bytearray(b'\x1e\x61\x7c\x61\x2d\x20\x2c\x23\x25\x20\x61...')

for i in range(len(payload)):
    payload[i] ^= 0x41

print(payload.decode())
```

The resulting (decrypted) python script is the following:

```python
_ = lambda __ : __import__('zlib').decompress(__import__('base64').b64decode(__[::-1]));exec((_)(b'=k5iFw03Ta2sZZyGkXgC2MQX7Cmtr6wvq6FyFxn0bp/PzF3URkYuZYp9sq7C6J7454K7G7Qvn3nHPOunbxDm9vRoFerq3q23MksZ1cM7Nz+XfYA6jtZ+rwH36n6LH8ZZmoWr46nhUofM7Il5y8vif3QzivGn3qskukNi8+fqZ1ZSWblTqe88+ixTT8TZVgsw5qR6sS62zCuw48Nr07O5+SP627jhPmcbd+0C+jT/3NY8/gbs9043o2g6Nihe6d+G7Wfq65oQD589d23b4f35BEaxNrnkXvfBiNjdZrTepqwsbJfiqGOVU9nEqq09t/BRvd+B05Kly3xbDVxSjY8e3TP25xlNbzzxY0uZT8MpN6irDW/DNMp8N7yyhqbC579K+gXqCDbOi4fWpgn2Y/wwqZlRCplRhTQawHhSB2JAKmaCLoxQW5rKjVfAhce0/5zGzpsQdA7GukFCstu10WIHxIGJgATdN1uTvQ1wxPpI9C62EXyK2i+j5y2AqYSMpxGrnQWs23sVszHsOG1j0EjW68otxTvxew9wQzaX3uovxYnGpEBy6+Y0NwcU6iysUYGiiFg6ikCEuWIjiFx2asbE36uQ4GFVyQDDHZM8MUD90QvI0YHFD4ku5kM4MOw+0n96vOvlCFTEDZcUoHCzF+uPQOq1zAfIemiYDxbE+uV/F+HG3Spg2y0lt+wxFzKzebmd7rHeydYoNTVvD2R313PIOZ9iyexGY5fRRQVDGRJLCqYQgUpEMUQgBrktDINmv+evQAk2v1EV1yJe'))

# x = ['JD0CEw==', 'JAMoWQ==', 'JwMCVA==', 'JwMCVA==', 'Ji0kVA==', 'JxMCVA==', 'JAM4EQ==', 'JAM8EA==', 'JD0oEA==', 'JD0KHg==', 'JwM8VA==', 'JAMoEQ==', 'JAMoEw==', 'JBMoVA==', 'Ji0OVA==', 'JD0sHg==', 'Ji0KVA==', 'Jj0OVA==', 'JD0kWg==', 'JD0KWQ==', 'JBMOVA==', 'JAMOVA==', 'Jz0kVA==', 'JD0CHg==', 'JwMoVA==', 'JD0wHg==', 'JD0gEw==', 'JwMgVA==', 'JihUVA==', 'Jy0gVA==', 'Ji0gVA==', 'JAMCVA==', 'JAMOVA==', 'JAM8VA==', 'Jj0sVA==', 'JD04EQ==', 'JD0CWA==', 'JD04Hg==', 'JD04Hg==', 'JD0sXQ==', 'JxM4VA==', 'JxMCVA==', 'JAMwVA==', 'Jz08VA==', 'JD0wXQ==', 'JAM4XQ==', 'JBMsVA==', 'JAMgXQ==', 'JAMgXQ==', 'JD0wHg==', 'JAMoWg==']
```

Its a bit obfuscated, but it's not that bad. The first part defines a `lambda` that reverses the input string, then base64 decodes the reversed input and finally decompresses the decoded input. Then the lambda is called with a given value (`=k5iFw03Ta2sZZyGkXg...`) and then execute is run on the resulting data. Since we don't really want to execute any unknown code, lets just decode this payload and see what it does (we can just remove the `exec` and print the result).

```python
_ = lambda __ : __import__('zlib').decompress(__import__('base64').b64decode(__[::-1]));

decoded_payload = _(b'=k5iFw03Ta2sZZyGkXgC2MQX7Cmtr6wvq6FyFxn0bp/PzF3URkYuZYp9sq7C6J7454K7G7Qvn3nHPOunbxDm9vRoFerq3q23MksZ1cM7Nz+XfYA6jtZ+rwH36n6LH8ZZmoWr46nhUofM7Il5y8vif3QzivGn3qskukNi8+fqZ1ZSWblTqe88+ixTT8TZVgsw5qR6sS62zCuw48Nr07O5+SP627jhPmcbd+0C+jT/3NY8/gbs9043o2g6Nihe6d+G7Wfq65oQD589d23b4f35BEaxNrnkXvfBiNjdZrTepqwsbJfiqGOVU9nEqq09t/BRvd+B05Kly3xbDVxSjY8e3TP25xlNbzzxY0uZT8MpN6irDW/DNMp8N7yyhqbC579K+gXqCDbOi4fWpgn2Y/wwqZlRCplRhTQawHhSB2JAKmaCLoxQW5rKjVfAhce0/5zGzpsQdA7GukFCstu10WIHxIGJgATdN1uTvQ1wxPpI9C62EXyK2i+j5y2AqYSMpxGrnQWs23sVszHsOG1j0EjW68otxTvxew9wQzaX3uovxYnGpEBy6+Y0NwcU6iysUYGiiFg6ikCEuWIjiFx2asbE36uQ4GFVyQDDHZM8MUD90QvI0YHFD4ku5kM4MOw+0n96vOvlCFTEDZcUoHCzF+uPQOq1zAfIemiYDxbE+uV/F+HG3Spg2y0lt+wxFzKzebmd7rHeydYoNTVvD2R313PIOZ9iyexGY5fRRQVDGRJLCqYQgUpEMUQgBrktDINmv+evQAk2v1EV1yJe')

print(decoded_payload.decode())
```

The second payload looks like this, after decoding:

```python
$ python decode1.py
#!/usr/bin/env python3
from base64 import b64encode

XOR_KEYS = [0x80, 0x83, 0x3, 0x6, 0x7, 0x9, 0x8a, 0x8b, 0xe, 0x9a, 0x1e, 0xa2, 0xa5, 0x2d, 0x2f, 0x31, 0x34, 0x3d, 0xbd, 0xc0, 0x42, 0x43, 0x45, 0xc7, 0x48, 0xc8, 0x4b, 0x50, 0x57, 0x5d, 0x62, 0x68, 0x70, 0x7d, 0x4, 0xef, 0xf0, 0xd3, 0xf8, 0x1e, 0x7b, 0x3c, 0x45, 0x47, 0x9c, 0x91, 0x71, 0x82, 0x91, 0xcc, 0xb2]
BASE_KEY = 0x69

def xor(__s: str, k: int) -> str:
    e = ""
    for i in __s:
        e += chr(ord(i) ^ k)
    return e

def encode(flag: str) -> list:
    enc = []
    for i in range(len(flag)):
        enc.append(str(ord(flag[i]) ^ XOR_KEYS[i]))
    for i in range(len(enc)):
        enc[i] = b64encode(enc[i].encode()).decode()
    for i in range(len(enc)):
        enc[i] = xor(enc[i], BASE_KEY)
    for i in range(len(enc)):
        enc[i] = b64encode(enc[i].encode()).decode()
    return enc

x = ['JD0CEw==', 'JAMoWQ==', 'JwMCVA==', 'JwMCVA==', 'Ji0kVA==', 'JxMCVA==', 'JAM4EQ==', 'JAM8EA==', 'JD0oEA==', 'JD0KHg==', 'JwM8VA==', 'JAMoEQ==', 'JAMoEw==', 'JBMoVA==', 'Ji0OVA==', 'JD0sHg==', 'Ji0KVA==', 'Jj0OVA==', 'JD0kWg==', 'JD0KWQ==', 'JBMOVA==', 'JAMOVA==', 'Jz0kVA==', 'JD0CHg==', 'JwMoVA==', 'JD0wHg==', 'JD0gEw==', 'JwMgVA==', 'JihUVA==', 'Jy0gVA==', 'Ji0gVA==', 'JAMCVA==', 'JAMOVA==', 'JAM8VA==', 'Jj0sVA==', 'JD04EQ==', 'JD0CWA==', 'JD04Hg==', 'JD04Hg==', 'JD0sXQ==', 'JxM4VA==', 'JxMCVA==', 'JAMwVA==', 'Jz08VA==', 'JD0wXQ==', 'JAM4XQ==', 'JBMsVA==', 'JAMgXQ==', 'JAMgXQ==', 'JD0wHg==', 'JAMoWg==']

print("Well, hello there.")
```

The code does nothing exciting (except specifying an array with more `base64` encoded strings and printing a message). The functions are not called at all. But we can guess that `x` actually is the result of calling `encode`, so we need to reverse encode to hopefully get the flag.

```python
# NOTE: keep XOR_KEYS, BASE_KEY, xor and x as before

def decode(enc):
    flag = ""
    for i in range(len(enc)):
        enc[i] = b64decode(enc[i]).decode()
    for i in range(len(enc)):
        enc[i] = xor(enc[i], BASE_KEY)
    for i in range(len(enc)):
        enc[i] = b64decode(enc[i].encode()).decode()
    for i in range(len(enc)):
        flag += chr(int(enc[i]) ^ XOR_KEYS[i])
    return flag

print(decode(x))
```

Flag `AOFCTF{wh0_kn3w_c_4nd_pyth0n_w0uld_b3_th1s_p4inful}`