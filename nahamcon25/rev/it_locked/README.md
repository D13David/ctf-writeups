# NahamCon 2025

## It's Locked

> This bin looks locked as a crypt to me, but I'm sure you can work some magic here.
> All I know is that this came from a machine with a cryptic ID of just 'hello'.
>
>  Author: @Kkevsterrr
>
> [`flag.sh`](flag.sh)

Tags: _rev_

## Solution
This challenge came with a heavily obfuscated `shell script`. The script contains a lot of unprintable bytes making it hard to see a proper structure. By closer inspection one can see some readable parts. 

```bash
eval`:||` "`:||`$(`:||`ec`#`ho `:||`...
```

We can see some command chunks in backticks. The commands evaluated (`:||`) are doing nothing as the null command `:` always succeeds and the right hand side of the logical or `||` is skipped due to short circuit. So these chunks are only there for obfuscation noise. Grabbing the readable parts and removing the chunks we get.

```bash
eval "$(echo ü³X2¢ÁJjbF9...[snip]...|LANG=C perl -pe "s/[^[:print:]]//g"|openssl base64 -A -d)"
```

The whole part in the middle is basically ran through a perl script that removes all non printable characters and then `openssl` is used to `base64` decode the result. It's not too far fetched to assume therefore, the block in the middle is some obfuscated `base64` encoded data. To retrieve it we copy to a file and clean up the data ourself (cyperchef, script, you name it...).

After decoding the `base64` payload we get [`the following result`](payload.sh), which is another `shell script` that is evaluated by `flag.sh`.

The code is not too bad, yet not super well structured. But let's walk through it step by step.

The first thing the script does, is to define some values. We probably need those later.

```bash
BCL='aWQgLXUK'
BCV='93iNKe0zcKfgfSwQoHYdJbWGu4Dfnw5ZZ5a3ld5UEqI='
P=llLvO8+J6gmLlp964bcJG3I3mY27I9ACsJTvXYCZv2Q=
S='lRwuwaugBEhK488I'
C=3eOcpOICWx5iy2UuoJS9gQ==
```

Then the script checks for three commands to be available on the machine running the script. If either `openssl`, `perl` or `gunzip` is missing the script will error out.

Then the script initialized `fn` to the calling script path, whenever the payload is sourced. In our case it is not, so `fn` will stay empty as `BC_FN` is also nowhere set. The same also for `XS` which will stay empty as there is no `command argument to the -c invocation option.`.

Finally the program checks if either `fn` or `XS` is defined or if the name of the script references a existing, regular file. If none of the conditions apply the script errors out. 

```bash
for x in openssl perl gunzip; do
    command -v "$x" >/dev/null || { echo >&2 "ERROR: Command not found: $x"; return 255; }
done
unset fn _err
if [ -n "$ZSH_VERSION" ]; then
    [ "$ZSH_EVAL_CONTEXT" != "${ZSH_EVAL_CONTEXT%":file:"*}" ] && fn="$0"
elif [ -n "$BASH_VERSION" ]; then
    (return 0 2>/dev/null) && fn="${BASH_SOURCE[0]}"
fi
fn="${BC_FN:-$fn}"
XS="${BASH_EXECUTION_STRING:-$ZSH_EXECUTION_STRING}"
[ -z "$XS" ] && unset XS
[ -z "$fn" ] && [ -z "$XS" ] && [ ! -f "$0" ] && {
    echo >&2 'ERROR: Shell not supported. Try "BC_FN=FileName source FileName"'
    _err=1
}
```

Next the script checks if `_err` was set before, if not it runs function `_bc_dec` by forwarding all the parameters; and afterwards does some cleanup.

```bash
[ -z "$_err" ] && _bc_dec "$@"
unset fn
unset -f _bc_dec
if [ -n "$_err" ]; then
    unset _err
    false
else
    true
