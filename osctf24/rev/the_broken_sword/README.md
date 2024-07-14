# OS CTF 2024

## The Broken Sword

> The time for the reforging of the The Sword That Was Broken has come.. Elendil left a riddle, solving which will give the password, which is what you need to find :p..
> 
> Flag Format: OSCTF{valueof'flag'variable_valueof'a'variable_valueof'v2'variable} / OSCTF{flag_a_v2}
>
>  Author: @Inv1s1bl3
>
> [`challenge.py`](challenge.py), [`variables.txt`])(variables.txt)

Tags: _rev_

## Solution
For this challenge we get a small python script and the output of said script. Lets have a look at the script.

```python
from Crypto.Util.number import *
from secret import flag,a,v2,pi

z1 = a+flag
y = long_to_bytes(z1)
print("The message is",y)
s = ''
s += chr(ord('a')+23)
v = ord(s)
f = 5483762481^v
g = f*35


r = 14
l = g
surface_area= pi*r*l
w = surface_area//1
s = int(f)
v = s^34
for i in range(1,10,1):
    h = v2*30
    h ^= 34
    h *= pi
    h /= 4567234567342
a += g+v2+f
a *= 67 
al=a
print("a1:",al)
print('h:',h)
```

This looks all very messy and in fact, the code can be cleaned up quite a bit. Appart from using weird naming it also does quite some unneeded work. All in all we can remove a lot of the variables and intermediate calculations, for instance.

```py
s = ''
s += chr(ord('a')+23)
```

This can be easily shortened to `s = 'x'`. Now we see s is only used in the expression `v = ord(s)` and nowhere else. So we can get rid of `s` alltogether and end up with `v = 120`. We also can get rid of `v`, since it's only used in `f = 5483762481^v` and just write `f = 5483762505`, etc... All in all the cleaned script is way shorter.

```py
from Crypto.Util.number import *
from secret import flag,a,v2,pi

print("The message is", long_to_bytes(a+flag))
print("a1:", (a + 197415450180 + v2) * 67)
print('h:', ((v2 * 30) ^ 34) * pi / 4567234567342)
```

We have to find the values for `flag`, `a` and `v2`. But actually we have another unknown value, which is `pi`, since we don't know to which precision pi is specified. So we can just test with increasing precision.

```py
import math_pi

for i in range(10):
    pi = float(math_pi.pi(b=i))
    v2 = (int((0.0028203971921452278 * 4567234567342) / pi) ^ 34) // 30

    if (((v2 * 30) ^ 34) * pi / 4567234567342) == 0.0028203971921452278:
        a = (899433952965498 // 67) - 197415450180 - v2
        flag = 13226864422850 - a
        print(f"OSCTF{{{flag}_{a}_{v2}}}")
        break
```

This gives us the values `flag = 29260723`, `a = 13226835162127` and `v2 = 136745387` for `pi = 3.14`.

Flag `OSCTF{29260723_13226835162127_136745387}`