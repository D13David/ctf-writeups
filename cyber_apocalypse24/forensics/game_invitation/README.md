# Cyber Apocalypse 2024

## Game Invitation

> In the bustling city of KORP™, where factions vie in The Fray, a mysterious game emerges. As a seasoned faction member, you feel the tension growing by the minute. Whispers spread of a new challenge, piquing both curiosity and wariness. Then, an email arrives: "Join The Fray: Embrace the Challenge." But lurking beneath the excitement is a nagging doubt. Could this invitation hide something more sinister within its innocent attachment?
> 
> Author: thewildspirit
> 
> [`forensics_game_invitation.zip`](fforensics_game_invitation.zip)

Tags: _forensics_

## Solution
For this challenge, we get a `word document`. First thing, we try to extract potential `VBA` scripts.

```bash
$ olevba invitation.docm
olevba 0.60.1 on Python 2.7.18 - http://decalage.info/python/oletools
===============================================================================
FILE: invitation.docm
Type: OpenXML
WARNING  For now, VBA stomping cannot be detected for files in memory
-------------------------------------------------------------------------------
VBA MACRO ThisDocument.cls
in file: word/vbaProject.bin - OLE stream: u'VBA/ThisDocument'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(empty macro)
-------------------------------------------------------------------------------
VBA MACRO NewMacros.bas
in file: word/vbaProject.bin - OLE stream: u'VBA/NewMacros'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Public IAiiymixt As String
Public kWXlyKwVj As String


Function JFqcf
...
```

And indeed, we get a [`result`](stage1.vb). After cleaning up a bit, we can see the script searches for the pattern `sWcDWp36x5oIe2hJGnRy1iC92AcdQgO8RLioVZWlhCKJXHRSqO450AiqLZyLFeXYilCtorg0p3RdaoPa` inside the document and extracts a chunk of data from there. Then decodes the data and finally saves it as `mailform.js`. To grab the data I wrote a small script:

```python
def Decrypt(buffer):
    key = 45
    for i in range(len(buffer)):
        buffer[i] = buffer[i] ^ key
        key = ((key ^ 99) ^ (i % 254))

data = open("invitation.docm", "rb").read()
offset = data.index(b"sWcDWp36x5oIe2hJGnRy1iC92AcdQgO8RLioVZWlhCKJXHRSqO450AiqLZyLFeXYilCtorg0p3RdaoPa") + 80

payload = bytearray(data[offset:offset+13082])
Decrypt(payload)
print(payload.decode())
```

The new file again does some decryption of a payload. First it takes an input argument and some decrypted payload. The input argument we can see in the `vb-script` is `vF8rdgMHKBrvCoCp0ulm` and is used as decryption key. Cleaned up we can write another python script to decode the data, but instead of invoking the decoded data we rather look at it carefully.

```python
key = b"vF8rdgMHKBrvCoCp0ulm"
data = b"cxbDX..."

t = [i for i in range(256)]
l = 0

for i in range(256):
    l = (l + t[i] + key[i%len(key)]) % 255:
    h = t[i]
    t[i] = t[l]
    t[l] = h

g = 0
l = 0
u = ""
for i in range(len(data)):
    g = (g+1) % 256
    l = (l+t[g]) % 256
    h = t[g]
    t[g] = t[l]
    t[l] = h
    u += chr(data[i]^t[(t[g]+t[l])%256])

print(u)
```

The resulting script is rather length, but it contains `S47T.SETREQUESTHEADER("Cookie:","flag=SFRCe200bGQwY3NfNHIzX2czdHQxbmdfVHIxY2tpMTNyfQo=");`. So this might be worth a shot, decoding the base64 value gives us the flag.

Flag `HTB{m4ld0cs_4r3_g3tt1ng_Tr1cki13r}`