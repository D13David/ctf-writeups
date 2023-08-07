# DeconstruCT.F 2023

## where-are-the-cookies

> Tom is feeling especially snacky during the CTF, can you find where the cookies are?
> 
> Note: This challenge works best on Chrome
>
>  Author: N/A
>

Tags: _web_

## Solution
This challenge very obviously is a kind of *do something with a cookie* style challenge. But there is no cookie used when entering the page. Checking out `robots.txt` it gives a hidden route `/cookiesaretotallynothere`.

Going to this route we have our cookie `caniseethecookie=bm8==`. The value is base64 encoded and decoding it tells us the value is `no`. Setting the cookie to the base64 encoded pendant to `yes` (`eWVz`) and refreshing the page gives the flag.

Flag `dsc{1_f0unD_Th3_c0oK135}`