fi
```

Let's have some look at `_bc_dec`. First of, `_P` is set to either `PASSWORD` or (of not defined) `BC_PASSWORD`. We don't have either of both, so `_P` stays empty fo the moment.

Then the program checks if `P` (no leading underscore) is present (which we saw already being initialized to `llLvO8+J6gmLlp964bcJG3I3mY27I9ACsJTvXYCZv2Q=`). In this branch also `BCV` and `BCL` are given, so the script calls to `bcl_gen_p`. The other branches (decoding `P` as base64 encoded input or prompting user input) are not relevant in our context.

```bash
_P="${PASSWORD:-$BC_PASSWORD}"
unset _ PASSWORD 
if [ -n "$P" ]; then
    if [ -n "$BCV" ] && [ -n "$BCL" ]; then
        _bcl_gen_p "$P" || return
    else
        _P="$(echo "$P"|openssl base64 -A -d)"
    fi
else
    [ -z "$_P" ] && {
        echo >&2 -n "Enter password: "
        read -r _P
    }
fi
```

Function `_bcl_gen_p` is rather lengthy. If `BC_BCL_TEST_FAIL` is not set the function initializes `_P` by decoding the input (which was the value of `P`) with AES-256-CBC and `_k` as `key`. 

If `_P` is set, the function will early out, so the remaining part we can probably just skip.

```bash
_bcl_gen_p () 
{ 
    local _k;
    local str;
    [ -z "$BC_BCL_TEST_FAIL" ] && _k="$(_bcl_get)" && _P="$(echo "$1" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "$_k" -a -A 2> /dev/null)";
    [ -n "$_P" ] && return 0;
    [ -n "$fn" ] && { 
        unset BCL BCV _P P S fn;
        unset -f _bcl_get _bcl_verify _bcl_verify_dec;
        return 255
    };
    BCL="$(echo "$BCL" | openssl base64 -d -A 2> /dev/null)";
    [ "$BCL" -eq "$BCL" ] 2> /dev/null && exit "$BCL";
    str="$(echo "$BCL" | openssl base64 -d -A 2> /dev/null)";
    BCL="${str:-$BCL}";
    exec /bin/sh -c "$BCL";
    exit 255
}
```

We only need the `key` and we know it's coming from `_bcl_get`. Inspecting the function, we see it set's `UID` to the current users id, and then walks through a whole list of potential data sources that are used to build up the key. The verify is done in `_bcl_verify_dec` and we can see the key has the format `<some-value>-<userid>`.

Recalling the challenge description `All I know is that this came from a machine with a cryptic ID of just 'hello'` we might guess the first part of the key is the machine ID, as one of the sources which are verified is `/etc/machine-id`. 

```bash
_bcl_verify_dec () 
{ 
    [ "TEST-VALUE-VERIFY" != "$(echo "$BCV" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "B-${1}-${UID}" -a -A 2> /dev/null)" ] && return 255;
    echo "$1-${UID}"
}
_bcl_verify() { _bcl_verify_dec "$@"; }
_bcl_get () 
{ 
    [ -z "$UID" ] && UID="$(id -u 2> /dev/null)";
    [ -f "/etc/machine-id" ] && _bcl_verify "$(cat "/etc/machine-id" 2> /dev/null)" && return;
    command -v dmidecode > /dev/null && _bcl_verify "$(dmidecode -t 1 2> /dev/null | LANG=C perl -ne '/UUID/ && print && exit')" && return;
    _bcl_verify "$({ ip l sh dev "$(LANG=C ip route show match 1.1.1.1 | perl -ne 's/.*dev ([^ ]*) .*/\1/ && print && exit')" | LANG=C perl -ne 'print if /ether / && s/.*ether ([^ ]*).*/\1/'; } 2> /dev/null)" && return;
    _bcl_verify "$({ blkid -o export | LANG=C perl -ne '/^UUID/ && s/[^[:alnum:]]//g && print && exit'; } 2> /dev/null)" && return;
    _bcl_verify "$({ fdisk -l | LANG=C perl -ne '/identifier/i && s/[^[:alnum:]]//g && print && exit'; } 2> /dev/null)" && return
}
```

The verification decrypts the value of `BCV` with the key `B-hello-<userid>`, so we can just bruteforce a valid user id.

```bash
#!/bin/bash

