# Tenable Capture the Flag 2023

## pi is overratEd

Tags: _stego_

## Solution

Disclaimer: The challenge only had *5* solves and I was none of them. I decided to use the very good feedback from the community (credits to them) and write about this challenge, since I didn't see any real writeup yet and writeups for this challenge where requested numerous times.

For this challenge no description is given. The only hint is in the name, where the `E` is written as uppercase letter. Since `pi` is mentioned as well, one could conclude that the hint points to [`Euler's number`](https://en.wikipedia.org/wiki/E_(mathematical_constant)).

Appart from this only a list of numbers are given, and thats all.

```
268293811

43467613

11502819

78705572

97132652

14581013

1710460813
```

This is probably where most teams struggled, including me. Finding the connection what to actually do with all those non-existing hints. The trick was, use the numbers as index *into* `e` and analyse the sequence of numbers starting at these indice. To do this, webservices exists, for instance [`here`](http://www.subidiom.com/pi/pi.asp). Choosing mode `Display 25 digits from start position` and constant `E` we can find the 25 digits:

```
268293811  => 1021089719722600266340076

43467613   => 0312310548810825311165920 

11502819   => 1159510131964056178944953

78705572   => 9510511403237922434710706

97132652   => 1149711613193728896498249 

14581013   => 0511111033100276964735988 

1710460813 => 7108631254521100432595136
```

To retrieve the flag from this the number sequences need to be converted to `ascii`. A bit of trial and error is needed here to split the number in sensible ascii sequences. For instance, taking `1021089719722600266340076`. We know we are looking for printable characters (most likely lowercase `'a' - 'z'` but we are looking at `37` - `126` to cover the full range). This means splitting `1` or `10` is not working, the first printable ascii code would be `102` that equals `f`, the same thing for the next one `108` equals to `l` and `97` equals to `a`.

```
102,108,97,19722600266340076
```

After this the sequence cannot be split further, since `1`, `19` and `197` are outside the printable range we are looking for. So we can conclude the first part is `fla` which sounds about right.

Moving on the the next sequence `0312310548810825311165920`. `0`, `03`, `031`, `0312` are all not working, so whats going on? We know the next character needs to be a `g` (we know this since we know the flag format), that would be a `103`. Our sequence starts with `03` but the `1` is missing. Checking out the previous number it ended with `197226...` and that exactly where the `1` is to be found, so character codes *can* be split between sequences. Moving on with this scheme we get the following numbers:

```
#1: 102, 108, 97, 1 
#2: 03, 123, 105, 
#3: 115, 95, 101, 
#4: 95, 105, 114, 
#5: 114, 97, 116, 1 
#6: 05, 111, 110, 3
#7: 7, 108, 63, 125
```

If we concat the numbers and convert them to ascii we get:
```python
"".join(chr(c) for c in [102, 108, 97, 103, 123, 105, 115, 95, 101, 95, 105, 114, 114, 97, 116, 105, 111, 110, 37, 108, 63, 125])
flag{is_e_irration%l?}
```

All right, that looks good. But the flag is not taken. Whats going on? Looking at the flag it *could* be `flag{is_e_irrational?}` and indeed this flag is the correct one. Double checking the number sequence still lead to this one bad character. Where this mistake is originating from, not sure. But the flag is complete enough to easily guess and replace the bad character and get the flag.

Flag `flag{is_e_irrational?}`