# DownUnderCTF 2023

## pyny

> I've never seen a Python program like this before.
>
>  Author: hashkitten
>
> [`pyny.py`](pyny.py)

Tags: _rev_

## Solution
We get this very small python code

```python
#coding: punycode
def _(): pass
('Correct!' if ('Enter the flag: ') == 'DUCTF{%s}' % _.____ else 'Wrong!')-gdd7dd23l3by980a4baunja1d4ukc3a3e39172b4sagce87ciajq2bi5atq4b9b3a3cy0gqa9019gtar0ck
```

This looks strange, but can be run.

```bash
$ python pyny.py
Enter the flag: asdasd
Wrong!
```

There's no trace of a flag... Wikipedia [`tells us`](https://en.wikipedia.org/wiki/Punycode).

> Punycode is a representation of Unicode with the limited ASCII character subset used for Internet hostnames. Using Punycode, host names containing Unicode characters are transcoded to a subset of ASCII consisting of letters, digits, and hyphens, which is called the letter–digit–hyphen (LDH) subset. For example, München (German name for Munich) is encoded as Mnchen-3ya.

By changing some random bytes with a hex editor python throws errors at us, by change it leaks the flag.

```python
('Cor᥂᥃reɝct£!' if ('En᥂±terɡ thᰉe flag᥄: 'ᰉ) == ᤽᥃'ᤷDU᤽ɠCɚTF{%s}'᥂ % _.___᥂_ e᥌ɝlse °'Wrongᰈ!£')᥌
                                                             ^^^^^^^^^^^^^^^^^^^^^^^^
NameError: name 'python_warmup' is not defined. Did you mean: 'pythonxwarmup'?
```

On the other hand, we can use python to decode the code for us:
```python
code = open("pyny.py", "rb").read()
code = code.replace(b"#coding: punycode", b"").decode("punycode")
print(code)
```

```python
def ᵖʸᵗʰºⁿ_ʷªʳᵐᵘᵖ(): pass
ᵖʳᵢⁿᵗ('Correct!' if ᵢⁿᵖᵘᵗ('Enter the flag: ') == 'DUCTF{%s}' % ᵖʸᵗʰºⁿ_ʷªʳᵐᵘᵖ.__ⁿªᵐᵉ__ else 'Wrong!')
```

Flag `DUCTF{python_warmup}`