BCV='93iNKe0zcKfgfSwQoHYdJbWGu4Dfnw5ZZ5a3ld5UEqI='

_bcl_verify_dec () {
    local decrypted
    decrypted=$(echo "$BCV" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "B-${1}-${2}" -a -A 2>/dev/null | tr -d '\0')
    if [ "TEST-VALUE-VERIFY" == "$decrypted" ]; then
        return 0
    fi
    return 255
}

for uid in $(seq 0 65535); do
    if _bcl_verify_dec "hello" "$uid"; then
        echo "Match found with UID: $uid"
        break
    fi
done
```

We find a match for user id `1338`. With this, we know the key to be `hello-1338` and we can continue to decrypt our password.

```bash
$ echo "llLvO8+J6gmLlp964bcJG3I3mY27I9ACsJTvXYCZv2Q=" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "hello-1338" -a -A 2> /dev/null
QHh4K9JfgoACd2f4
```

Perfect, let's continue with `_bc_dec`. If `C` is given (which has value `3eOcpOICWx5iy2UuoJS9gQ==` in our case here) the script decrypts the value with a key `C-<S>-<_P>`. As we now have both `S` and `_P` we just can decrypt this part.

```bash
[ -n "$C" ] && {
    local str
    str="$(echo "$C" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "C-${S}-${_P}" -a -A 2>/dev/null)"
    unset C
    [ -z "$str" ] && {
        [ -n "$BCL" ] && echo >&2 "ERROR: Decryption failed."
        return 255
    }
    eval "$str"
    unset str
}
``` 

```bash
$ echo "3eOcpOICWx5iy2UuoJS9gQ==" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "C-lRwuwaugBEhK488I-QHh4K9JfgoAC
d2f4" -a -A 2>/dev/null
R=2105
```

The result is `R=2105` and the string is passed through `eval` setting `R` to `2105`.

The final three blocks are essentially doing the same thing but based on the presence of `XS` and `fn`. This is the whole part, it's not very readable, so let's first clean this up a bit.

```bash
eval "unset _P S R fn;$(LANG=C perl -e '<>;<>;read(STDIN,$_,1);while(<>){s/B3/\n/g;s/B1/\x00/g;s/B2/B/g;print}'<"${fn}"|openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "${S}-${_P}" 2>/dev/null|LANG=C perl -e "read(STDIN,\$_, ${R:-0});print(<>)"|gunzip)"
```

First a perl script is executed. The script file name is redirected as input, so the perl script skips the two first lines plus one byte of `flag.sh` and then prints the remaining bytes and replacing `B3` with `\n`, `B1` with `\x00` and `B2` with `B`.

```perl
<>;
<>;
read(STDIN,$_,1);
while(<>) {
    s/B3/\n/g;
    s/B1/\x00/g;
    s/B2/B/g;
    print
}
```

The output is piped to `openssl` and yet again decrypted with the key `<S>-<_P>`. Then the decrypted result is piped into another perl script. This script skips the first `2105` bytes of the input stream (remember, R was initializes with 2105 before) and this result is again piped and decompressed with `gunzip`.

Replacing the variables `fn`, `S`, `_P` and `R` we get this command:

```bash
perl -e '<>;<>;read(STDIN,$_,1);while(<>){s/B3/\n/g;s/B1/\x00/g;s/B2/B/g;print}' < flag.sh |  openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "lRwuwaugBEhK488I-QHh4K9JfgoACd2f4" 2>/dev/null | perl -e 'read(STDIN,$_, 2105);print(<>)' | gunzip
```

Running it gives us gives us yet another payload that would be put into `eval` and with it the flag.

```bash
echo "flag{f2ea4caf879bde891f0174f528c20682}"
echo "Congraulations!"
`

Flag `flag{f2ea4caf879bde891f0174f528c20682}`