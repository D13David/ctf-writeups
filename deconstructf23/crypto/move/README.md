# DeconstruCT.F 2023

## MOVE

> There is an urgent need for a touch typist in our 13 year old organization, can you find the flag from the encrypted data?
>
>  Author: N/A
>
> [`KEY.txt`](KEY.txt)

Tags: _crypto_

## Solution
One file is given with the content `U_E}M28NWV5?28S~`. The description gives two hints `13 year old organization` and `touch typist`. The first one could be a clue pointing to `rot13` the second one could be pointing to `Keyboard Shift Cipher`.

After some trial and error the sequence is first apply `rot13` then bruteforce some variants of keyboard shift cipher [`here`](https://www.dcode.fr/keyboard-shift-cipher).

```bash
$ echo "U_E}M28NWV5?28S~" | rot13
H_R}Z28AJI5?28F~
```

Keyboard Shift Decoder with `DVORAK (US)` layout, `Right` shift and `1 key/step` for shift results in the key.

```
dvorak →	DSC{V17_QU4L17Y
```

Flag `DSC{V17_QU4L17Y}`