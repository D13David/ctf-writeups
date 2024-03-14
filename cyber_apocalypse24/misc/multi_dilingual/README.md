# Cyber Apocalypse 2024

## MultiDigilingual

> It's a known secret that each faction speaks different languages, however few can speak all of them. KORP has long wanted to send a spy in the factions to keep an eye on them. Through their extensive network, they have found different talented factionless to test. The first to show their multidigilingual skills will get a place in them, and be their secret agent amongst the factions. Can you show them your worth?
> 
> Author: n/a
> 

Tags: _misc_

## Solution
We get a container we can connect to. Doing so, we are provided with the following instruction.

```bash
$ nc 94.237.54.161 51724
****************************************
*   How many languages can you talk?   *
* Pass a base64-encoded program that's *
*   all of the below that just reads   *
*      the file `flag.txt` to win      *
*          and pass the test.          *
*                                      *
*              Languages:              *
*               * Python3              *
*               * Perl                 *
*               * Ruby                 *
*               * PHP8                 *
*               * C                    *
*               * C++                  *
*                                      *
*   Succeed in this and you will be    *
*               rewarded!              *
****************************************

Enter the program of many languages:
```

So, we need to submit a program, that prints the content of the flag file to screen. And the program should run in many different languages.

A bit of google research led to [`this`](https://gist.github.com/SaswatPadhi/2872457) code snipped. Adapting it to read the `flag.txt` contents gives us the flag.

```c
#/*<?php eval('$x=file_get_contents("flag.txt");print("\r".$x);'); __halt_compiler();?> */

#include <stdio.h>
#include <stdlib.h> /*

(("b" + "0" == 0) and not eval('system("cat flag.txt");')) or (0 and eval("system('cat flag.txt')") or eval("print(open('flag.txt').read())"))

__DATA__ = 1
"""""
__END__

===== . ===== */

char msg[] = {'c','a','t',' ','f','l','a','g','.','t','x','t'};

int main() { int i; system(msg); return 0;} /*

"""
#*/
```

```bash
Enter the program of many languages: Iy8qPD9waHAgZXZhbCgnJHg9ZmlsZV9nZXRfY29udGVudHMoImZsYWcudHh0Iik7cHJpbnQoIlxyIi4keCk7Jyk7IF9faGFsdF9jb21waWxlcigpOz8+ICovCgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5oPiAvKgoKKCgiYiIgKyAiMCIgPT0gMCkgYW5kIG5vdCBldmFsKCdzeXN0ZW0oImNhdCBmbGFnLnR4dCIpOycpKSBvciAoMCBhbmQgZXZhbCgic3lzdGVtKCdjYXQgZmxhZy50eHQnKSIpIG9yIGV2YWwoInByaW50KG9wZW4oJ2ZsYWcudHh0JykucmVhZCgpKSIpKQoKX19EQVRBX18gPSAxCiIiIiIiCl9fRU5EX18KCj09PT09IC4gPT09PT0gKi8KCmNoYXIgbXNnW10gPSB7J2MnLCdhJywndCcsJyAnLCdmJywnbCcsJ2EnLCdnJywnLicsJ3QnLCd4JywndCd9OwoKaW50IG1haW4oKSB7IGludCBpOyBzeXN0ZW0obXNnKTsgcmV0dXJuIDA7fSAvKgoKIiIiCiMqLwo=

[*] Executing Python3 using command python
    [+] Completed. Checking output
    [+] Passed the check


[*] Executing Perl using command perl
    [+] Completed. Checking output
    [+] Passed the check


[*] Executing Ruby using command ruby
    [+] Completed. Checking output
    [+] Passed the check


[*] Executing PHP8 using command php
    [+] Completed. Checking output
    [+] Passed the check


[*] Executing C using command gcc
    [+] Completed. Checking output
    [+] Passed the check


[*] Executing C++ using command g++
    [+] Completed. Checking output
    [+] Passed the check

You seem to know your way around code. We will be looking at you with great interest... HTB{7he_ComMOn_5yM8OL5_Of_l4n9U49E5_C4n_LE4d_7O_m4ny_PolY9lO7_WoNdeR5}
```

Flag `HTB{7he_ComMOn_5yM8OL5_Of_l4n9U49E5_C4n_LE4d_7O_m4ny_PolY9lO7_WoNdeR5}`