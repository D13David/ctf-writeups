# Google CTF 2023

## LEAST COMMON GENOMINATOR?

> Someone used this program to send me an encrypted message but I can't read it! It uses something called an LCG, do you know what it is? I dumped the first six consecutive values generated from it but what do I do with it?!
>
>  Author: N/A
>
> [`attachment.zip`](attachment.zip)

Tags: _crypto_

## Solution
This challenge comes with four files. A python script and three files which are created by the script. One holding the encrypted flag, one holding long integer numbers and a `pem` file holding a public key. The python script looks like this:

```python
from secret import config
from Crypto.PublicKey import RSA
from Crypto.Util.number import bytes_to_long, isPrime

class LCG:
    lcg_m = config.m
    lcg_c = config.c
    lcg_n = config.n

    def __init__(self, lcg_s):
        self.state = lcg_s

    def next(self):
        self.state = (self.state * self.lcg_m + self.lcg_c) % self.lcg_n
        return self.state

if __name__ == '__main__':

    assert 4096 % config.it == 0
    assert config.it == 8
    assert 4096 % config.bits == 0
    assert config.bits == 512

    # Find prime value of specified bits a specified amount of times
    seed = 211286818345627549183608678726370412218029639873054513839005340650674982169404937862395980568550063504804783328450267566224937880641772833325018028629959635
    lcg = LCG(seed)
    primes_arr = []

    dump = True
    items = 0
    dump_file = open("dump.txt", "w")

    primes_n = 1
    while True:
        for i in range(config.it):
            while True:
                prime_candidate = lcg.next()
                if dump:
                    dump_file.write(str(prime_candidate) + '\n')
                    items += 1
                    if items == 6:
                        dump = False
                        dump_file.close()
                if not isPrime(prime_candidate):
                    continue
                elif prime_candidate.bit_length() != config.bits:
                    continue
                else:
                    primes_n *= prime_candidate
                    primes_arr.append(prime_candidate)
                    break

        # Check bit length
        if primes_n.bit_length() > 4096:
            print("bit length", primes_n.bit_length())
            primes_arr.clear()
            primes_n = 1
            continue
        else:
            break

    # Create public key 'n'
    n = 1
    for j in primes_arr:
        n *= j
    print("[+] Public Key: ", n)
    print("[+] size: ", n.bit_length(), "bits")

    # Calculate totient 'Phi(n)'
    phi = 1
    for k in primes_arr:
        phi *= (k - 1)

    # Calculate private key 'd'
    d = pow(config.e, -1, phi)

    # Generate Flag
    assert config.flag.startswith(b"CTF{")
    assert config.flag.endswith(b"}")
    enc_flag = bytes_to_long(config.flag)
    assert enc_flag < n

    # Encrypt Flag
    _enc = pow(enc_flag, config.e, n)

    with open ("flag.txt", "wb") as flag_file:
        flag_file.write(_enc.to_bytes(n.bit_length(), "little"))

    # Export RSA Key
    rsa = RSA.construct((n, config.e))
    with open ("public.pem", "w") as pub_file:
        pub_file.write(rsa.exportKey().decode())
```

