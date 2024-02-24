# BraekerCTF 2024

## The mainframe speaks

> "Oh ancient robeth! All throughout the land they talk of you becoming obsolete. How is you? Are you in need of assistance?"
>
>
> "Obsolete? These bots must be abending. I'm working just fine you see. Young bots are the ones having all sorts of troubles, not us. We're maintained and properly managed. However, I do have this old code lying around, and I lost the documentation. Can you find it for me?"
>
>  Author: n/a
>
> [`chall.rexx`](chall.rexx)

Tags: _rev_

## Solution
For this challenge we get a somewhat obfuscated [`REXX`](https://en.wikipedia.org/wiki/Rexx) script. There is a nice [`online compiler`](https://www.tutorialspoint.com/execute_rexx_online.php) that can help to make sense of this script. There only is a small disclaimer: The used [`Regina Rexx Interpreter`](https://regina-rexx.sourceforge.io/) character encoding does not match what was used on [`IBM Mainframe`](https://www.ibm.com/docs/en/zos-basic-skills?topic=mainframe-ebcdic-character-set), so all encoding functionality (`X2C`, `D2C`, ...) does return different values when the interpreter is used.

```bash
/* REXX */

PARSE ARG _'{'!'}'_
PARSE VAR ! ?_'_'_?_'_'_?
_.='EM0';_._=_.WOA!'CEWL'

A=\VERIFY(?_,_._)&\ABBREV(D2C(15123923),?_,3)
B=POS(0,?_)=5&LENGTH(?_)=7

E.1='9DA8ADAE9FB9BB0137108E8D11363D1DB0'
E.2='8BBE98BD36021C32888E00350126231C9E2126301C2500000A251188B11D2BB31D'
E.3='25BBAC3301243316302334002435163524330024321636233200153513351733072437B0B5B0813F'
E.4='8B8EAD24021788240C3024260D882537348E12300704260A8E9DAF8E8BAE22A80989988D222100BD17981D1D'
E.5='8B8EBEBD2631003F16122BBDA91C9B27370112371CABA8A888019F378D3421A80289AE8BBE98B89B25351D'
E.6='2F0393B89D841303000A10313C888B8EA8A89D9FA8BBBBBEACB0370D23109361717C850E537783774266A6665B46B05256C1C7'

IF A&B THEN
  DO i = 1 TO 6
    BC = X2C(E.i)
    NC = ABS(LENGTH(BC)%LENGTH(?_))
    BCD = BITXOR(BC,COPIES(?_,NC),' ')
    interpret BCD
  END
ELSE say oof no flag
```

Armed with this knowledge we can start. The first two lines do some input parsing: `PARSE ARG` will take input arguments and match them for a given pattern. The input starts and ends with a placeholder (`_`) that is ignored. Then curly opening and closing braces are assumed and the content between the braces is written to a variable called `!`. This for sure looks like the flag format `brck{<content here>}`. The second step is to split the extracted content into three parts, each seperated by a underscore `_`, the first part is written to a variable named `?_`, the middle part is written to a variable named `_?_` and the last part is written to a variable named `_?`.

The fact that `REXX` supports variables named like this makes the code less readable and obfuscated. But as we know about this, we really don't care too much.

```bash
_.='EM0';_._=_.WOA!'CEWL'

A=\VERIFY(?_,_._)&\ABBREV(D2C(15123923),?_,3)
B=POS(0,?_)=5&LENGTH(?_)=7
```

Moving on, there are two more variables initialized, one is called `_.` and gets the value `EM0`, the second one is called `_._` and gehts the value `EM0CEWL` (taking _. into account). Then `VERIFY` is called. According to [`VERIFY`](https://www.ibm.com/docs/en/zos/2.1.0?topic=functions-verify).

> returns a number that, by default, indicates whether string is composed only of characters from reference; returns 0 if all characters in string are in reference, or returns the position of the first character in string not in reference.

This line checks for the first character of the first flag part that is **not** contained in `EM0CEWL`. If no such character is found `VERIFY` returns `0` and is negated by the `\` operator just before the functions call, effectively inverting the value to `1`. We can assume now that the first part is made out of the characters `EM0CEWL`. 

The second condition uses [`ABBREV`](https://www.ibm.com/docs/en/zos/2.1.0?topic=functions-abbrev-abbreviation). The documentation states

> returns 1 if info is equal to the leading characters of information and the length of info is not less than length. Returns 0 if either of these conditions is not met.

The first parameter is `D2C(15123923)`. The function `D2C` converts a decimal to a character representation, here the online compiler fails and we have to do it manually (using [`CyberChef`](https://gchq.github.io/CyberChef/), or [`python`](https://pypi.org/project/ebcdic/)). If we do it correct we see that the converted number results in the string `WEL`.

Right, back to `ABBREV`, we can simplify this to `ABBREV("WEL",?_,3)` so this would return 1 if `WEL` starts with the first flag part. Meaning the first flag part can only be `W`, `WE` or `WEL`. If we peek further down, we see another condition `LENGTH(?_)=7`, the first flag part is 7 characters long. How can this be? But the return value of `ABBREV` is negated, so in total `A` is 1. Thinking about this, this looks like a bug and the line should read actually:

```bash
A=\VERIFY(?_,_._)&ABBREV(?_,D2C(15123923))
```

This would test successfully for the correct alphabet and check **if the first flag parts starts with `WEL`**. If both conditions are given, `A` is set to 1. The next line reads:

```bash
B=POS(0,?_)=5&LENGTH(?_)=7
```

This is fairly easy, the 5th character of our first flag part needs to be `0` and the first flag part is 7 characters long in total. We get `WEL?0??`, in our alphabet we have `E` and `C` left to distribute, so we can guess the first flag part is `WELC0ME`.

A bit further down, we can see that `A` and `B` need to be both set to `1` in order to let the script proceed. Otherwise the program exits with the line `say oof no flag`.

```bash
IF A&B THEN
  /*...*/
ELSE say oof no flag
```

Right, we have two parts left. We have this loop that goes over the array `E` and does some encryption. First the hex-string is converted to a character string. Then we check how often the first flag part fits into the line we want to decode (mind that `%` is the division in `REXX`). Finally we do a bitwise xor (`BITXOR` on the encoded line and repeated copies of the first flag part). This should give us more `REXX` code that is invoked with an `interpret` call.

```bash
E.1='9DA8ADAE9FB9BB0137108E8D11363D1DB0'
E.2='8BBE98BD36021C32888E00350126231C9E2126301C2500000A251188B11D2BB31D'
E.3='25BBAC3301243316302334002435163524330024321636233200153513351733072437B0B5B0813F'
E.4='8B8EAD24021788240C3024260D882537348E12300704260A8E9DAF8E8BAE22A80989988D222100BD17981D1D'
E.5='8B8EBEBD2631003F16122BBDA91C9B27370112371CABA8A888019F378D3421A80289AE8BBE98B89B25351D'
E.6='2F0393B89D841303000A10313C888B8EA8A89D9FA8BBBBBEACB0370D23109361717C850E537783774266A6665B46B05256C1C7'

DO i = 1 TO 6
  BC = X2C(E.i)
  NC = ABS(LENGTH(BC)%LENGTH(?_))
  BCD = BITXOR(BC,COPIES(?_,NC),' ')
  interpret BCD
END
```

Lets write a python script that does this for us:

```python
import ebcdic
from pwn import xor

e = [
        '9DA8ADAE9FB9BB0137108E8D11363D1DB0',
        '8BBE98BD36021C32888E00350126231C9E2126301C2500000A251188B11D2BB31D',
        '25BBAC3301243316302334002435163524330024321636233200153513351733072437B0B5B0813F',
        '8B8EAD24021788240C3024260D882537348E12300704260A8E9DAF8E8BAE22A80989988D222100BD17981D1D',
        '8B8EBEBD2631003F16122BBDA91C9B27370112371CABA8A888019F378D3421A80289AE8BBE98B89B25351D',
        '2F0393B89D841303000A10313C888B8EA8A89D9FA8BBBBBEACB0370D23109361717C850E537783774266A6665B46B05256C1C7'
    ]

key = "WELC0ME".encode("cp1047")

for line in e:
    tmp = bytes.fromhex(line)
    print(xor(tmp, key).decode("cp1047"))
```

```bash
$ python decode.py
#_=_?_=X2C('E3ûQÄ
_#.=FORM()CENTER(SOURCELINE(ïQ8øÒ
C="01060507000007000703010A050D0702îøÄâõ
_.=X2C(BITXOR(C2X(SUBSTR(_#._,1,9)),X2C(C)ÛQ
_._=OVERLAY('R'SUBSTR(_#.1.2,12,2),_#.#,10Û
IF #_&OVERLAY(_.#,_._)=_? THEN say You got the fl\x1b
```

Something did work, but not completely. The end of the lines are all messed up.. Very sad... Lets go back to reading the [`documentation`](https://www.ibm.com/docs/en/zos/2.1.0?topic=functions-bitxor-bit-by-bit-exclusive).

> returns a string composed of the two input strings logically eXclusive-ORed together, bit by bit. (The encoding of the strings are used in the logical operation.) The length of the result is the length of the longer of the two strings. If no pad character is provided, the XOR operation stops when the shorter of the two strings is exhausted, and the unprocessed portion of the longer string is appended to the partial result. If pad is provided, it extends the shorter of the two strings on the right before carrying out the logical operation. The default for string2 is the zero length (null) string.

Ah, we have a value for `pad`, the code gives a space for the remaining characters at line end. So lets fix this.

```python
import ebcdic
from pwn import xor

e = [
        '9DA8ADAE9FB9BB0137108E8D11363D1DB0',
        '8BBE98BD36021C32888E00350126231C9E2126301C2500000A251188B11D2BB31D',
        '25BBAC3301243316302334002435163524330024321636233200153513351733072437B0B5B0813F',
        '8B8EAD24021788240C3024260D882537348E12300704260A8E9DAF8E8BAE22A80989988D222100BD17981D1D',
        '8B8EBEBD2631003F16122BBDA91C9B27370112371CABA8A888019F378D3421A80289AE8BBE98B89B25351D',
        '2F0393B89D841303000A10313C888B8EA8A89D9FA8BBBBBEACB0370D23109361717C850E537783774266A6665B46B05256C1C7'
    ]

key = "WELC0ME".encode("cp1047")
space = " ".encode("cp1047")

for line in e:
    tmp = bytes.fromhex(line)
    # repeat full key as often as possible
    key_ = key * (len(tmp) // len(key))

    # pad the remaining difference with spaces
    key_ = key_ + space * (len(tmp) - len(key))

    # decode the full line and print it
    decoded_line = bytes([c ^ k for c, k in zip(tmp, key_)])

    print(decoded_line.decode("cp1047"))
```

```bash
$ python decode.py
#_=_?_=X2C('E3')0
_#.=FORM()CENTER(SOURCELINE(1),3)
C="01060507000007000703010A050D0702050A"
_.=X2C(BITXOR(C2X(SUBSTR(_#._,1,9)),X2C(C)))
_._=OVERLAY('R'SUBSTR(_#.1.2,12,2),_#.#,10)
IF #_&OVERLAY(_.#,_._)=_? THEN say You got the flag
```

Now this worked. Here we have even more code to reverse. Lets start one by one. The first line checks if the second flag part is equal to `T0` (0xe3 decodes as `T` and the 0 is concatinated) and the result is stored to variable `#_`. This gives us the second part of the flag: `T0`.

```bash
#_=_?_=X2C('E3')0
```

The next line calls [`FORM`](https://www.tutorialspoint.com/rexx/rexx_form.htm) that `This method returns the current setting of ‘NUMERIC FORM’ which is used to do mathematic calculations on the system` and gives `SCIENTIFIC` as first part of the string. The next part comes from `CENTER(SOURCELINE(1),3)`. [`SOURCELINE`](https://www.ibm.com/docs/en/zos/2.4.0?topic=functions-sourceline) gives is the script source at the given line, that is the initial comment `/* REXX */`. 

[`CENTER`](https://www.ibm.com/docs/en/zos/2.1.0?topic=functions-centercentre) does the following:

> returns a string of length length with string centered in it, with pad characters added as necessary to make up length.

The resulting string is `REX` and `-#.` gets the value `SCIENTIFICREX` after concatenation. The next two lines are again decoding some xor encrypted value stored in `C`. We can go back to our python script to work around the `ebcdic` encoding issue.

```python
import ebcdic
from pwn import xor

key = "SCIENTIFI".encode("cp1047").hex().encode()
C   = "01060507000007000703010A050D0702050A"
msg = bytes.fromhex(xor(bytes.fromhex(C), key).decode()).decode("cp1047")
print(msg)
```

If we run this script, we can see the decoded value is `M4INFR4M3`. The next line uses [`OVERLAY`](https://www.ibm.com/docs/en/zos/2.1.0?topic=functions-overlay). `R` is concatenated with the last two characters of `SCIENTIFICREX`, giving us `REX`. The overlay overrides the characters 10, 11 and 12 of `SCIENTIFICREX` with `REX` giving us a final result of `SCIENTIFIREXX` for variable `_._`.

The last line does the final verification. First it checks if the middle part of the flag was tested correct before. Then `OVERLAY` is used once more, this time `M4INFR4M3`is overlayed onto `SCIENTIFIREXX` leaving us with `M4INFR4M3REXX`. This value is tested against the last part of the flag. Building all the parts together gives us finally the flag.

Flag `brck{WELC0ME_T0_M4INFR4M3REXX}`