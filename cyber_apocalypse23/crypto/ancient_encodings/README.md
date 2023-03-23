# Cyber Apocalypse 2023

## Ancient Encodings

> Your initialization sequence requires loading various programs to gain the necessary knowledge and skills for your journey. Your first task is to learn the ancient encodings used by the aliens in their communication.
>
>  Author: N/A
>
> [`crypto_ancient_encodings.zip`](crypto_ancient_encodings.zip)

Tags: _crypto_

## Solution
Provided are two files one python script and a text file with some encrypted data. Looking at the python script we can se that encryption really is ancient. The flag is base64 encoded and than converted to a hex string. 

```python
def encode(message):
    return hex(bytes_to_long(b64encode(message)))
```

This is easy to reverse
```bash
$ python -c "from Crypto.Util.number import long_to_bytes;print(long_to_bytes(0x53465243657a467558336b7764584a66616a4231636d347a655639354d48566664326b786246397a5a544e66644767784e56396c626d4d775a4446755a334e665a58597a636e6c33614756794d33303d).decode())" | base64 -d
HTB{1n_y0ur_j0urn3y_y0u_wi1l_se3_th15_enc0d1ngs_ev3rywher3}
```