# Cyber Apocalypse 2024

## LootStash

> A giant stash of powerful weapons and gear have been dropped into the arena - but there's one item you have in mind. Can you filter through the stack to get to the one thing you really need?
> 
> Author: clubby789
> 
> [`rev_lootstash.zip`](rev_lootstash.zip)

Tags: _rev_

## Solution
The given program prints some messages out of a big array of strings. In this case, its always worth a shot to use `strings` on the binary.

```bash
$ strings stash | grep HTB
HTB{n33dl3_1n_a_l00t_stack}
```

Flag `HTB{n33dl3_1n_a_l00t_stack}`