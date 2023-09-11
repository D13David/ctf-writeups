# CyberHeroines 2023

## Lenore Blum

> [Lenore Carol Blum](https://en.wikipedia.org/wiki/Lenore_Blum) (née Epstein born December 18, 1942) is an American computer scientist and mathematician who has made contributions to the theories of real number computation, cryptography, and pseudorandom number generation. She was a distinguished career professor of computer science at Carnegie Mellon University until 2019 and is currently a professor in residence at the University of California, Berkeley. She is also known for her efforts to increase diversity in mathematics and computer science. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Lenore_Blum)
> 
> Chal: Connect to 0.cloud.chals.io 28827 and return the flag to the computational mathematics professor [from this random talk](https://www.youtube.com/watch?v=GlKyizqdGIY)
>
>  Author: [Robbie](https://github.com/Robster4911)
>
> [`chal.bin`](chal.bin)

Tags: _crypto_

## Solution
When we connect to the service we have the option to play a little guessing game. We get a `seed` and then have to guess a random number. To see how things work we can open the attached binary with `Gidra`.

```bash
$ nc 0.cloud.chals.io 28827
Lets play a little game.
I give you a seed, and you guess my random number.
Would you like to play? Y/N >>> y
Here is my seed: 86275273
Can you guess my random number? >>> 1337
Incorrect. My random number was 1059388257381471813
```

```c
  printf(
        "Lets play a little game.\nI give you a seed, and you guess my random number.\nWould you lik e to play? Y/N >>> "
        );
  local_31 = 'n';
  __isoc99_scanf(&DAT_00402095,&local_31);
  if (local_31 == 'y') {
    while( true ) {
      tVar2 = time((time_t *)0x0);
      srand((uint)tVar2);
      iVar1 = rand();
      local_10 = (long)(iVar1 % 65000);
      local_18 = find_prime_congruent_to_3_mod_4(local_10);
      local_20 = find_prime_congruent_to_3_mod_4(local_18 + 1);
      local_28 = local_10 * 0x539;
      printf("Here is my seed: %lld\nCan you guess my random number? >>> ",local_28);
      local_40 = 0;
      __isoc99_scanf(&DAT_004020d3,&local_40);
      local_30 = bbs(local_18,local_20,local_28);
      if (local_30 == local_40) break;
      printf("Incorrect. My random number was %lld\n",local_30);
    }
    puts("Great job! Here\'s your prize:");
    print_file("flag.txt");
```

As we can see the application uses `srand(time(NULL))` to initialize the `RNG`. Then it takes a 32 bit random number mod 65000 (seed) and calculates two prime numbers congruent to 3 mod 4. The seed we get is multiplied with `1337`. Then the user input is requested and afterwards everything goes into a function called `bbs`.

Since we have have the input for `find_prime_congruent_to_3_mod_4` lets see what this function does.

```c
long find_prime_congruent_to_3_mod_4(long param_1)
{
  char cVar1;
  long local_10;
  
  local_10 = param_1;
  while( true ) {
    cVar1 = is_prime(local_10);
    if ((cVar1 != '\0') && (((uint)local_10 & 3) == 3)) break;
    local_10 = local_10 + 1;
  }
  return local_10;
}

ulong bbs(long param_1,long param_2,long param_3)
{
  int local_1c;
  ulong local_18;
  ulong local_10;
  
  local_10 = (ulong)(param_3 * param_3) % (ulong)(param_1 * param_2);
  local_18 = 0;
  for (local_1c = 0; local_1c < 0x3f; local_1c = local_1c + 1) {
    local_10 = (local_10 * local_10) % (ulong)(param_1 * param_2);
    local_18 = local_18 | (ulong)((uint)local_10 & 1) << ((byte)local_1c & 0x3f);
  }
  return local_18;
}
```

This is easy enough and does exactly what the function name said. Since we have the *seed* we can calculate the exact two numbers locally as well putting them through `bbs` generating the same number as the service does.

```python
import sympy

def find(num):
    while True:
        if sympy.isprime(num) and (num & 3) == 3:
            break
        num = num + 1
    return num

seed = 14864766
prime1 = find(seed//1337)
prime2 = find(prime1+1)

local_10 = (seed * seed) % (prime1 * prime2)
local_18 = 0
for i in range(0, 0x3f):
    local_10 = (local_10*local_10) % (prime1 * prime2)
    local_18 = local_18 | (local_10 & 1) << (i & 0x3f)

print(local_18)
```

Lets play another round, this time we guess correct and get the flag.

```bash
$ nc 0.cloud.chals.io 28827
Lets play a little game.
I give you a seed, and you guess my random number.
Would you like to play? Y/N >>> y
Here is my seed: 14864766
Can you guess my random number? >>> 198617183237813426
Great job! Here's your prize:
chctf{tH3_f1rsT_Blum}
```

Flag `chctf{tH3_f1rsT_Blum}`