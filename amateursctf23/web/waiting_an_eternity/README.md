# AmateursCTF 2023

## waiting-an-eternity

> My friend sent me this website and said that if I wait long enough, I could get and flag! Not that I need a flag or anything, but I've been waiting a couple days and it's still asking me to wait. I'm getting a little impatient, could you help me get the flag?Inspired by recent "traumatic" events.
>
>  Author: voxal
>

Tags: _web_

## Solution
When opening the link, just a simple text is given `just wait an eternity`. Since we don't have any time at all we inspect the `HTTP headers`. 

```
< HTTP/2 200
< content-type: text/html; charset=utf-8
< date: Tue, 18 Jul 2023 09:37:05 GMT
< refresh: 1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000; url=/secret-site?secretcode=5770011ff65738feaf0c1d009caffb035651bb8a7e16799a433a301c0756003a
< server: gunicorn
< content-length: 21
```

This looks promosing, there is a refresh scheduled to happen in `3.17097919837645829e+76 millenia`. So, instead of waiting we just call the side on our own and are greeted with another message `welcome. please wait another eternity.`. After refreshing the page, the message changes `you have not waited an eternity. you have only waited 60.61320996284485 seconds`. So the time is tracked somewhere. Inspecting a bit further bringe up a suspicious cookie `time = 1689673199.4156046`. We can change this to any big number, but the application is sure, we waited not long enough `you have not waited an eternity. you have only waited -1e+87 seconds`. What we need is to change the cookie to an infinite value and sure enough setting `time = -Infinity` gives the flag.

## Solution

Flag `amateursCTF{im_g0iNg_2_s13Ep_foR_a_looo0ooO0oOooooOng_t1M3}`