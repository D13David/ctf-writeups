# Cyber Apocalypse 2024

## Dynastic

> You find yourself trapped inside a sealed gas chamber, and suddenly, the air is pierced by the sound of a distorted voice played through a pre-recorded tape. Through this eerie transmission, you discover that within the next 15 minutes, this very chamber will be inundated with lethal hydrogen cyanide. As the tape’s message concludes, a sudden mechanical whirring fills the chamber, followed by the ominous ticking of a clock. You realise that each beat is one step closer to death. Darkness envelops you, your right hand restrained by handcuffs, and the exit door is locked. Your situation deteriorates as you realise that both the door and the handcuffs demand the same passcode to unlock. Panic is a luxury you cannot afford; swift action is imperative. As you explore your surroundings, your trembling fingers encounter a torch. Instantly, upon flipping the switch, the chamber is bathed in a dim glow, unveiling cryptic letters etched into the walls and a disturbing image of a Roman emperor drawn in blood. Decrypting the letters will provide you the key required to unlock the locks. Use the torch wisely as its battery is almost drained out!
> 
> Author: aris
> 
> [`crypto_dynastic.zip`](crypto_dynastic.zip)

Tags: _crypto_

## Solution
We get some code of a implementation of the [`Trithemius Cipher`](https://en.wikipedia.org/wiki/Tabula_recta) and the ciphertext.

```php
def to_identity_map(a):
    return ord(a) - 0x41

def from_identity_map(a):
    return chr(a % 26 + 0x41)

def encrypt(m):
    c = ''
    for i in range(len(m)):
        ch = m[i]
        if not ch.isalpha():
            ech = ch
        else:
            chi = to_identity_map(ch)
            ech = from_identity_map(chi + i)
        c += ech
    return c
```

Reversing this algorithm is simple:

```php
def decrypt(c):
    m = ''
    for i in range(len(c)):
        ch = c[i]
        if not ch.isalpha():
            dch = ch
        else:
            chi = to_identity_map(ch)
            dch = from_identity_map(chi - i)
        m += dch
    return m
```

Running this, gives us the flag.

Flag `HTB{DID_YOU_KNOW_ABOUT_THE_TRITHEMIUS_CIPHER?!_IT_IS_SIMILAR_TO_CAESAR_CIPHER}`

## Makeshift

> Weak and starved, you struggle to plod on. Food is a commodity at this stage, but you can’t lose your alertness - to do so would spell death. You realise that to survive you will need a weapon, both to kill and to hunt, but the field is bare of stones. As you drop your body to the floor, something sharp sticks out of the undergrowth and into your thigh. As you grab a hold and pull it out, you realise it’s a long stick; not the finest of weapons, but once sharpened could be the difference between dying of hunger and dying with honour in combat.
> 
> Author: ir0nstone
> 
> [`crypto_makeshift.zip`](crypto_makeshift.zip)

Tags: _crypto_

## Solution
We get the source code of a algorithm that scrambles blocks of three characters. 

```python
flag = FLAG[::-1]
new_flag = ''

for i in range(0, len(flag), 3):
    new_flag += flag[i+1]
    new_flag += flag[i+2]
    new_flag += flag[i]

print(new_flag)
```

Running the same algorithm again on the ciphertext will give the decrypted message.

Flag `HTB{4_b3tTeR_w3apOn_i5_n3edeD!?!}`

## Primary Knowledge

> Surrounded by an untamed forest and the serene waters of the Primus river, your sole objective is surviving for 24 hours. Yet, survival is far from guaranteed as the area is full of Rattlesnakes, Spiders and Alligators and the weather fluctuates unpredictably, shifting from scorching heat to torrential downpours with each passing hour. Threat is compounded by the existence of a virtual circle which shrinks every minute that passes. Anything caught beyond its bounds, is consumed by flames, leaving only ashes in its wake. As the time sleeps away, you need to prioritise your actions secure your surviving tools. Every decision becomes a matter of life and death. Will you focus on securing a shelter to sleep, protect yourself against the dangers of the wilderness, or seek out means of navigating the Primus’ waters?
> 
> Author: aris
> 
> [`crypto_primary_knowledge.zip`](crypto_primary_knowledge.zip)

Tags: _crypto_

## Solution
We get the source of a pretty vanilla `RSA` implementation. The only thing to note is that `n` is only a single `prime` (since range(2**0) equals range(1)). Therefore `phi = n-1`.

```python
m = bytes_to_long(FLAG)

n = math.prod([getPrime(1024) for _ in range(2**0)])
e = 0x10001
c = pow(m, e, n)

with open('output.txt', 'w') as f:
    f.write(f'{n = }\n')
    f.write(f'{e = }\n')
    f.write(f'{c = }\n')
```

```python
n = 144595784022187052238125262458232959109987136704231245881870735843030914418780422519197073054193003090872912033596512666042758783502695953159051463566278382720140120749528617388336646147072604310690631290350467553484062369903150007357049541933018919332888376075574412714397536728967816658337874664379646535347
e = 65537
c = 15114190905253542247495696649766224943647565245575793033722173362381895081574269185793855569028304967185492350704248662115269163914175084627211079781200695659317523835901228170250632843476020488370822347715086086989906717932813405479321939826364601353394090531331666739056025477042690259429336665430591623215

phi = n-1
d = pow(e, -1, phi)

print(long_to_bytes(pow(c, d, n)))
```

Flag `HTB{0h_d4mn_4ny7h1ng_r41s3d_t0_0_1s_1!!!}`

## Iced TEA

> Locked within a cabin crafted entirely from ice, you're enveloped in a chilling silence. Your eyes land upon an old notebook, its pages adorned with thousands of cryptic mathematical symbols. Tasked with deciphering these enigmatic glyphs to secure your escape, you set to work, your fingers tracing each intricate curve and line with determination. As you delve deeper into the mysterious symbols, you notice that patterns appear in several pages and a glimmer of hope begins to emerge. Time is flying and the temperature is dropping, will you make it before you become one with the cabin?
> 
> Author: aris
> 
> [`crypto_iced_tea.zip`](crypto_iced_tea.zip)

Tags: _crypto_

## Solution
We get a implementation of [`Tiny Encryption Algorithm`](https://en.wikipedia.org/wiki/Tiny_Encryption_Algorithm). Our message is encrypted with `ECB mode` since no `iv` is specified. This simplifies the challenge quite a bit.

```python
class Cipher:
  def __init__(self, key, iv=None):
          self.BLOCK_SIZE = 64
          self.KEY = [b2l(key[i:i+self.BLOCK_SIZE//16]) for i in range(0, len(key), self.BLOCK_SIZE//16)]
          self.DELTA = 0x9e3779b9
          self.IV = iv
          if self.IV:
              self.mode = Mode.CBC
          else:
              self.mode = Mode.
# ...
if __name__ == '__main__':
    KEY = os.urandom(16)
    cipher = Cipher(KEY)
    ct = cipher.encrypt(FLAG)
    with open('output.txt', 'w') as f:
        f.write(f'Key : {KEY.hex()}\nCiphertext : {ct.hex()}')
```

Writing the inverse of `encrypt_block` and running on the ciphertext gives us the flag.

```python
def decrypt_block(self, ct_block):
        c = b2l(ct_block)
        msk = (1 << (self.BLOCK_SIZE//2)) - 1

        m0 = c >> (self.BLOCK_SIZE//2)
        m1 = c & msk

        K = self.KEY

        s = self.DELTA << 5
        for i in range(32):
            m1 -= ((m0 << 4) + K[2]) ^ (m0 + s) ^ ((m0 >> 5) + K[3])
            m1 &= msk
            m0 -= ((m1 << 4) + K[0]) ^ (m1 + s) ^ ((m1 >> 5) + K[1])
            m0 &= msk
            s -= self.DELTA

        m = ((m0 << (self.BLOCK_SIZE//2)) + m1) & ((1 << self.BLOCK_SIZE) - 1)  # m = m0 || m1

        return l2b(m)
```

Flag `HTB{th1s_1s_th3_t1ny_3ncryp710n_4lg0r1thm_____y0u_m1ght_h4v3_4lr34dy_s7umbl3d_up0n_1t_1f_y0u_d0_r3v3rs1ng}`

## Blunt

> Valuing your life, you evade the other parties as much as you can, forsaking the piles of weaponry and the vantage points in favour of the depths of the jungle. As you jump through the trees and evade the traps lining the forest floor, a glint of metal catches your eye. Cautious, you creep around, careful not to trigger any sensors. Lying there is a knife - damaged and blunt, but a knife nonetheless. You’re not helpless any more.
> 
> Author: ir0nstone
> 
> [`crypto_blunt.zip`](crypto_blunt.zip)

Tags: _crypto_

## Solution
We get some code that looks like a [`Diffie–Hellman key exchange`](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange). 

```python
p = getPrime(32)
print(f'p = 0x{p:x}')

g = random.randint(1, p-1)
print(f'g = 0x{g:x}')

a = random.randint(1, p-1)
b = random.randint(1, p-1)

A, B = pow(g, a, p), pow(g, b, p)

print(f'A = 0x{A:x}')
print(f'B = 0x{B:x}')

C = pow(A, b, p)
assert C == pow(B, a, p)

# now use it as shared secret
hash = sha256()
hash.update(long_to_bytes(C))

key = hash.digest()[:16]
iv = b'\xc1V2\xe7\xed\xc7@8\xf9\\\xef\x80\xd7\x80L*'
cipher = AES.new(key, AES.MODE_CBC, iv)

encrypted = cipher.encrypt(pad(FLAG, 16))
print(f'ciphertext = {encrypted}')
```

Since the prime number `p` is very small we can recover `p` by bruteforcing it. A more elegant solution would be to use the `discrete logarithm` of `B` (or `A`) to retrieve one of the private exponens to calculate `C`. This is easily possible as `p` is so small.

```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from Crypto.Util.number import getPrime, long_to_bytes
from hashlib import sha256

from secret import FLAG

import random


p = getPrime(32)
print(f'p = 0x{p:x}')

g = random.randint(1, p-1)
print(f'g = 0x{g:x}')

a = random.randint(1, p-1)
b = random.randint(1, p-1)

A, B = pow(g, a, p), pow(g, b, p)

print(f'A = 0x{A:x}')
print(f'B = 0x{B:x}')

C = pow(A, b, p)
assert C == pow(B, a, p)

# now use it as shared secret
hash = sha256()
hash.update(long_to_bytes(C))

key = hash.digest()[:16]
iv = b'\xc1V2\xe7\xed\xc7@8\xf9\\\xef\x80\xd7\x80L*'
cipher = AES.new(key, AES.MODE_CBC, iv)

encrypted = cipher.encrypt(pad(FLAG, 16))
print(f'ciphertext = {encrypted}')
```

Flag `HTB{y0u_n3ed_a_b1gGeR_w3ap0n!!}`