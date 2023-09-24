# vsCTF 2023

## LVMProtect

> vsCTF technologies has just made the worlds™ best™ Lua™ obfuscator™ - can you break it?
> 
> Hint: Don't be afraid to run the script, this isn't a static analysis challenge.
> 
> Hint 2: the flag is not just present as a sha-hash 🙂 (there is no password cracking / similar involved with this challenge)
>
>  Author: 3dsboy08
>
> [`lvmprotect.lua`](lvmprotect.lua)

Tags: _rev_

## Solution

Disclaimer: This challenge I ran out of time during the event and finished it in aftermath.

For this challenge we get a obfuscated `lua script`. First thing is to beatify it a bit to make it [`somewhat readable`](lvmprotect_beatified.lua). At the beginning there are the typical function re-defines which can easily be replaced.

```lua
local S = string.sub
local N = getfenv or function()
        return _ENV
    end
local P = string.char
local V = table.insert
local Z = tonumber
local X = pairs
local i = table.getn or function(e)
        return #e
    end
local O = select
local C = l
local T = setmetatable
local d = unpack or table.unpack
local B = string.byte
local t = {}
```

The next part decodes a large string. I dumped the blob to see if there are any interesting strings in it, but nothing exciting so far...

```lua
local t = {}
for e = 0, 255 do
    t[e] = string.char(e)
end
local function decode_program_image(data)
    local l, n, o = e, e, {}
    local W = 256
    local index = 1
    local function read_next_block()
        local length = tonumber(string.sub(data, index, index), 36)
        index = index + 1
        local block_data = tonumber(string.sub(data, index, index + length - 1), 36)
        index = index + length
        return block_data
    end
    l = string.char(read_next_block())
    o[1] = l
    while index < #data do
        local e = read_next_block()
        if t[e] then
            n = t[e]
        else
            n = l .. string.sub(l, 1, 1)
        end
        t[W] = l .. string.sub(n, 1, 1)
        o[#o + 1], l, W = n, n, W + 1
    end
    return table.concat(o)
end

local Z = decode_program_image(
        "26P24N26P26R26P27827822924524X27726P24123N24321R1M24W27E2..."
)
```

Then a few helper functions are provided. Reading the source we can give the functions some names. For instance, three of the functions are used to read int values of various size from the program image at a given position. The position is stored outside of the functions, so consecutive calls read from different offsets.

```lua
local function readInt32()
    local l, R, o, n = string.byte(Z, e, e + 3)
    l = f(l, 241)
    R = f(R, 241)
    o = f(o, 241)
    n = f(n, 241)
    e = e + 4
    return (n * 16777216) + (o * D) + (R * 256) + l
end
local function readInt8()
    local l = f(string.byte(Z, e, e), 241)
    e = e + 1
    return l
end
local function readInt16()
    local n, l = string.byte(Z, e, e + 2)
    n = f(n, 241)
    l = f(l, 241)
    e = e + 2
    return (l * 256) + n
end
```

Scanning over the next function, it looks like it parses the program image and creates lists of constants, opcodes etc... In fact it looks strongly related to [`GoogleCTF23 ZERMATT`](../../../googlectf23/rev/zermatt/README.md) challenge.

```lua
local function I()
    local C = {}
    local P = {}
    local l = {}
    local d = {[3] = C, [8] = {}, [4] = P, [6] = l, [9] = nil, [1] = nil}
    local l = {}
    local X = {}
    local l = {}
    for d = 1, readInt8() == 0 and readInt16() * 2 or readInt32() do
        local l = readInt8()
        while true do
            if (l == 1) then
                local o, R, n = "", readInt32()
                if (R == 0) then
                    l = o
                    break
                end
                n = string.sub(Z, e, e + R - 1)
                n = {string.byte(n, 1, #n)}
                e = e + R
                for e = 1, i(n) do
                    o = o .. t[f(n[e], 241)]
                end
                l = o
                break
            end
            if (l == 2) then
                local n, e = readInt32(), readInt32()
                local R, n, e, o = 1, (cntBitsOrBitSet(e, 1, 20) * (2 ^ 32)) + n, cntBitsOrBitSet(e, 21, 31), ((-1) ^ cntBitsOrBitSet(e, 32))
                if e == 0 then
                    if n == 0 then
                        l = o * 0
                        break
                    else
                        e = 1
                        R = 0
                    end
                elseif (e == 2047) then
                    l = (o * ((n == 0 and 1 or 0) / 0))
                    break
                end
                l = (o * (2 ^ (e - 1023))) * (R + (n / (2 ^ 52)))
                break
            end
            l = nil
            break
        end
        X[d] = l
    end
    if Q < 1 then
        Q = 1
        local l = readInt16()
        d[a] = string.sub(Z, e, e + l - 1)
        e = e + l
    end
    for e = 1, readInt32() do
        C[e - 1] = I()
    end
    for t = 1, readInt32() do
        local e = readInt8()
        if (cntBitsOrBitSet(e, 1, 1) == 0) then
            local S = cntBitsOrBitSet(e, 2, 3)
            local f, Z, B, l = readInt16(), readInt8() == 1, readInt16(), {}
            local W = cntBitsOrBitSet(e, 4, 6)
            local e = {[2] = B, [8] = nil, [3] = Z, [7] = f}
            if (S == 3) then
                e[3], e[8] = readInt32() - D, readInt16()
            end
            if (S == 1) then
                e[3] = readInt32()
            end
            if (S == 0) then
                e[3], e[8] = readInt16(), readInt16()
            end
            if (S == 2) then
                e[3] = readInt32() - D
            end
            if (cntBitsOrBitSet(W, 2, 2) == 1) then
                l[3] = 3
                e[3] = X[e[3]]
            end
            if (cntBitsOrBitSet(W, 3, 3) == 1) then
                l[8] = 8
                e[8] = X[e[8]]
            end
            if (cntBitsOrBitSet(W, 1, 1) == 1) then
                l[2] = 2
                e[2] = X[e[2]]
            end
            if Z then
                V(d[8], e)
                e[9] = l
            end
            P[t] = e
        end
    end
    d[9] = readInt8()
    return d
end
```

