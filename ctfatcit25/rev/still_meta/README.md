# CTF@CIT 2025

## Still Meta

> Find the flag.
>
> If you cannot solve this challenge using PUC Lua, try using LuaJIT instead.
>
>  Author: ronnie
>
> [`stillmeta.lua`](stillmeta.lua)

Tags: _rev_

## Solution
For this challenge we get an obfuscated lua script. After reformatting things get a little clearer at least.

```bash
lua-format --column-limit=1000 stillmeta.lua > stillmeta_formatted.lua
```

It's a long script with nearly 10k lines but the obfuscation fingerprint looks very much what [`Hercules`](https://github.com/zeusssz/hercules-obfuscator/blob/main/README.md) would produce. The obfuscator transforms the original code into some kind of `vm` and adds other layers of obfuscation, it's just no fun to reverse.

Normally one would start by resolving comlex expressions to constants, adding a lot of traces to follow the flow etc.. I did something like this in the [`past`](https://github.com/D13David/ctf-writeups/tree/main/googlectf23/rev/zermatt). 

But this time, the program doesn't actually query any input. So we take a wild guess, maybe it's like [`Serpent`](../serpent/README.md), that the script just forgets to print the flag to us?

This is a good start, and another good start is to look at the scripts [`global state`](https://www.lua.org/pil/14.html) after the script ran. To add our diagnostics code to the script, instead of plugging the inner function into the `return` we cache the result in an local.

```lua
-- ...
    return (function(N, f, E, m, d, J, P, T, S, y, j, G, e, k, L, o, c, R, F, K, v, b, u, r, g, i, W)
        -- snip vm code
        -- ...
        return (W(630955 + 12938805, {}))(f(P))
    end)(getfenv and getfenv() or _ENV, unpack or table[X((-394860 - (-807224)) + -430539)], newproxy, setmetatable, getmetatable, select, {...})
end)(...)
```

```lua
-- ...
    local result = (function(N, f, E, m, d, J, P, T, S, y, j, G, e, k, L, o, c, R, F, K, v, b, u, r, g, i, W)
        -- snip vm code
        -- ...
        return (W(630955 + 12938805, {}))(f(P))
    end)(getfenv and getfenv() or _ENV, unpack or table[X((-394860 - (-807224)) + -430539)], newproxy, setmetatable, getmetatable, select, {...})

    -- now we have space to dump the table
    for key, value in pairs(_G) do
        print(value)
    end

    return result
end)(...)
```

Running this gives us the flag.

```bash
$ ./luajit stillmeta.lua | grep CIT
CIT{3aaf345a70fdd27be93d8}
```

Flag `CIT{3aaf345a70fdd27be93d8}`