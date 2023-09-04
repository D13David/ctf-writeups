# DownUnderCTF 2023

## Welcome to DUCTF!

> To compile our code down here, we have to write it in the traditional Australian Syntax: ( Try reading bottom up! )
>
> ¡ƃɐlɟ ǝɥʇ ʇno noʎ ʇuᴉɹd ll,ʇᴉ puɐ ɹǝʇǝɹdɹǝʇuᴉ ǝɥʇ ɥƃnoɹɥʇ ʇᴉ unɹ puɐ ǝɹǝɥ ǝpoɔ sᴉɥʇ ǝʞɐʇ ʇsnJ .ƎWWIפ uɐɔ noʎ NOʞƆƎɹ I puɐ ┴∩Oq∀ʞ˥∀M ƃuᴉoפ '¡H∀N H∀Ǝ⅄ 'ɐʞʞɐ⅄ pɹɐH 'ǝʞᴉl sǝɹnʇɐǝɟ ɔᴉʇsɐʇuɐɟ ƃuᴉɹnʇɐǝℲ
>
> .snlԀ snlԀ ǝᴉssn∀ ǝʌᴉsnlɔuᴉ ʎʇᴉuɐɟoɹd ǝɹoɯ 'ɹǝʇsɐɟ 'ɹǝʇʇǝq ǝɥʇ oʇ noʎ ǝɔnpoɹʇuᴉ I uɐɔ ʇnq ++Ɔ ɟo pɹɐǝɥ ǝʌ,no⅄
>
>  Author: pix
>
> [`welcome_to_ductf.aplusplus`](welcome_to_ductf.aplusplus)

Tags: _misc_

## Solution
For this challenge we are getting a `aplusplus` file with some pseudocode. The fun thing is that the code is read bottom to up. It's still kind of easy to follow.

There are a few interesting bits to the *language*. Variables are assigned with `;value = <name> NOʞƆƎɹ I`, and printing something seems to be `;<value> ƎWWIפ`.

Down (up) the road, we find a fake flag thatreads `CTFDU{YaFlagAin'tHereMate!}`. 

```
;„}¡ǝʇɐWǝɹǝHʇ,uᴉ∀ƃɐlℲɐ⅄{∩DℲ┴Ɔ„ = פ∀˥Ⅎ_∀⅄ NOʞƆƎɹ I
```

If we read through the code we find some interesting parts:

```
;„}„ = H┴MƎɹ┴S NOʞƆƎɹ I
```

```
;„{Ⅎ┴Ɔ∩D„ = Ⅎ∀˥פ NOʞƆƎɹ I
```

```
;„ƎɹƐɥʍƐɯoϛ_ʞɔ0lƆoϛ-sʇƖ„ = ɹnoHʎddɐH NOʞƆƎɹ I    
```

```
;H┴MƎɹ┴S + ɹnoHʎddɐH + Ⅎ∀˥פ ƎWWIפ	
```

Stitching this togther gives us `}ƎɹƐɥʍƐɯoϛ_ʞɔ0lƆoϛ-sʇƖ{Ⅎ┴Ɔ∩D` and flipping the characters gives the flag.

Flag `DUCTF{1ts-5oCl0ck_5om3wh3rE}`