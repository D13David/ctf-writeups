# PearlCTF 2024

## not-so-easy

> Reversing a binary is pretty easy innit? But what if there are 200 of them?
>
>  Author: v1per
>
> [`binaries.zip`](binaries.zip)

Tags: _rev_

## Solution
This challenge comes with a lot of small binaries. After inspecting a few of them im `Ghidra` we can note that the binaries are pretty much identical. Every one of them calls a function `scramble` from the `main` function. The function scramble is pretty straight forward:

```c++
void scramble(void)
{
  uint local_14;
  int local_10;
  int local_c;
  
  local_14 = 0xae5;
  f(&local_14);
  local_c = -1;
  for (local_10 = 0; local_10 < 10; local_10 = local_10 + 1) {
    local_14 = local_14 + *(int *)(arr + (long)local_10 * 4) * local_c;
    local_c = -local_c;
    f(&local_14);
  }
  local_14 = local_14 ^ 0x47a;
  f(&local_14);
  return;
}
```

It basically iterates over the items of an global array and does some simple calculation on it. We can clean up the function a bit, to make it better understandable. 

```c++
  result = 0xae5;
  f(&result);
  mul = -1;
  for (i = 0; i < 10; i = i + 1) {
    result = result + (&arr)[i] * mul;
    mul = -mul;
    f(&result);
  }
  result = result ^ 0x47a;
  f(&result);
```

The only thing changing between the binaries are the `initialization value`, the `xor value` and the values and size of `arr`. To see, what every file is generating, we could run them all in sequence. There is only one issue, the call to `f(&result)` resets result to zero, so we don't get any good results back.

One thing we could do is to patch the calls out and grab the correct results afterwards. I went the route to extract the computation information and put them together in a small python script that does the computation. 

To get the information, we need to check where the info is located. Thankfully the constants are always at the same offset in file, so we can just read them. The array on the other hand can be variable in size and, as i turned out, was not always in a fixed location. But we can cope with this by checking the space around the array for some fixed markers. 

```
00003010  00 00 00 00  00 00 00 00   00 00 00 00  00 00 00 00                                           ................
00003020  E8 00 00 00  EA 00 00 00   B4 00 00 00  4D 01 00 00                                           ............M...
00003030  70 00 00 00  BA 01 00 00   6E 00 00 00  5A 01 00 00                                           p.......n...Z...
00003040  D6 00 00 00  39 01 00 00   47 43 43 3A  20 28 44 65                                           ....9...GCC: (De
00003050  62 69 61 6E  20 31 32 2E   32 2E 30 2D  31 34 29 20                                           bian 12.2.0-14) 
00003060  31 32 2E 32  2E 30 00 00   00 00 00 00  00 00 00 00                                           12.2.0..........
```

The arrays are roughly located at offset `3010h`. Right after the last element we see `GCC: ...`, so we can use this as a stop marker. By trial and error, I found the start offset of `3010h` is fine for all arrays, except we need to skip zero values.

With all the information at hand we can write our script and compute the result.

```
⛲੣ༀర⎸ᐭ᥼୬ᑽ⓹ᯒ♵ᰛ஫࿾ጉẨࢂᴶΈ☒ṊϿᔥጦᘾ⍃ྨᦺ᝭✷୅ǋᨒជໝᚽ᙮◷፠ბྌ࿲ၐၬᯞॼ⌠Ṷᛈᶧᷕेᙀ⎇ᖠᶰᒭࢡ঒൶রᥓ➲Ἂઃ≅᜾ࠀ࿡ሎᾑ▻☈Ủᾛઽॲↅ᝜ࠒ᝞ࠟᴍ଀ࢱᬲ਌☳ᜣဖ᢬ௐ੭ᑽᩓᠫ᭦᛺ảᾉᄴ৩ၜሽ᪴Ὴၺ፪✵ᅨ◒႒ঔ᧯஀⒥࣠Მί➥ᖻ᪝ᦉᮏᱴ᠚፽᫶ᵞ᠑⒌ᷴሷᕈᢌகᖑᴸḸ▕ᨥạᢇ↞ଽᑋऺᑪ⋴ẘṓࡶᕄἤൗ⌸ᶣઝહ⟰ᢱ⛽ᗋᐉೆᾱᾶࠢሮ‹ᖞ⋁ᳯ⅝ᇗୢⅣ␭əဳ′⇸ᮅᆅᙋᅡႝ⽖ᐤ࿴ᶫᴿᾭ⑧ᕉ๞⊻ᢊऱ
```

Oh no.. Something seems to be slightly off. Going back to the disassembly we can see that `Ghidra` omits a important information in the decompiled `C` code. Here's the last part of `scramble`, just before returning, when the xor is calculated.

```python
; calculate result ^ 0x47a
                      LAB_001011a1
001011a1 83 7d f8 09     CMP        dword ptr [RBP + i],0x9
001011a5 7e c2           JLE        LAB_00101169
001011a7 8b 45 f4        MOV        EAX,dword ptr [RBP + result]
001011aa 35 7a 04        XOR        EAX,0x47a
         00 00
; zero out result.. not interested in this at all
001011af 89 45 f4        MOV        dword ptr [RBP + result],EAX
001011b2 48 8d 45 f4     LEA        RAX=>result,[RBP + -0xc]
001011b6 48 89 c7        MOV        RDI,RAX
001011b9 e8 6b ff        CALL       f
         ff ff
; wtf Ghidral... Why not mentioning this?
001011be 8b 45 f4        MOV        EAX,dword ptr [RBP + result]
001011c1 2d fe 09        SUB        EAX,0x9fe
         00 00
```

There is a `sub` that is completely missing from the decompiled code. The code actually looks like:

```c++
result ^= 0x47a
f(&result);
result -= 0x9fe

// or what we actually want
result = (result ^ 0x47a) - 0x9fe
```

Right, lets extract this value as well and adapt our script. Running this, finally gives us the flag.

```python
import os
import string

data = [None]*200
start = [None]*200
end = [None]*200
sub = [None]*200

# read every file and extract information 
for name in os.listdir("."):
    if "not-so-easy-" in name:
        index = int(name.split("-")[-1])

        with open(name, "rb") as file:
            # start
            file.seek(0x1149, 0)
            start[index] = int.from_bytes(file.read(4), byteorder='little')

            # end
            file.seek(0x11ab, 0)
            end[index] = int.from_bytes(file.read(4), byteorder='little')

            # sub
            file.seek(0x11c2, 0)
            sub[index] = int.from_bytes(file.read(4), byteorder='little')

            # arr
            file.seek(0x3010, 0)
            buffer = []
            while True:
                value = int.from_bytes(file.read(4), byteorder='little')
                if value == 0:
                    continue
                if value == 977486663:
                    break
                buffer.append(value)
            data[index] = buffer

result = ""
for i in range(len(data)):
    x = -1
    y = start[i]
    for b in data[i]:
        y = y + b * x
        x = -x
    y = (y ^ end[i]) - sub[i]
    if y != ord('+'):
        result += chr(y)

print(result)
```

Flag `pearl{d1d_y0u_aut0m4t3_0r_4r3_y0u_h4rdw0rk1ng_?}`