# Tenable Capture the Flag 2023

## The Javascript One

Tags: _rev_

## Solution

Some obfuscated [`javascript code`](code.js) was given:
```javascript
var _0x4b0817=_0x3cdb;(function(_0x25abc1,_0x1b11ab){var _0x21dd4f=_0x3cdb,_0x15cf55=_0x25abc1();while(!![]){try{var _0x187219=par...
```

In this form the code was not readable, so putting it in a deobfuscator and the result was actually, with a bit of manual tweaking, [`quite nice`](code_deobf.js).

One function was especially interesting. This seems to be the encryption method, `btoa` converts to base64 so we are looking for a base64 encoded value. Indeed one such value can be found `Zm1jZH92N2tkcFVhbXs6fHNjI2NgaA==`. 

```javascript
function encryptFlag(opacityProp) {
  var persons = ''
  var x = 0
  for (; x < opacityProp.length; x++) {
    var url = opacityProp.charCodeAt(x)
    var id = url ^ x
    persons = persons + String.split(id)
  }
  return btoa(persons)
}
```

Having this in place the decryption is easily done:

```python
import base64

foo = base64.b64decode("Zm1jZH92N2tkcFVhbXs6fHNjI2NgaA==")

for i in range(0, len(foo)):
    print(chr(foo[i]^i),end="")
```

Flag `flag{s1lly_jav4scr1pt}`