The code uses a [`LCG`](https://en.wikipedia.org/wiki/Linear_congruential_generator) to generate primes of a certain bit length. While the total number of primes and the bit length is hidden in a config class which is not available as attachment, the numbers are leaked by asserts.

```python
assert 4096 % config.it == 0
assert config.it == 8
assert 4096 % config.bits == 0
assert config.bits == 512
```

So 8 primes in total are generated with a bit length of 512 bits. From those primes the modulus and totient are created. The code is nice enough also to create the private key which is not used but was probably left as a niceness. Afterwards the flag is encrypted with the public key and written to `flag.txt`. Also the public key is serialized to `public.pem`.

To decode the flag we need to construct `d`. The exponent `e` is available within `public.pem`. To calculate the totient the same 8 primes would be needed, meaning the LCG state needs to be reconstructed. The `seed` is known but `modulus`, `multiplier` and `increment` are hidden within the config.

With some consecutive generated numbers the information can be reconstructed. We can for instance calculate the increment with only two consecutive generated numbers by solving `s_(i+1) = (m*s_i + c) mod n` for c: `c = (s_(i+1) - ms_i) mod n`.

The multiplier can be derived out of three consecutive generated numbers by using `s_(i+1) = (ms_i + c) mod n` and `s_(i+2) = (ms_(i+1) + c) mod n`. Deriving `s_(i+1) - s_(i+2) = m(s_i - s_(i+1)) mod n` and solving for m: `m = (s_(i+1) - s_(i+2)) / (s_i - s_(i+1)) mod n`.

Calculating `m` is a bit more involved, but [`here`](https://security.stackexchange.com/questions/4268/cracking-a-linear-congruential-generator) is a good explanation:

> To recover m, define tn = sn+1 - sn and un = |tn+2 tn - t2n+1|; then with high probability you will have m = gcd(u1, u2, ..., u10). 10 here is arbitrary; if you make it k, then the probability that this fails is exponentially small in k. I can share a pointer to why this works, if anyone is interested.

```python
s0 = 21667716755951840...
s1 = 67292729504676254...
s2 = 22303969033023529...
s3 = 45788477877361437...
s4 = 75783329794790865...
s5 = 25504204432703810...

# reconstructing n
t0 = s1 - s0; t1 = s2 - s1
t2 = s3 - s2; t3 = s4 - s3
t4 = s5 - s4
u = [abs(t2 * t0 - t1 * t1), abs(t3 * t1 - t2 * t2), abs(t4 * t2 - t3 * t3)]
n = reduce(gcd, u)
print("n:", n)

# reconstructing m
m = (s1 - s2) * pow(s0 - s1, -1, n) % n
print("m:", m)

#reconstructing c
c = (s1 - m * s0) % n
print("c:", c)
```

Lucky enough the first 6 consecutive generated numbers are provided with `dump.txt`. So running the script with those numbers gives all the information to initialize LCG with the correct state.

```python
modulus = 8311271273016946265169120092240227882013893131681882078655426814178920681968884651437107918874328518499850252591810409558783335118823692585959490215446923
multiplier = 99470802153294399618017402366955844921383026244330401927153381788409087864090915476376417542092444282980114205684938728578475547514901286372129860608477
increment = 3910539794193409979886870049869456815685040868312878537393070815966881265118275755165613835833103526090552456472867019296386475520134783987251699999776365

class LCG:
    lcg_m = multiplier
    lcg_c = increment
    lcg_n = modulus

    def __init__(self, lcg_s):
        self.state = lcg_s

    def next(self):
        self.state = (self.state * self.lcg_m + self.lcg_c) % self.lcg_n
        return self.state

seed = 211286818345627549183608678726370412218029639873054513839005340650674982169404937862395980568550063504804783328450267566224937880641772833325018028629959635
lcg = LCG(seed)

# ... remaining code stays mostly the same

```

All what is left now is to read the flag and decrypt it with the private key. One tiny note, while long_to_bytes is used to convert the long back to a byte array the flag is not serialized with bytes_to_long but rather using little endian encoding `_enc.to_bytes(n.bit_length(), "little"))`, so reading needs to consider this as `Crypto.Util.number.long_to_bytes` uses big endian encoding.

```python
with open("public.pem", "rb") as file:
    key = RSA.importKey(file.read())

d = pow(key.e, -1, phi)

with open("flag.txt", "rb") as file:
    flag = int.from_bytes(file.read(), "little")

flag = pow(flag, d, n)

print(long_to_bytes(flag))
```

Flag `CTF{C0nGr@tz_RiV35t_5h4MiR_nD_Ad13MaN_W0ulD_b_h@pPy}`