# Cyber Apocalypse 2024

## Tutorial

> Before we start, practice time!
> 
> Author: w3th4nds
> 
> [`pwn_tutorial.zip`](pwn_tutorial.zip)

Tags: _pwn_

## Solution
This challenge is more a Q&A for basic understandment concerning integer handling in `C`. The answers to the first questions are already in the description.

```bash
This is a simple questionnaire to get started with the basics.

◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉
◉                                                                                           ◉
◉  C/C++ provides two macros named INT_MAX and INT_MIN that represent the integer limits.   ◉
◉                                                                                           ◉
◉  INT_MAX = 2147483647                  (for 32-bit Integers)                              ◉
◉  INT_MAX = 9,223,372,036,854,775,807   (for 64-bit Integers)                              ◉
◉                                                                                           ◉
◉  INT_MIN = –2147483648                 (for 32-bit Integers)                              ◉
◉  INT_MIN = –9,223,372,036,854,775,808  (for 64-bit Integers)                              ◉
◉                                                                                           ◉
◉  When this limit is passed, C will proceed with an 'unusual' behavior. For example, if we ◉
◉  add INT_MAX + 1, the result will NOT be 2147483648 as expected, but something else.      ◉
◉                                                                                           ◉
◉  The result will be a negative number and not just a random negative number, but INT_MIN. ◉
◉                                                                                           ◉
◉  This 'odd' behavior, is called Integer Overflow.                                         ◉
◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉◉

[*] Question number 0x1:

Is it possible to get a negative result when adding 2 positive numbers in C? (y/n)

>> y

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠

[*] Question number 0x2:

What's the MAX 32-bit Integer value in C?

>> 2147483647

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
```

The next answer is due to integers are handled with `C`. The max int value is `2147483647`, if we convert to binary we have 1 `zero` and 31 `ones`. The `most significant bit` will tell us the sign of a number (if we use signed integers). Adding one to `INT_MAX` will therefore set bit 32 to one and thus wrapping to the negative range. But why is this not `-0` or `-1` you might ask, since we have all zeroes except the `msb`. This is how C (and most other languages as well) [`encode their integers`](https://en.wikipedia.org/wiki/Two%27s_complement), therefore we wrap to INT_MIN here.

```bash
[*] Question number 0x3:

What number would you get if you add INT_MAX and 1?

>> -2147483648

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
```

As described for question 3 the `signed 32 bit integer` will wrap but due to `two's complement` encoding we will end up with `-2` when adding `INT_MAX` to `INT_MAX`.

```bash
  01111111111111111111111111111111
+ 01111111111111111111111111111111
= 11111111111111111111111111111110 (binary)
= 2                                (decimal in two's complement)
```

```bash
[*] Question number 0x4:

What number would you get if you add INT_MAX and INT_MAX?

>> -2

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
```

Question 5 asks for the name of the `bug` (which is not a bug at all), the answer here is `integer overflow`. The answer to question 6 can be found again in the initial description and question 7 tests again your ability to add binary numbers and understand the two's complement.

```bash
[*] Question number 0x5:

What's the name of this bug? (e.g. buffer overflow)

>> integer overflow

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠

[*] Question number 0x6:

What's the MIN 32-bit Integer value in C?

>> -2147483648

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠

[*] Question number 0x7:

What's the number you can add to INT_MAX to get the number -2147482312?

>> 1337

♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
♠                   ♠
♠      Correct      ♠
♠                   ♠
♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠ ♠
HTB{gg_3z_th4nk5_f0r_th3_tut0r14l}
```

Flag `HTB{gg_3z_th4nk5_f0r_th3_tut0r14l}`