The suspicion rises that we have another `vm` here we need to hack. Ok, continuing to analyze the code. The next, and last function is the `vm runtime`. As things are obfuscated it's very hard to read. Things are deeply cascaded but after reading over the code, we can flatten things and make it more readable. The loop is basically a bunch of `if .. elseif .. ` condition to handle each opcode. After going over the whole loop we end up with something like this:

```lua
while true do
    e = o[l]
    R = e[7]
    if I > 0 then
        n[e[2]] = e[3]
    end

    if R == 2 then
        local R
        local W
        n[e[2]] = e[3]
        l = l + 1
        e = o[l]
        n[e[2]] = e[3] ^ n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] / n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] % e[8]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] - n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = e[3] - n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = e[3] ^ n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] * n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] % e[8]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] + n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]][n[e[8]]]
        l = l + 1
        e = o[l]
        W = e[3]
        R = n[W]
        for e = W + 1, e[8] do
            R = R .. n[e]
        end
        n[e[2]] = R
    end
    
    if R == 3 then
        local X
        local f, Z
        local R
        n[e[2]] = n[e[3]][n[e[8]]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] - e[8]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]][n[e[8]]]
        l = l + 1
        e = o[l]
        n[e[2]] = W[e[3]]
        -- snip
        n[e[2]] = n[e[3]] + n[e[8]]
        l = l + 1
        e = o[l]
        n[e[2]][n[e[3]]] = n[e[8]]
    end
    
    if R == 4 then
        n[e[2]] = #n[e[3]]
        l = l + 1
        e = o[l]
        n[e[2]] = n[e[3]] + n[e[8]]
        l = l + 1
        e = o[l]
        W[e[3]] = n[e[2]]
        l = l + 1
        e = o[l]
        n[e[2]] = e[3]
        l = l + 1
        e = o[l]
        n[e[2]] = W[e[3]]
        l = l + 1
        e = o[l]
        l = n[e[2]] == e[8] and l + 1 or e[3]
    end
    
    if R == 7 then
        l = n[e[2]] == e[8] and e[3] or l + 1
    end
    
    if R == 8 then
        local W
        local S
        local R
        n[e[2]] = Z[e[3]]
        l = l + 1
        e = o[l]
        -- snip
        W = n[S]
        for e = S + 1, e[8] do
            W = W .. n[e]
        end
        n[e[2]] = W
    end

    -- more opcode handlers here...
```

This is a bit better, but the code is still hard to understand. Also there is a hint that static analysis is not the way to go, so refactoring it even more is probably not the way to go. We can still deduce a few things from this.

* `l` is the current read index and reads the next opcode information from our code segment
* `n` is used like scratch memory or registers. Things are written and read from here
* the read index is increased within the opcode handlers quite a lot. Things are read from the code segment, most likely some intermediate values like constants or jump offsets

Since we don't do further static analysis what we can do is to get a idea on how data is processed and how dataflows are. But lets run the whole thing first.

```bash
$ lua vm.lua
Welcome to vsctf:tm: Secure:tm: Login:tm:!

Enter key:
a
Invalid login!
```

We need to enter a key. Since we don't know the key we end up with a `Invalid login!` message. To get an idea on what functions are doing I put random `print` statements in the code and checked the output. For instance, function `187` is used to print output to screen.

```lua
if R == 187 then
    local e = e[2]
    n[e](n[e + 1])
    print(n[e+1])
end

```lua
if R == 166 then
    do
        print(n[e[2]])
        return n[e[2]]
    end
