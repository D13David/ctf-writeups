# BuckeyeCTF 2023

## Rivest-Shamir-Adleman

> Big numbers make big security
> 
>  Author: jm8
>
> [`dist.py`](dist.py)

Tags: _crypto_

## Solution
For this challenge we get some vanilla RSA in code, we have all properties, even `d` is calculated for us. The only thing we need to do is to decrypt `c`.

```python
message = b"[REDACTED]"

m = int.from_bytes(message, "big")

p = 3782335750369249076873452958462875461053
q = 9038904185905897571450655864282572131579
e = 65537

n = p * q
et = (p - 1) * (q - 1)
d = pow(e, -1, et)

c = pow(m, e, n)

print(f"e = {e}")
print(f"n = {n}")
print(f"c = {c}")


# OUTPUT:
# e = 65537
# n = 34188170446514129546929337540073894418598952490293570690399076531159358605892687
# c = 414434392594516328988574008345806048885100152020577370739169085961419826266692
```

```python
>>> long_to_bytes(pow(c, d, n))
b'bctf{1_u53d_y0ur_k3y_7h4nk5}'
```

Flag `bctf{1_u53d_y0ur_k3y_7h4nk5}`