# LACTF 2023

## very-hot

> I didn't think that using two primes for my RSA was sexy enough, so I used three.
> 
> Author: Red Guy
> 
> [`src.py`](src.py)
> [`out.txt`](out.txt)

Tags: _crypto_

## Solution
This is a pretty vanilla `RSA`challenge. We get `n`, `e` and `ct` as input and the script that was used to generate `out.txt`.

```python
from Crypto.Util.number import getPrime, isPrime, bytes_to_long
from flag import FLAG

FLAG = bytes_to_long(FLAG.encode())

p = getPrime(384)
while(not isPrime(p + 6) or not isPrime(p + 12)):
    p = getPrime(384)
q = p + 6
r = p + 12

n = p * q * r
e = 2**16 + 1
ct = pow(FLAG, e, n)

print(f'n: {n}')
print(f'e: {e}')
print(f'ct: {ct}')
```

We can see that `n` is using three prime factors. To get the factors `factordb` could be used in this case. Having the prime factors the rest is straight forward `rsa`.

```python
p = 21942765653871439764422303472543530148312720769660663866142363370143863717044484440248869144329425486818687730842077
q = 21942765653871439764422303472543530148312720769660663866142363370143863717044484440248869144329425486818687730842083
r = 21942765653871439764422303472543530148312720769660663866142363370143863717044484440248869144329425486818687730842089
phi = (p-1)*(q-1)*(r-1)
d = pow(e, -1, phi)
print(long_to_bytes(pow(ct, d, n)))
```

Flag `lactf{th4t_w45_n0t_so_53xY}`

## hOlyT

> God is trying to talk to you through a noisy wire
> 
> Author: freed
> 
> [`server.py`](server.py)

Tags: _crypto_

## Solution
Packed this challenge together with `very-hot` as the solution here was exactly the same (but probably unintended).

Flag `lactf{1s_r4bin_g0d?}`