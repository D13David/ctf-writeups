# Hack The Boo 2022

## Ouija

> You've made contact with a spirit from beyond the grave! Unfortunately, they speak in an ancient tongue of flags, so you can't understand a word. You've enlisted a medium who can translate it, but they like to take their time...
Submit flag & press enter
>
>  Author: N/A
>
> [`rev_ouija.zip`](rev_ouija.zip)

Tags: _rev_

## Solution

Looking at the program in Ghidra reveals a lot of noise output with artificially timeout sprinkled with some interessting parts where the flag is 'decoded'. Extracting this part into a small python script helps the decode the flag without the artificial delay.

```python
key = 0xd
key = key + 5

flag = "ZLT{Svvafy_kdwwhk_lg_qgmj_ugvw_escwk_al_wskq_lg_ghlaearw_dslwj!}"

flag1 = ""

for c in flag:
    if c.islower():
         x = ord(c)
         if x - key < 0x61:
             x = x + 26
         x = x - key
         flag1 += chr(x)
    elif c.isupper():
         x = ord(c)
         if x - key < 0x41:
             x = x + 26
         x = x - key
         flag1 += chr(x)
    else:
        flag1 += c

print(flag1)
```

Revealing the flag ```HTB{Adding_sleeps_to_your_code_makes_it_easy_to_optimize_later!}```