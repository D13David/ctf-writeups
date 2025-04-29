# CTF@CIT 2025

## Serpent

> I made this obfuscator a few years ago for my intro to python class. A few features broke but it still works enough, hope u guys like it :)
>
>  Author: ronnie
>
> [`serpent.py`](serpent.py)

Tags: _rev_

## Solution
This challenge gives us some obfuscated python code. The way to go is to deobfuscate things and make them more readable. There are two things obfuscating readability, one is naming in general the other one is integer constants being expressed as weird floating point expressions.

Let's start with the first function. We resolve all the calculations and replace them with their result. Lets start with the script entry:

```py
if __name__ == chr(int(((1955.2271382109936/303.1857043087163)*(0.07202237493314385*204.53501662471783))))+chr(int(((5323873.869855661/124.82746302418342)/(0.629099699936762*713.6323524013322))))+chr(int(((56243034.98052258/536.3820280892107)/(1.438309237907811*668.8300266140869))))+chr(int(((0.0008331530443309137*424.7048420918733)*(12932.015807290707/47.17441144365127))))+chr(int(((0.0002051828163215019*806.8426094322679)*(369879.89776461944/583.1781471513561))))+chr(int(((49.57895095805172*897.4246201338177)/(222765.26993180002/550.7377619407324))))+chr(int(((30.796010142565716/223.61686434645145)*(1.061236330086653*650.0123310865858))))+chr(int(((955.3515679084579/627.637950528471)*(27305.53736183058/437.50311296409166)))):
    IllIlllIIllIlIIIIIlI()
```

Thats already way better, next up is to name functions and variables propery.

```py
if __name__ == '__main__':
    IllIlllIIllIlIIIIIlI()
```

Perfect.. Ok, this was the simple case. Lets look at another one.

```py
if __name__ == '__main__':
    main()
```

```py
def IllIlllIIllIlIIIIIlI():
    IllIlllIIlll = lIllIlIIlIlllllIllll()
    lllIIIllIllII = IIIIlIIlIll(IllIlllIIlll)
    llIlIIIIIlllIIll = "".join(map(chr, [int(((((5562435773715.241/704.0901771947747)/(1.9699638544042952*427.5113719080957))/((6511651.89705106/700.9721129717325)/(3759.0968189663154/202.71450353747088)))/(((58563.97711529514/633.916783558375)/(0.18167811512809387*688.9592187291072))*((366.8234315078891/741.1654638897988)*(3.0935475861695996*247.32235300078142))))), int(((((8.158991397809261/273.475019145894)*(96035.797198189/276.3425089462911))/((63.284521634965394/259.320710761768)*(347368.12291447254/702.0095150389117)))*(((98048.41789863585*717.3471158801076)/(0.16793423907148727*914.6549497450158))/((81.06730839186591*989.2223361602637)/(0.17689882396196413*841.7190826953124))))), int(((((353.5756925477515/51.6645409333705)*(0.035006118975224536*328.96075915170786))/((225.92999400470666/261.92315648895067)*(6.007969473501056*141.18304509141504)))*(((1110191.8994177037/469.8700616411935)/(0.9848805572981928*813.1439482646323))*((26135366.70899981/775.4886382212433)/(56792.88080686416/445.4337456493366))))), int(((((2356972639662.039/70.3626093793244)/(0.3609240153481338*993.710708107654))/((471297892.3107161/891.0216234419607)/(216030.94828519435/330.86535561556144)))/(((7.01417155063326/677.7164743941144)*(2.5095269356141787*142.12455386373753))*((114.86326240131523*741.9720949725735)/(1.3536081927155608*247.95672739666492)))))]))
    IllIIIllllIlII = "".join(map(chr, [int(((((7656946845755.739/161.37227393857216)/(458970.3173774403/496.00112881536086))/((55912695.00794399/446.29915838995026)/(132393.82420952836/982.8582344805285)))/(((1.3475462712431223/537.5911158305258)*(26689.83723984362/150.95107396076043))*((211.88690134887918/167.63313101179358)*(0.8228898355561193*956.7973883632889)))))]))
    lIIlllllIl = llIlIIIIIlllIIll + lllIIIllIllII + IllIIIllllIlII
```

```py
def main():
    IllIlllIIlll = lIllIlIIlIlllllIllll()
    flag_value = compute_flag_value(IllIlllIIlll)
    flag_start = 'CIT{'
    flag_end = '}'
    flag = flag_start + flag_value + flag_end
```

We basically resolve as much as possible and name everything we know the context about with a somewhat meaningful name. This we do till we gathered enough context to make sense out of the program. In this case it's not too much work, as we can see quite early that the flag is build up for us without any additional input needed. 

```py
def lIllIlIIlIlllllIllll() -> str:
    secret = 'S3cr3tS33d_For_CTFC0mp'
    secret_hash = hash(secret)
    llIIlIllIIllIIIIll = IIllIIIllIIlIIIIlIl(secret_hash, IIIllIIllllIII=10)
    transformer = Transformer(llIIlIllIIllIIIIll)
    IIIllIIlII = transformer.lIIllllIIllI()
    IllllIIllIIl = transformer.IIIlIIlIIlIl(IIIllIIlII)
    IIIllIIlIII = transformer.IlIIIllIlIlIlI(IllllIIllIIl)
    IlIIIIIlIIIIlIIIIIII = (int(hashlib.sha1(IllllIIllIIl.encode()).hexdigest()[:8], 16)) & 0xFFFF
    llllllIIlIlIIIIlI = IIllIllIIIIIIlIl([secret_hash, llIIlIllIIllIIIIll, IIIllIIlIII, IlIIIIIlIIIIlIIIIIII])
    return llllllIIlIlIIIIlI

def compute_flag_value(val: str) -> str:
    result = []
    for c in val:
        result.append(chr(((ord(c) - 48 + 7) % 75) + 48))
    return "".join(result)

def main():
    IllIlllIIlll = lIllIlIIlIlllllIllll()
    flag_value = compute_flag_value(IllIlllIIlll)
    flag_start = 'CIT{'
    flag_end = '}'
    flag = flag_start + flag_value + flag_end

if __name__ == '__main__':
    main()
```

The only thing the program forgets is to *print* the flag. But this we can quickly change.

```py
def main():
    IllIlllIIlll = lIllIlIIlIlllllIllll()
    flag_value = compute_flag_value(IllIlllIIlll)
    flag_start = 'CIT{'
    flag_end = '}'
    flag = flag_start + flag_value + flag_end
    print(flag) # we add this
```

Running the program, gives us the flag.

Flag `CIT{7777aKMpU9X3TqnD}`