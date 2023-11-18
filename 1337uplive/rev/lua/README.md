# 1337UP LIVE CTF 2023

## Lunar Unraveling Adventure

> Start your mission, untangle the path and find the way to the dark side of the moon 🌘
>
> Author: DavidP, 0xM4hm0ud
> 
> [`lunar`](lunar)

Tags: _rev_

## Solution
For this challenge we get another archive containing a flag checker. Using `file` on the file tells us its `Lua bytecode, version 5.1`. Nice, this can be reversed by using [`unluac`](https://sourceforge.net/projects/unluac/), which gives us [`the following result`](lunar.lua).

```bash
$ java -jar unluac.jar lunar > lunar.lua
```

Cleaning this up a bit by hand gives us the first part, where some payload is decoded and some helper functions that are used to read various data types from the decoded data buffer.

```lua
local function decode_payload(i)
  local l, n, c = "", "", {}
  local f = 256
  local o = {}
  for e = 0, f - 1 do
    o[e] = string.char(e)
  end
  local e = 1
  
  local function a()
    local l = tonumber(string.sub(i, e, e), 36)
    e = e + 1
    local n = tonumber(string.sub(i, e, e + l - 1), 36)
    e = e + l
    return n
  end
  
  l = string.char(a())
  c[1] = l
  while e < #i do
    local e = a()
    if o[e] then
      n = o[e]
    else
      n = l .. string.sub(l, 1, 1)
    end
    o[f] = l .. string.sub(n, 1, 1)
    c[#c + 1], l, f = n, n, f + 1
  end
  return table.concat(c)
end

local data = decode_payload("212162751427527823Q22C21Y27727827522A27C27E1625I22B27H27E21Y22D27M27E27P27D27E22827Q27523Q22E27W1623Q27G27T27525I22G28025I22N2801622428822928021Y22M28822K28G28A28427J27S27I23Q22728G22J28822I28G27V28N1628S28N23Q22528B22228023Q29628N21Y22H21Y1627T23322X161327823523823323622R161M27821V22W29O23821223623222R21222O22Y22V22P21O2741227823822R22V22Q29I27823A29M29U1621527821X22X22W22P23822V2362372A323629G22W23921321222N22X2371X2342A022O2B222W22Q29X29Z21222T22X2382AA22T2362A12A322P2141621827822D2BF23823J2162BB2B62BL21223323921222W22X2BJ2BE2BG22R2BI21421222A2BT2122A422V23322W214152781E27E102782392362AH22P162A827522S23J29O29A27Z29228Y27I1621O28G28I2922872CU27822T23222V23827E1O2781K22029E16172782742DM2772842CK2D42DR2DM182752CK2DY2DO2771221K2782E1161W1T2DM1F2DN2DB2E42782EC2DO2EF2752E7212219162CK2772DU21M2EO2ET2DO2121R2ET2CK29J2122BN2EQ2ET2EJ161U2ED181I162CO1N2ED2E32E52752FD2EI2FG2F62ED2E92DM2FA2DO112CU2FK2FP2FS2782F72EV2EN2EP2FB2752ES2CK2CK2EV2EX2G42AE2F12DM2CK2CO1K21N2EU2DP1G2EY162CM2782A828Z2CK2CV27E2DU2DV2ED2762842CO2752CQ2CS2DB2752DD2DF27E2FA2782172DM27E1K2DZ2GU162DQ2G82842GQ27I2G02HH2HD2782E32DM2HB2GG2752HF2ET2HL2DO27I2A82A82HW2HC2DS2G12DM2FI2F42FK2I52902HR2751H2HU2GM2FK1L2GU2272ET27I2IC2G027821C2782I0142EC2762D426U21L2AE27523622V22S22Y29P2GX162CH23922R2382362I3162GZ2CH2CT2GQ2CX29O2IJ2JC23722S2IX162AG2CH2JA1V27822722W23A2372BJ2J22AO29Y2C222R22R22Q2C123622X21222S2A0161A2DP2H32AQ2BI2J82AY27E2AK27829D2I02752HQ2772KO2HC2HA2752HZ2GM2IT2I52GE2G127T2121S2G12CO2GS162FR2I02HQ2CM2GQ2DQ2CM2CM2F02752IS2JB161D2JN2782KD29J27I2EC2KD27I2GL2D42J42EI21S2DM29J2HW2G02KO21Z2JJ2782G82GS1021D2DM1P2ED2GP2FK2MD2DO2L02772FR2KP2JS2CK2LV2KX2DV2HY2DJ27529J2LJ2M72ET2LQ2IT2KR27E28Z2N027E2II2N12KP21E2IA2F42HD1K2N92M12GM2BP2CK2H82DO1021A2DM1X2ED2FJ2782NO2NQ2752162GU2M52L927E2212GK2ED2GX2FR2EC2J4162DI2O42H92FR2MK2GM2LZ2CK1Y2GU2IC2I22IN2IP2IP21V27E2102782L42KP2752DO2LA2N42OS2GJ2OX2MS2OX29J2MZ2HQ2CO2J42HQ2OB2MT2O12ML162HQ2EC2LV1K225161C162LJ2HQ2LM2GS2HQ2KD2PJ2OX1B2LL2P92DY2LT2PC27519162PT2OX29R2DY2OX2FD2LM2OX2HB2PX2HQ2IG2Q02KP2PH2FA29R2OX1J2PU2OX2GI2QB2IB29Q2P92F72FD2OX2JS2HQ2PY162L42QO162EA2IG2OX1Q2PI2P92EX2H62PC2PH2DI2R02MD2QK2OX2742GI2OX2132QL2QX2OP2IC2OX2112FL2OX2OG2RF2QX1Z162RI2QX1W162QT2QX2NO2JS2CL2NR2FE2HB2KS1022C2DM2OU2H921P2OL2782SG2LW2SC2M32SF2GT2SJ2H92PC22B2DB2OR2HE2KV2DB2EA2HQ29J2R52HX2SD2QX2A82SU2DQ2MS2EX2KX2E227E29J2L72752CO2HI2MU2DW2NL2AE2GF2SE2F52TM2FV2752M52MI2GF29J2DI2N82G12MD2782Q029J2N12F521U2ED2L02TV2DJ2N92CO2DQ2PZ2AE2N72IO2OT27E")

local bit_xor = bit32 and bit32.bxor or function(e, l)
  local n, o = 1, 0
  while 0 < e and 0 < l do
    local t, c = e % 2, l % 2
    if t ~= c then
      o = o + n
    end
    e, l, n = (e - t) / 2, (l - c) / 2, n * 2
  end
  if e < l then
    e = l
  end
  while 0 < e do
    local l = e % 2
    if 0 < l then
      o = o + n
    end
    e, n = (e - l) / 2, n * 2
  end
  return o
end

local valueForBitRange = function(l, e, n)
  if n then
    local e = l / 2 ^ (e - 1) % 2 ^ (n - 1 - (e - 1) + 1)
    return e - e % 1
  else
    local e = 2 ^ (e - 1)
    return e <= l % (e + e) and 1 or 0
  end
end
local e = 1

local function readInt()
  local l, n, c, t = string.byte(data, e, e + 3)
  l = bit_xor(l, 6)
  n = bit_xor(n, 6)
  c = bit_xor(c, 6)
  t = bit_xor(t, 6)
  e = e + 4
  return t * 16777216 + c * 65536 + n * 256 + l
end

local function readByte()
  local l = bit_xor(string.byte(data, e, e), 6)
  e = e + 1
  return l
end

local function readShort()
  local l, n = string.byte(data, e, e + 2)
  l = bit_xor(l, 6)
  n = bit_xor(n, 6)
  e = e + 2
  return n * 256 + l
end

local function readFloat()
  local e = readInt()
  local l = readInt()
  local t = 1
  local o = valueForBitRange(l, 1, 20) * 4294967296 + e
  local e = valueForBitRange(l, 21, 31)
  local l = (-1) ^ valueForBitRange(l, 32)
  if e == 0 then
    if o == 0 then
      return l * 0
    else
      e = 1
      t = 0
    end
  elseif e == 2047 then
    return o == 0 and l * (1 / 0) or l * (0 / 0)
  end
  return math.ldexp(l, e - 1023) * (t + o / 4503599627370496)
end

local function readByteArray(l)
  local n
  if not l then
    l = readInt()
    if l == 0 then
      return ""
    end
  end
  n = string.sub(data, e, e + l - 1)
  e = e + l
  local l = {}
  for e = 1, #n do
    l[e] = string.char(bit_xor(string.byte(string.sub(n, e, e)), 6))
  end
  return table.concat(l)
end
```

From the structure we can assume the obfuscator used was [`ironbrew-2`](https://github.com/Trollicus/ironbrew-2). The obfuscator uses a `vm-like` structure to represent and obfuscate code. The payload contains the bytecode, which is executed and the following part loads and initializes the vm runtime.

```lua
local e = l

local function createTableAndCount(...)
  return {
    ...
  }, select("#", ...)
end

local function loadImage()
  local i = {}
  local o = {}
  local e = {}
  local d = {
    i,
    o,
    nil,
    e
  }
  local e = readInt()
  local t = {}
  for n = 1, e do
    local l = readByte()
    local e
    if l == 3 then
      e = readByte() ~= 0
    elseif l == 2 then
      e = readFloat()
    elseif l == 0 then
      e = readByteArray()
    end
    t[n] = e
  end
  for e = 1, readInt() do
    o[e - 1] = loadImage()
  end
  for d = 1, readInt() do
    local e = readByte()
    if valueForBitRange(e, 1, 1) == 0 then
      local o = valueForBitRange(e, 2, 3)
      local f = valueForBitRange(e, 4, 6)
      local e = {
        readShort(),
        readShort(),
        nil,
        nil
      }
      if o == 0 then
        e[3] = readShort()
        e[4] = readShort()
      elseif o == 1 then
        e[3] = readInt()
      elseif o == 2 then
        e[3] = readInt() - 65536
      elseif o == 3 then
        e[3] = readInt() - 65536
        e[4] = readShort()
      end
      if valueForBitRange(f, 1, 1) == 1 then
        e[2] = t[e[2]]
      end
      if valueForBitRange(f, 2, 2) == 1 then
        e[3] = t[e[3]]
      end
      if valueForBitRange(f, 3, 3) == 1 then
        e[4] = t[e[4]]
      end
      i[d] = e
    end
  end
  d[3] = readByte()
  return d
end
```

After this the interesting part starts. The function `run` executes the logic. For this the code is split into functional fragments which are executed with associated `opcodes`. To analyze this we can print the opcode, that will effectively give us the program flow.

```lua
local function run(e, d, a)
  local n = e[1]
  local l = e[2]
  local e = e[3]
  return function(...)
    local t = n
    local D = l
    local o = e
    local i = s
    local l = 1
    local c = -1
    local C = {}
    local s = {
      ...
    }
    local F = select("#", ...) - 1
    local r = {}
    local n = {}
    for e = 0, F do
      if o <= e then
        C[e - o] = s[e + 1]
      else
        n[e] = s[e + 1]
      end
    end
    local e = F - o + 1
    local e, o
    while true do
      e = t[l]
      o = e[1]
      # added to dump the opcodes
      print(o)
      if o <= 46 then
        if o <= 22 then
          if o <= 10 then
            if o <= 4 then
              if o <= 1 then
                if o == 0 then
                  local o = e[2]
                  local t = n[o]
                  local c = n[o + 2]
                  if 0 < c then
                    if t > n[o + 1] then
                      l = e[3]
                    else
                      n[o + 3] = t
                    end
                  elseif t < n[o + 1] then
                    l = e[3]
                  else
                    n[o + 3] = t
                  end
                else
                  local e = e[2]
                  n[e](f(n, e + 1, c))
                end
              elseif o <= 2 then
                if n[e[2]] then
                  l = l + 1
                else
                  l = e[3]
                end
-- ... snip
```

When executing, we get something like this:

```bash
50
47
47
47
40
4
84
84
24
Enter the flag: asd
27
42
70
53
42
70
53
42
70
53
7
43
7
32
42
58
Input length needs to be 39 characters!
2
42
35
34
Sorry, the flag is not correct. Try again.
17
```

Right, we know the flag needs to be 39 characters wide. Lets try again. This time the program flow looks different. A lot sequences repeat which suggests that those parts run per flag character.

```bash
50
47
47
47
40
4
84
84
24
Enter the flag: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
27
42
70
53
42
70
53
...
7
43
7
32
86
35
7
35
92
42
68
87
80
48
8
74
65
37
46
42
30
22
61
53
42
68
87
80
48
...
8
74
65
37
46
42
30
22
61
53
35
42
10
81
46
13
63
46
35
74
13
63
46
35
74
13
63
...
43
7
76
79
61
2
42
35
34
Sorry, the flag is not correct. Try again.
17
```

By going opcode by opcode and checking the functionality we can make sense out of the flow. And/or find interesting parts where we can print informations. For instance, opcode `50` and `47` are initializing an array with values.

```lua
-- opcode 50
n[e[2]] = {}
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]

-- opcode 47
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
l = l + 1
e = t[l]
n[e[2]] = e[3]
```

Opcode 40 copies the array to some memory location, and opcode 24 prints the input prompt and reads input. 

```lua
-- opcode 40
local l = e[2]
local o = n[l]
for e = l + 1, e[3] do
    table.insert(o, n[e])
end
```

Going through the whole sequence bit by bit gives us eventually enough informations to reverse the full flow and lets us recreate the original lua code.

```lua
local flag = {
    0x4a,0x50,0x57,0x4d,0x4c,0x58,0x50,0x42,0x52,0x7b,0x57,0x67,0x34,0x5f,0x61,0x6b,0x34,0x5f,0x65,0x4f,0x34,0x5f,0x4f,0x33,0x75,0x5f,0x73,0x67,0x59,0x5f,0x32,0x37,0x34,0x38,0x39,0x32,0x37,0x33,0x7d
}

local function encryptChar(char, shift)
    local byte = string.byte(char)
    if byte >= 65 and byte <= 90 then
        byte = ((byte - 65 + shift) % 26) + 65
    elseif byte >= 97 and byte <= 122 then
        byte = ((byte - 97 + shift) % 26) + 97
    end
    return string.char(byte)
end

local function check(input, idx)
    local enc = encryptChar(string.char(input), idx)
    if enc == string.char(flag[idx]) then
        return true
    else
        return false
    end
end

local function checkFlag(input)
    local inputBinary = {}

    for i = 1, #input do
        table.insert(inputBinary, string.byte(input:sub(i, i)))
    end

    if #inputBinary ~= #flag then
        print("Input length needs to be " .. #flag .. " characters!")
        return false
    end

     local checkResult = {}
    for i = 1, #inputBinary do
        table.insert(checkResult, check(inputBinary[i], i))
    end

    local count = 0
    for i, value in ipairs(checkResult) do
       count = count + (value and 1 or 0)
    end
    return count == #flag
end

io.write("Enter the flag: ")
local input = io.read()

if checkFlag(input) then
    print("Congratulations! You've found the correct flag.")
else
    print("Sorry, the flag is not correct. Try again.")
end
```

With this we can create a script that decodes the flag for us.

```python
flag = [0x4a,0x50,0x57,0x4d,0x4c,0x58,0x50,0x42,0x52,0x7b,0x57,0x67,0x34,0x5f,0x61,0x6b,0x34,0x5f,0x65,0x4f,0x34,0x5f,0x4f,0x33,0x75,0x5f,0x73,0x67,0x59,0x5f,0x32,0x37,0x34,0x38,0x39,0x32,0x37,0x33,0x7d]

def decrypt_char(byte, shift):
    if 65 <= byte <= 90:
        byte = ((byte - 65 - shift + 26) % 26) + 65
    elif 97 <= byte <= 122:
        byte = ((byte - 97 - shift + 26) % 26) + 97
    return chr(byte)

for i, c in enumerate(flag):
    print(decrypt_char(c, i+1), end="")
```

Another possible solution would be to brute force the flag. This works by injecting print statements in some opcode that returns conditional results based on, if the current flag character is valid or not.

```python
import subprocess

def run_command(command, input_data):
    try:
        result = subprocess.run(command, input=input_data, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        return None

command_to_run = ["lua", "decomp.lua"]
characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_\{\}'
flag_length = 39
flag = ""
true_count = 0

while true_count < flag_length:

    for char in characters:
        current_attempt = flag + char + "A" * (flag_length - len(flag) - 1)
        result = run_command(command_to_run, current_attempt)

        if result and result.count("true") > true_count:
            flag += char
            true_count += 1

print("Final flag:", flag)

"""
In the decompiled lua code add this print statement:

elseif o <= 61 then
    print(n[e[2]])
    return n[e[2]]
"""
```

Both methods will give the flag.

Flag `INTIGRITI{Lu4_lu4_lU4_R3v_reV_27489273}`