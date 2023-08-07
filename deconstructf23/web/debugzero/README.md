# DeconstruCT.F 2023

## debugzero

> Someone on the dev team fat fingered their keyboard, and deployed the wrong app to production. Try and find what went wrong. The flag is in a file called "flag.txt"
>
>  Author: N/A
>

Tags: _web_

## Solution
The web application hosted only outputs a simple text, not too interesting. Browsing the code there is a reference to a stylesheet `/static/styles.css` that contains no `css` but a comment with a *maybe usefull* number `934123`.

Another hint is given telling us `Are there any python servers that can store water ; )`, this could be a pointer to `Flask` and the debug variant offers the `Werkzeug Debugger Console` at the route `/console`.

Heading over to the console it's secured with a `pin`. There are a lot of [`informations`](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/werkzeug) and [`writeups`](https://github.com/wdahlenburg/werkzeug-debug-console-bypass) [`here`](https://github.com/grav3m1nd-byte/werkzeug-pin) or [`here`](https://hacktricks.boitatech.com.br/pentesting/pentesting-web/werkzeug) that describe how to bypass the bin. A `lfi` vulnerability is needed to leak some information of the host but... We saw this usefull number before, so trying this as the pin and voilà - console unlocked.

This is a `python` console and since we know where the flag is located entering...

```python
open("flag.txt").read()
```

...gives the flag.

Flag `dsc{p1zz4_15_4w350m3}`