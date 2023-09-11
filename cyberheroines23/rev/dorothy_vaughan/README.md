# CyberHeroines 2023

## Dorothy Vaughan

> [Dorothy Jean Johnson Vaughan](https://en.wikipedia.org/wiki/Dorothy_Vaughan) (September 20, 1910 – November 10, 2008) was an American mathematician and human computer who worked for the National Advisory Committee for Aeronautics (NACA), and NASA, at Langley Research Center in Hampton, Virginia. In 1949, she became acting supervisor of the West Area Computers, the first African-American woman to receive a promotion and supervise a group of staff at the center. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Dorothy_Vaughan)
> 
> Chal: We ran this Fortran Software and received the output Final `Array:bcboe{g4cy:ixa8b|m:8}`. We have no idea what this means but return the flag to the [Human Computer](https://www.youtube.com/watch?v=zMAFPRgsCDM)
>
>  Author: [Kourtnee](https://github.com/kourtnee)
>
> [`dorothy`](dorothy)

Tags: _rev_

## Solution
We get a binary and the *encrypted* flag. To decrypt again we need to reverse the algorithm. We can do this by inspecting the binary with `Ghidra`.

The binary is compiled using [`GNU Fortran`](https://gcc.gnu.org/fortran/) and there are some remnants visible, but the interesting bits are two loops in [`MAIN__`](main__.c).

```c
for (local_10 = 1; iVar1 = local_18, (int)local_10 <= iVar2; local_10 = local_10 + 1) {
    if ((&bStack249)[(int)local_10] == 0x7d || (&bStack249)[(int)local_10] == 0x7b) {
      *(byte *)((long)&local_16c + (long)(int)local_10 + 3) = (&bStack249)[(int)local_10];
    }
    else {
      if ((local_10 & 1) == 0) {
        local_c = (&bStack249)[(int)local_10] + 3;
      }
      else {
        local_c = (&bStack249)[(int)local_10] + 7;
      }
      local_16d = (undefined)local_c;
      *(undefined *)((long)&local_16c + (long)(int)local_10 + 3) = local_16d;
    }
  }
```

```c
for (local_10 = 1; (int)local_10 <= iVar1; local_10 = local_10 + 1) {
    local_c = (uint)*(byte *)((long)&local_16c + (long)(int)local_10 + 3);
    if (local_c < 0x5b && 0x40 < local_c) {
      local_16e = (char)(local_c - 0x2f) + (char)((int)(local_c - 0x2f) / 0x1a) * -0x1a + 'A';
      (&cStack137)[(int)local_10] = local_16e;
    }
    else if (local_c < 0x7b && 0x60 < local_c) {
      local_16f = (char)(local_c - 0x4f) + (char)((int)(local_c - 0x4f) / 0x1a) * -0x1a + 'a';
      (&cStack137)[(int)local_10] = local_16f;
    }
    else {
      (&cStack137)[(int)local_10] = *(char *)((long)&local_16c + (long)(int)local_10 + 3);
    }
  }
```

The first loop does a increment of `3` or `7` to the ascii character. Every odd ascii code is incremented by 7, every even ascii code by 3. The characters `{}` are just copied therefore can be noted in the ouput on the correct position.

To analyze what the second loop does we can create a lookup table for each character.
```bash
['\x00', '\x01', '\x02', '\x03', '\x04', '\x05', '\x06', '\x07', '\x08', '\t', '\n', '\x0b', '\x0c', '\r', '\x0e', '\x0f', '\x10', '\x11', '\x12', '\x13', '\x14', '\x15', '\x16', '\x17', '\x18', '\x19', '\x1a', '\x1b', '\x1c', '\x1d', '\x1e', '\x1f', ' ', '!', '"', '#', '$', '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', '[', '\\', ']', '^', '_', '`', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', '{', '|', '}', '~', '\x7f', '\x80', '\x81', '\x82', '\x83', '\x84', '\x85', '\x86', '\x87', '\x88', '\x89', '\x8a', '\x8b', '\x8c', '\x8d', '\x8e', '\x8f', '\x90', '\x91', '\x92', '\x93', '\x94', '\x95', '\x96', '\x97', '\x98', '\x99', '\x9a', '\x9b', '\x9c', '\x9d', '\x9e', '\x9f', '\xa0', '¡', '¢', '£', '¤', '¥', '¦', '§', '¨', '©', 'ª', '«', '¬', '\xad', '®', '¯', '°', '±', '²', '³', '´', 'µ', '¶', '·', '¸', '¹', 'º', '»', '¼', '½', '¾', '¿', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', '×', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ð', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', '÷', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'þ']
``` 

We can see that the range `A-Z` and `a-z` are rolled by 8 positions. So the part implements a `rot-8` for `[A-Za-z]`. Knowing this we can reverse this easily.

```python
# create lookup for rot-8 part
lookup = [0]*255
for i in range(0, 255):
    val = i
    if i < 0x5b and 0x40 < i:
        val = (i-0x2f) + ((i-0x2f)//0x1a)*-0x1a + ord('A')
    elif i < 0x7b and 0x60 < i:
        val = (i-0x4f) + ((i-0x4f)//0x1a)*-0x1a + ord('a')
    lookup[i] = chr(val)

print(lookup)

flag_enc = "bcboe{g4cy:ixa8b|m:8}"
flag = b""

# undo to character rotation
for c in flag_enc:
    for i, cc in enumerate(lookup):
        if cc == c:
            flag = flag + chr(i).encode()
            break

# undo the 3,7 increments
for i in range(0,len(flag)):
    if flag[i] == ord('{') or flag[i] == ord('}'):
        c = flag[i]
    else:
        if (i+1)%2==0: x = 3
        else: x = 7
        c = flag[i]-x
    print(chr(c),end="")
```

Flag `chctf{h1dd3n_f1gur35}`