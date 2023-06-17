# NahamCon 2023

## JNInjaspeak

> We are all very familiar with Leetspeak, can you crack the code on how JNInjaspeak works?
>
>  Author: @matlac#2291
>
> [`jninjaspeak.apk`](jninjaspeak.apk)

Tags: _mobile_

## Solution
Just using strings and filtering for flag leads the flag.

```bash
$ strings jninjaspeak.apk | grep flag
flag{1f539e4a706e6181dae9db3fad6a78f1}covariant return thunk to
flag{1f539e4a706e6181dae9db3fad6a78f1}
flag{1f539e4a706e6181dae9db3fad6a78f1}
flag{1f539e4a706e6181dae9db3fad6a78f1}
```

Flag `flag{1f539e4a706e6181dae9db3fad6a78f1}`