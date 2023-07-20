# AmateursCTF 2023

## You get extra information 2

> You get more information! More complicated = more information right.
>
>  Author: hellopir2
>
> [`main.py`](main.py) [`output.txt`](output.txt)

Tags: _crypto_

## Solution
This challenge basically is the same as [`You get extra information 1`](../you_get_extra_info_1/README.md) except the constraint for extra information is much more complicated `extra_information = (n**2)*(p**3 + 5*(p+1)**2) + 5*n*q + q**2`. This again can be solved quickly with `z3`.

```python
s = Solver()
p = Int("p")
q = Int("q")
s.add((n**2)*(p**3 + 5*(p+1)**2) + 5*n*q + q**2 == summed)
s.add(p * q == n)
s.check()
model = s.model()

p = model[p].as_long()
q = model[q].as_long()

print("p", p)
print("q", q)
```

After a while `z3` comes back with `p` and `q`
```
p 12592515782077404137849236994955837609500154464782855076585955501637937872493619036975469814859697874798733737517472127306855726944300236711447248402640349
q 7591285472030363593819309149475285775894683777302616308552541051471117604695830085885971123084425024738819800112718432254917427153283662301475561286492279
```

With p and q at hand the private key `(d, phi)` is easy to calculate and the flag can be decrypted.

Flag `amateursCTF{omg_it's_my_favorite_epic_thing_where_it_looks_like_a_binomial!!}`