# WaniCTF 2024

## lambda

> Let's dance with lambda!
>
>  Author: hi120ki
>
> [`rev-lambda.zip`](rev-lambda.zip)

Tags: _rev_

## Solution
This challenge comes with a small python script containing some unreadable `lambda` expression.

```py
import sys

sys.setrecursionlimit(10000000)

(lambda _0: _0(input))(lambda _1: (lambda _2: _2('Enter the flag: '))(lambda _3: (lambda _4: _4(_1(_3)))(lambda _5: (lambda _6: _6(''.join))(lambda _7: (lambda _8: _8(lambda _9: _7((chr(ord(c) + 12) for c in _9))))(lambda _10: (lambda _11: _11(''.join))(lambda _12: (lambda _13: _13((chr(ord(c) - 3) for c in _10(_5))))(lambda _14: (lambda _15: _15(_12(_14)))(lambda _16: (lambda _17: _17(''.join))(lambda _18: (lambda _19: _19(lambda _20: _18((chr(123 ^ ord(c)) for c in _20))))(lambda _21: (lambda _22: _22(''.join))(lambda _23: (lambda _24: _24((_21(c) for c in _16)))(lambda _25: (lambda _26: _26(_23(_25)))(lambda _27: (lambda _28: _28('16_10_13_x_6t_4_1o_9_1j_7_9_1j_1o_3_6_c_1o_6r'))(lambda _29: (lambda _30: _30(''.join))(lambda _31: (lambda _32: _32((chr(int(c,36) + 10) for c in _29.split('_'))))(lambda _33: (lambda _34: _34(_31(_33)))(lambda _35: (lambda _36: _36(lambda _37: lambda _38: _37 == _38))(lambda _39: (lambda _40: _40(print))(lambda _41: (lambda _42: _42(_39))(lambda _43: (lambda _44: _44(_27))(lambda _45: (lambda _46: _46(_43(_45)))(lambda _47: (lambda _48: _48(_35))(lambda _49: (lambda _50: _50(_47(_49)))(lambda _51: (lambda _52: _52('Correct FLAG!'))(lambda _53: (lambda _54: _54('Incorrect'))(lambda _55: (lambda _56: _56(_41(_53 if _51 else _55)))(lambda _57: lambda _58: _58)))))))))))))))))))))))))))
```

Lets maybe first see how lambdas work in python. The following defines a function object with one parameter, which returns the square of the parameter.

```py
lambda x: x*x
```

We can try this by calling it right away:

```py
>>> (lambda x: x*x)(5)
25
```

So expressions like this `lambda _0: _0(input)` expecting the lambda to be called with another function object and call to the object themselfe. Lets check the first three lines.

```py
(lambda _0: _0(input))(
    lambda _1: (lambda _2: _2("Enter the flag: "))(
        lambda _3: (lambda _4: _4(_1(_3)))(
            # ...
        )
    )
)
```

Lambda #0 is passing `input` for parameter for lambda #1, so we can substitute `_1` with `input`. Lambda #1 defines lambda #2 and immediately calls it with lambda #3 as parameter, so lambda #2 calls lambda #3 with `Enter the flag:` as parameter. We can substitute the parameters and just pass in `None` as proof of concept to see if things still work as intended.

```py
(lambda _0: _0(None))(
    lambda _1: (lambda _2: _2(None))(
        lambda _3: (lambda _4: _4(input("Enter the flag: ")))(
            # ...
        )
    )
)
```

Now we can remove the lambdas which just call, since there is no functionality remaining anyways.

```py
# removed lambda #0 - #5 ...
(lambda _6: _6("".join))(
    lambda _7: (
        lambda _8: _8(lambda _9: _7((chr(ord(c) + 12) for c in _9)))
    )(
        lambda _10: (lambda _11: _11("".join))(
            lambda _12: (
                lambda _13: _13((chr(ord(c) - 3) for c in _10(input("Enter the flag: "))))
            )(
                # ...
            )
        )
    )
)
```

After proceeding with the same process things condence to something like this (lambda #0 - #23 where removed already). 

```py
(lambda _24: _24(((lambda _20: "".join((chr(123 ^ ord(c)) for c in _20)))(c) for c in "".join((chr(ord(c) - 3) for c in (lambda _9: "".join((chr(ord(c) + 12) for c in _9)))(input("Enter the flag: ")))))))(
    lambda _25: (lambda _26: _26("".join(_25)))(
        lambda _27: (
            lambda _28: _28(
                "16_10_13_x_6t_4_1o_9_1j_7_9_1j_1o_3_6_c_1o_6r"
            )
        )(
            # ...
        )
    )
)
```

Things are way more readable now, we can now try to move out the one-liner. Coming from this...

```py
param = ((lambda _20: "".join((chr(123 ^ ord(c)) for c in _20)))(c) for c in "".join((chr(ord(c) - 3) for c in (lambda _9: "".join((chr(ord(c) + 12) for c in _9)))(input("Enter the flag: ")))))

(lambda _24: _24(param))(
    # ...
)
```

... to this.

```py
flag = input("Enter the flag: ")
flag = "".join(chr(ord(c) + 12) for c in flag)
flag = "".join((chr(ord(c) - 3) for c in flag))
flag = "".join((chr(123 ^ ord(c)) for c in flag))

(lambda _24: _24(flag))(
    # ...
)
```

Since, seems the first part is done already, lets continue with the rest. Same procedure as before (substitute and remove unnecessary lambdas). We finally arrive here.

```py
(lambda _56: _56(print("Correct FLAG!" if (lambda _37: lambda _38: _37 == _38)("".join(flag))("".join((chr(int(c, 36)+ 10) for c in "16_10_13_x_6t_4_1o_9_1j_7_9_1j_1o_3_6_c_1o_6r".split("_")))) else "Incorrect")))(
    lambda _57: lambda _58: _58
)
```

We can remove the last lambdas and get this:

```py
flag = input("Enter the flag: ")
flag = "".join(chr(ord(c) + 12) for c in flag)
flag = "".join((chr(ord(c) - 3) for c in flag))
flag = "".join((chr(123 ^ ord(c)) for c in flag))
target = "".join((chr(int(c, 36) + 10) for c in "16_10_13_x_6t_4_1o_9_1j_7_9_1j_1o_3_6_c_1o_6r".split("_")))
print("Correct FLAG!" if flag == target else "Incorrect")
```

Now things are readable and easy. All what's left is to take the value of `target` and revert the operations done to `flag`.

```py
target = [int(c, 36) + 10 for c in "16_10_13_x_6t_4_1o_9_1j_7_9_1j_1o_3_6_c_1o_6r".split("_")]
flag = ""

for value in target:
    flag += chr((value ^ 123) + 3 - 12)

print(flag)
```

Flag `FLAG{l4_1a_14mbd4}`