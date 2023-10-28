# Hack The Boo 2023

## HauntMart

> An eerie expedition into the world of online retail, where the most sinister and spine-tingling inventory reigns supreme. Can you take it down?
>
>  Author: N/A
>
> [`web_hauntmart.zip`](web_hauntmart.zip)

Tags: _web_

## Solution
We are delivered with the source code of a web application. If open the page we can login or create a account. Since no credentials are given we create a account and login. After logging in we can see a shoplike web-page and a option to sell something.

Checking out the source code we find the target in `index.html`. Our goal is to get access to an admin account or elevate our own account to have admin role.

```html
{% if user['role'] == 'admin' %}
        {{flag}}
{% endif %}
```

In `database.py` is an interesting function, that allows to give a random user `admin role`. Now we need to find a spot where this function is called.

```python
def makeUserAdmin(username):
    check_user = query('SELECT username FROM users WHERE username = %s', (username,), one=True)

    if check_user:
        query('UPDATE users SET role="admin" WHERE username=%s', (username,))
        mysql.connection.commit()
        return True

    return False
```

We there is a route that calls `makeUserAdmin`. The only thing is, it can only be called from `localhost`. So our goal is to let the server call this route somehow. 

```python
@api.route('/addAdmin', methods=['GET'])
@isFromLocalhost
def addAdmin():
    username = request.args.get('username')

    if not username:
        return response('Invalid username'), 400

    result = makeUserAdmin(username)

    if result:
        return response('User updated!')
    return response('Invalid username'), 400
```

There are typically various approaches. To find a possible attack vector we need to check out how we can interact with the web-page. One thing we can do is sell products.

```python
@api.route('/product', methods=['POST'])
@isAuthenticated
def sellProduct(user):
    if not request.is_json:
        return response('Invalid JSON!'), 400

    data = request.get_json()
    name = data.get('name', '')
    price = data.get('price', '')
    description = data.get('description', '')
    manualUrl = data.get('manual', '')

    if not name or not price or not description or not manualUrl:
        return response('All fields are required!'), 401

    manualPath = downloadManual(manualUrl)
    if (manualPath):
        addProduct(name, description, price)
        return response('Product submitted! Our mods will review your request')
    return response('Invalid Manual URL!'), 400
```

There is no filtering or sanitizing of our input. Also we can specify a url to a manual for the product. The url is used to `download` the manual. Lets see what is going on inside.

```python
def downloadManual(url):
    safeUrl = isSafeUrl(url)
    if safeUrl:
        try:
            local_filename = url.split("/")[-1]
            r = requests.get(url)

            with open(f"/opt/manualFiles/{local_filename}", "wb") as f:
                for chunk in r.iter_content(chunk_size=1024):
                    if chunk:
                        f.write(chunk)
            return True
        except:
            return False

    return False
```

The url is split and a file is read at the path `/opt/manualFiles/{filename}`. This looks like a *lfi* issue, but it's not. The far more interesting bit is, that the full url is used to do a `get request`. Thats exactly what we need. The only thing we need to bypass is the `isSafeUrl` check.

```python
blocked_host = ["127.0.0.1", "localhost", "0.0.0.0"]

def isSafeUrl(url):
    for hosts in blocked_host:
        if hosts in url:
            return False

    return True
```

A url is save if it is not one of the `blocked hosts`. The only problem is, the blocked hosts are not enough, we can, for instance, just use `127.0.0.2` to do a local call. So, the plan is to create a user (with user name `test` for instance), login with that user and then sell a product. The product information are not important, the only important thing is the manual url which we set to `http://127.0.0.2:1337/api/addAdmin?username=test`.

And after refreshing the index page (and logging in again), we are presented with the flag.

Flag `HTB{A11_55RF_5C4rY_p4tch_3m_411!}`