# CSAW'23

## Baby's Third

> 
> Babies can't count, but they can do binaries?
> 
> (Where did Baby Two go?
>
>  Author: ElykDeer
>
> [`readme.txt`](readme.txt), [`babysthird`](babysthird)

Tags: _intro_

## Solution
We get a binary and a readme with some introductions. The readme gives a strong hint `not to read the code`, so we don't analyze it but just call `strings` on the binary.

```bash
$ strings babysthird | grep csaw
csawctf{st1ng_th30ry_a1nt_so_h4rd}
```

Flag `csawctf{st1ng_th30ry_a1nt_so_h4rd}`