# Cyber Apocalypse 2023

## Small StEps

> As you continue your journey, you must learn about the encryption method the aliens used to secure their communication from eavesdroppers. The engineering team has designed a challenge that emulates the exact parameters of the aliens' encryption system, complete with instructions and a code snippet to connect to a mock alien server. Your task is to break it.
>
>  Author: N/A
>
> [`crypto_small_steps.zip`](crypto_small_steps.zip)

Tags: _crypto_

## Solution
Inspecting the provided python code we can see text is encrypted with RSA. The weak point is that `e` is choosen to be very small. Therefore a valid approach is to just inverse the encryption by [`taking the eth-root`](solution.py).

```python
from gmpy2 import iroot
from Crypto.Util.number import long_to_bytes

e = 3 
flag = 70407336670535933819674104208890254240063781538460394662998902860952366439176467447947737680952277637330523818962104685553250402512989897886053

print(long_to_bytes(iroot(flag, e)[0]).decode())
```

Calling this gives the flag `HTB{5ma1l_E-xp0n3nt}`.