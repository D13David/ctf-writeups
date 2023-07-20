# AmateursCTF 2023

## Insanity check

> insanity introduce inspire something incredible impulse ivory intelligence incident implication hidden illustrate isolation illusion indirect instinct inappropriate interrupt infection in item inspector institution infinite insert the insist import ignite incentive influence instruction invasion install infrastructure innovation ignore investment impact improve increase rules identification initial immune inhabitant indulge illness information iron injection interest intention inquiry inflate impound
>
>  Author: hellopir2
>
> [`main.py`](main.py)

Tags: _misc_

## Solution
This challenge was a bit confusing. The description seems to be random words starting with an `i`. But in fact in the middle there are some words which are not starting with an `i`. Connecting them together gives `something hidden [in] the rules`. This obviously points to the CTF rules channel in discord. But there is nothing hidden at the first glance. But when opening the channel with a mobile device some weird numbers pop up.

```
# __RULES__
107122414347637. Use common sense.
125839376402043. Play nice. No interfering with other competitors or infrastructure, and keep brute forcing to a minimum.
122524418662265. Do not attack other infrastructure or organizers. Any service running on the domain `amt.rs` is in scope. Keep brute forcing to a minimum.
122549902405493. Admins reserve the right to modify the rules at any point (mostly to clarify things).
121377376789885. PLEASE DO NOT COMMUNICATE WITH ADMINS THROUGH DMS, **USE THE MODMAIL/TICKET BOT INSTEAD**
Good job for reading the rules. Here's your sanity check flag: `amateursCTF{be_honest._did_you_actually_read_the_rules?}`
## vv anything in the red box is disallowed (yes that means flag hoarding is banned)
```

Converting the numbers to hex and then to ascii leads the flag
```bash
$ python -c "print(bytes.fromhex(hex(107122414347637)[2:]+hex(125839376402043)[2:]+hex(122524418662265)[2:]+hex(122549
902405493)[2:]+hex(121377376789885)[2:]))"
b'amateursCTF{oops_you_found_me}'
```

Flag `amateursCTF{oops_you_found_me}`