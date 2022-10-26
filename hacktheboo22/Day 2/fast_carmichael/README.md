# Hack The Boo 2022

## Fast Carmichael

> You are walking with your friends in search of sweets and discover a mansion in the distance. All your friends are too scared to approach the building, so you go on alone. As you walk down the street, you see expensive cars and math papers all over the yard. Finally, you reach the door. The doorbell says "Michael Fastcar". You recognize the name immediately because it was on the news the day before. Apparently, Fastcar is a famous math professor who wants to get everything done as quickly as possible. He has even developed his own method to quickly check if a number is a prime. The only way to get candy from him is to pass his challenge.
>
>  Author: N/A
>
> [`crypto_fast_carmichael.zip`](crypto_fast_carmichael.zip)

Tags: _crypto_

## Preparation
From the code the condition to be met so that the flag is revleaed is the following

```python
if _isPrime(p) and not isPrime(p):
    sendMessage(s, FLAG)
else:
    sendMessage(s, "Conditions not satisfied!")
```

Looks like the number entered is tested to be prime with two different approaches. Since ```_isPrime``` is handcrafted lets further inspect this:

```python
def _isPrime(p):
    if p < 1:
        return False
    if (p.bit_length() <= 600) and (p.bit_length() > 1500):
        return False
    if not millerRabin(p, 300):
        return False

    return True
```

The function uses a *millerRabin* test and has a strange condition, most likely a typo that can be exploited. So the target should be to find a number that is not *prime* but *millerRabin* is tricked to think it is. One hint comes from the challenge title, some *carmichael numbers* seem to have the fitting property.

## Solution
There are surely very involved ways to generate such numbers, but a bit of research led to a quicker solution in this case.

```
$ nc 161.35.162.249 30176
Give p: 2887148238050771212671429597130393991977609459279722700926516024197432303799152733116328983144639225941977803110929349655578418949441740933805615113979999421542416933972905423711002751042080134966731755152859226962916775325475044445856101949404200039904432116776619949629539250452698719329070373564032273701278453899126120309244841494728976885406024976768122077071687938121709811322297802059565867

HTB{c42m1ch431_num8325_423_fun_p53ud0p21m35}
```