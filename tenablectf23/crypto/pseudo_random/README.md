# Tenable Capture the Flag 2023

## PseudoRandom

> We were given the following code and output. Find our mistake and tell us the flag.
>
>  Author: N/A
>

Tags: _crypto_

## Solution
As input for this challenge, the following code and data is given

Code
```python
import random
import time
import datetime  
import base64

from Crypto.Cipher import AES
flag = b"find_me"
iv = b"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

for i in range(0, 16-(len(flag) % 16)):
    flag += b"\0"

ts = time.time()

print("Flag Encrypted on %s" % datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M'))
seed = round(ts*1000)

random.seed(seed)

key = []
for i in range(0,16):
    key.append(random.randint(0,255))

key = bytearray(key)


cipher = AES.new(key, AES.MODE_CBC, iv) 
ciphertext = cipher.encrypt(flag)

print(base64.b64encode(ciphertext).decode('utf-8'))
```

Output
```
Flag Encrypted on 2023-08-02 10:27
lQbbaZbwTCzzy73Q+0sRVViU27WrwvGoOzPv66lpqOWQLSXF9M8n24PE5y4K2T6Y
```

The flag is encrypted with `AES CBC`. For this, the initialization vector is known. Also we can see that the key is generated as a sequence of (pseudo-) random values. This is important, since the output leaks the time which is also used as `random seed`.

Knowing this, we can recreate the key by finding the correct seed first. It must be noted here, that only creating a timestamp from the date is not enough, since the timestamp will be depending on the timezone. Since we don't know the location where (on earth) the flag was encrypted we have to guess or search all timezones. The second thing to be noted here is that the resolution of the timestamp *can* in fact be smaller than a second. Since the timestamp is multiplied with 1000 we can assume that we need millisecond precicion, this adds again some more pressure on our search space.

```python
import random
import time
import base64
import datetime
from datetime import timedelta
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad, pad

seeds = []
for i in range(-13, 13):
    for j in range(0,60):
        t = datetime.datetime(2023, 8, 2, 10, 27, 0)
        t = t + timedelta(hours=i)
        t = t + timedelta(seconds=j)
        for k in range(0,9999):
            seeds.append((i, round(t.timestamp()*1000)+k))

iv = b"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
ct = base64.b64decode("lQbbaZbwTCzzy73Q+0sRVViU27WrwvGoOzPv66lpqOWQLSXF9M8n24PE5y4K2T6Y")

for time_zone, seed in seeds:
    random.seed(seed)

    key = []
    for i in range(0,16):
        key.append(random.randint(0,255))
    key = bytearray(key)

    cipher = AES.new(key, AES.MODE_CBC, iv)
    msg = cipher.decrypt(ct)

    if msg.startswith(b"flag{"):
        print(time_zone, msg)
        break
```

The timestamp found is `1690986434439`, this is located in UTC+8 timezone. Knowing that the CTF was held on three physical locations `Las Vegas`, `Singapore` and `Sydney`. A good guess would have been to test for the three timezones and indeed `Singapore` would have been a match.

After getting the correct timestamp and setting it as seed. The sequence random generates will give the correct key since the generated numbers are deterministic. Having this all in place the flag can be decoded.

Flag `flag{r3411y_R4nd0m_15_R3ally_iMp0r7ant}`