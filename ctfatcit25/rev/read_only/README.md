# CTF@CIT 2025

## Read Only

> Here we go!
>
>  Author: ronnie
>
> [`readonly`](readonly)

Tags: _rev_

## Solution
This one is a typical entry level reversing challenge where the flag is somewhere stored in the image as plane string. We can just call `strings` on those files and grep for the flag prefix.

```bash
$ strings readonly | grep CIT
CIT{87z1BjG1968G}
```

Flag `CIT{87z1BjG1968G}`