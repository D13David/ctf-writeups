# UIUCTF 2023

## At Home

> Mom said we had food at home
>
>  Author: Anakin
>
> [`chal.py`](chal.py)
> [`chal.txt`](chal.txt)

Tags: _crypto_

## Solution
For this challenge we have two files. A generator script and the output of the script containing the encrypted flag. 

```
from Crypto.Util.number import getRandomNBitInteger

flag = int.from_bytes(b"uiuctf{******************}", "big")

a = getRandomNBitInteger(256)
b = getRandomNBitInteger(256)
a_ = getRandomNBitInteger(256)
b_ = getRandomNBitInteger(256)

M = a * b - 1
e = a_ * M + a
d = b_ * M + b

n = (e * d - 1) // M

c = (flag * e) % n

print(f"{e = }")
print(f"{n = }")
print(f"{c = }")
```

Most of the code can be ignored, the interesting part is how the encryption is done: `c = (flag * e) % n`. Since we have `n` and `e` we can retrieve the flag by multiplying `c` with the inverse of `e`.

`c = (flag * e) % n`\
`c * e^-1 = (flag * e * e^-1) % n`\
`c * e^-1 = flag % n`

```python
from Crypto.Util.number import inverse

e = 359050389152821553416139581503505347057925208560451864426634100333116560422313639260283981496824920089789497818520105189684311823250795520058111763310428202654439351922361722731557743640799254622423104811120692862884666323623693713
n = 26866112476805004406608209986673337296216833710860089901238432952384811714684404001885354052039112340209557226256650661186843726925958125334974412111471244462419577294051744141817411512295364953687829707132828973068538495834511391553765427956458757286710053986810998890293154443240352924460801124219510584689
c = 67743374462448582107440168513687520434594529331821740737396116407928111043815084665002104196754020530469360539253323738935708414363005373458782041955450278954348306401542374309788938720659206881893349940765268153223129964864641817170395527170138553388816095842842667443210645457879043383345869

d = inverse(e, n)
flag = (c * d) % n
print(flag.to_bytes((flag.bit_length() + 7) // 8, 'big'))
```

Flag `uiuctf{W3_hav3_R5A_@_h0m3}`