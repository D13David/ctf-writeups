# AmateursCTF 2023

## You get extra information 1

>
>  Author: hellopir2
>
> [`main.py`](main.py) [`output.txt`](output.txt)

Tags: _crypto_

## Solution
This challenge comes with a encoder source code and the generated output. The source code is quite short:

```python
from Crypto.Util.number import *
from flag import flag

p = getPrime(512)
q = getPrime(512)
n = p*q
p = p + q
e = 0x10001

extra_information = p + q
ptxt = bytes_to_long(flag)
c = pow(ptxt, e, n)

with open('output.txt', 'w') as f:
    f.write(f"n: {n}\nc: {c}\ne: {e}\nextra_information: {extra_information}")
```

This looks like vanilla RSA but there is an extra hint leaked that will help to retrieve `p` and `q`. The extra information is associated with p and q like `extra = 2q + p`. To retrieve p and q we can use `z3`.

```python
from Crypto.Util.number import long_to_bytes
from z3 import *

n = 83790217241770949930785127822292134633736157973099853931383028198485119939022553589863171712515159590920355561620948287649289302675837892832944404211978967792836179441682795846147312001618564075776280810972021418434978269714364099297666710830717154344277019791039237445921454207967552782769647647208575607201
c = 55170985485931992412061493588380213138061989158987480264288581679930785576529127257790549531229734149688212171710561151529495719876972293968746590202214939126736042529012383384602168155329599794302309463019364103314820346709676184132071708770466649702573831970710420398772142142828226424536566463017178086577
e = 65537
summed = 26565552874478429895594150715835574472819014534271940714512961970223616824812349678207505829777946867252164956116701692701674023296773659395833735044077013

s = Solver()
p = Int("p")
q = Int("q")
s.add(p + 2*q == summed)
s.add(p * q == n)
s.check()
model = s.model()

p = model[p].as_long()
q = model[q].as_long()

print("p", p)
print("q", q)

phi = (p-1)*(q-1)
d = pow(e, -1, phi)

print(long_to_bytes(pow(c, d, n)))
```

With p and q at hand the private key `(d, phi)` is easy to calculate and the flag can be decrypted.

Flag `amateursCTF{harder_than_3_operations?!?!!}`