end
```

Function `166` gives some interesting values. Among lots of numbers there are a few strings we know already and two hashes: `ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb` and `781059743e99ea6b979df329b5240350f8286ac41a3ad534dc7dff0d42d90d20`. When we change our input we can observe that one hash changes and the other stays the same.

```bash
...
3025348097.0
1249958226.0
176163136.0
2853527962.0
3921175115.0
ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb
781059743e99ea6b979df329b5240350f8286ac41a3ad534dc7dff0d42d90d20
false
Invalid login!
Invalid login!
Invalid login!
```

It looks like `sha256` hashes, we can verify this:

```bash
$ echo -n "a" | sha256sum
ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb  -
```

Perfect, what do we have here? One `sha256` hash for our input and a `sha256` hash that most likely is the hash for the login key aka flag. Cracking the hash is not an valid option (also confirmed with the second hint), but how do we get the flag value? The assumption is that the flag is hashed at some point and then the hash values are compared. If the values are not equal the `Invalid login!` message is printed.

This means we need to go back the call history and hope to find the point where the hash is generated. To do this I tracked each opcode in a list so I could dump the call history.

```lua
local function dump_stack(n)
    local file = io.open("callstack.txt", "w")
    local c = 0
    file:write(tostring(#callstack) .. "\n")
    for i = #callstack, #callstack - n + 1, -1 do
        file:write(string.format("%d: %d", i, callstack[i]) .. "\n")
    end
    file:close()
end

-- ...

-- vm loop
while true do
    e = o[l]
    R = e[7]
    if I > 0 then
        n[e[2]] = e[3]
    end
    
    table.insert(callstack, R)
    
    if R == 2 then
        -- ...
```

Now we can dump the call stack on interesting locations, to get fancy and long columns of numbers we can stare at.

```lua
if R == 187 then 	-- print
    local e = e[2]
    n[e](n[e + 1])

    -- dump stack when invalid login message is printed
    if n[e+1]=="Invalid login!" then
        dump_stack(4000)
    end
end
```

```bash
2375944: 187
2375943: 166
2375942: 131
2375941: 2
2375940: 176
2375939: 131
2375938: 2
2375937: 176
2375936: 131
2375935: 2
2375934: 176
2375933: 131
2375932: 2
2375931: 176
2375930: 131
2375929: 2
2375928: 176
2375927: 131
2375926: 2
2375925: 176
2375924: 131
2375923: 2
2375922: 176
2375921: 131
```

Now we have to check what the functions are doing. `187` we know, is the print function. `166` is the function giving us the hash values. `131` is some branch code and `2` reads and decodes a character value and appends the value to a string. `176` then does a memory assignment. The sequence builds a string character by character before the whole string is returned and printed. We can verify this by putting a print in function `2`.

```bash
I
In
Inv
Inva
Inval
Invali
Invalid
Invalid
Invalid l
Invalid lo
Invalid log
Invalid logi
Invalid login
Invalid login!
```

At this point I went back through the call history in the same fashion but could not find a trace of the flag. Another thing I tried is to dump the `scratch memory` for every opcode execution. This resulted in `2GB` of data to analyze. There where nice things to be found, like a fake flag `vsctf{nic3_try_l0l}`, but no flag...

And this is where I ran out of time. After the event was over, the challenge author dropped a note, saying the solution would be to bypass the validation to get the flag printed *afterwards*. In fact this is something I tried, but dropped the idea since the program started crashing. What I tried was to modify the `jmp` handlers to switch the jump offsets. In the code we can find a lot of those jumps that have the form `l = n[e[2]] == e[8] and l + 1 or e[3]`. But as mentioned, things started crashing and therefore I dropped the idea and concentrated on finding the spot where the flag was hashed.

But... The flag was never hashed and the intended solution was to sneak in the flag `hash` before the compare, so the compare would branch to the success case. So lets do this:

We take function `166` (remember, the function which gives us the hash values), and just force returing the flag hash when the function would actually return our user input has.

```lua
-- ...
elseif R <= 166 then
    do
        -- if the function would return sha256 of our input ('a') we return the flag hash instead
        if n[e[2]] == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb" then
            return "781059743e99ea6b979df329b5240350f8286ac41a3ad534dc7dff0d42d90d20"
        end
        return n[e[2]]
    end
elseif R > 167 then
-- ...
```

Thats it... Thats all we have to do. Lets run and finally get the flag.

```bash
$ lua vm.lua
Welcome to vsctf:tm: Secure:tm: Login:tm:!

Enter key:
a
Correct key! For reference, your flag is: vsctf{n3xt_t1me_w3_w1ll_mak3_eq_ev3n_m0r3_s3c3re!}
```

Flag `vsctf{n3xt_t1me_w3_w1ll_mak3_eq_ev3n_m0r3_s3c3re!}`