# Codefest CTF 2025

## Guess

> 
> Can you guess the list of numbers in my mind?
>
> Detailed description will be available on connecting to the instance.
>
>  Author: 0xkn1gh7
>

Tags: _ppc_

## Solution
This challenge doesn't come with any attachments, but when we connect to the given netcat endpoint we get a description.

```bash
 ██████╗ ██╗   ██╗███████╗███████╗███████╗
██╔════╝ ██║   ██║██╔════╝██╔════╝██╔════╝
██║  ███╗██║   ██║█████╗  ███████╗███████╗
██║   ██║██║   ██║██╔══╝  ╚════██║╚════██║
╚██████╔╝╚██████╔╝███████╗███████║███████║
 ╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚══════╝

The system will generate a list of numbers. You have to guess the list in exact order.

Here are the constraints on how the luist is built:
1. The list will have at most 2000 elements.
2. Each number in the list can be from 1 to 1000000.
3. Indexing in the list starts from 0.

Initially you will be given N, the number of elements in the list.

You have maximum N queries of the type ? i j and 1 query of type ! a0 a1 a2 ... aN-1.
? i j --> For given i, j indices the server returns ai+aj, the sum of elements at indices i and j. i != j.
! a0 a1 a2 ... aN-1 --> The server returns the flag if list is correct and disconnects otherwise.

All the best!

GIVEN: N = 1553

[1] INPUT:
```

So we have to reconstruct the array. As described we can specify two array indices and get the sum of both values at the specific indices. With this we can reconstruct the first few elements.

```js
s01 = a0 + a1
s02 = a0 + a2
s12 = a1 + a2
```

This gives us
```js
s01 + s02 - s12 = a0 + a1 + a0 + a2 -(a1 + a2) = 2*a0 + a1 + a2 - a1 - a2 = 2*a0
```

Therefore we can retrieve `a0, a1 and a2` like

```js
a0 = (s01 + s02 - s12) / 2
a1 = s01 - a0
a2 = s02 - a0
```

The remaining values can be just reconstructed by using one of the known values in the query pair. The following script does exactly this.

```python
from pwn import *
from tqdm import tqdm

def query(idx0, idx1):
    p.sendlineafter(b"INPUT: ", f"? {idx0} {idx1}".encode())
    p.recvuntil(b"OUTPUT: ")
    return int(p.recvline())

while True:
    p = remote("codefest-ctf.iitbhu.tech", 61755)
    p.recvuntil(b"GIVEN: N = ")
    N = int(p.recvline())

    # try to find a small N to reduce wait time
    if N <= 300:
        break

    p.close()

print(f"N  = {N}\n")

s01 = query(0, 1)
s02 = query(0, 2)
s12 = query(1, 2)

# calculate the first three elements from the previous queries
a0 = (s01 + s02 - s12) // 2
a1 = s01 - a0
a2 = s02 - a0

numbers = [a0, a1, a2]

print(f"Reconstructed:\na0 = {a0}\na1 = {a1}\na2 = {a2}\n")

for i in tqdm(range(3, N), leave=False):
    # since we know the first index we just use it with the pair
    # and substract afterwards
    ai = query(0, i) - a0
    numbers.append(ai)

# send back the full list
data = " ".join(str(num) for num in numbers)
p.sendlineafter(b"INPUT: ", f"! {data}".encode())
print(p.recvall().decode())
```

Runing this, gives us the flag.

```bash
$ python guess.py SILENT=true
N  = 150

Reconstructed:
a0 = 867099
a1 = 363722
a2 = 427976

 50%|████████████████████████████████████████▋                                         | 73/147 [00:20<00:20,  3.59it/s]
```

```bash
Congratulations! Here is the flag - CodefestCTF{pr377y_e45y_pr0bl3m_oA5SKrVX}
```

Flag `CodefestCTF{pr377y_e45y_pr0bl3m_oA5SKrVX}`