# DownUnderCTF 2023

## helpless

> I accidentally set my system shell to the Python help() function! Help!!
> 
> The flag is at /home/ductf/flag.txt.
> 
> The password for the ductf user is ductf.
>
>  Author: hashkitten
>

Tags: _misc_

## Solution
When connecting with `ssh` we end up in Python's help function. As mentioned in the description. After some trial and error I found that we can enter `less` by looking up help for any module.

```
test

Help on package test:

NAME
    test - # Dummy file to make this directory a package.

MODULE REFERENCE
    https://docs.python.org/3.10/library/test.html

    The following documentation is automatically generated from the Python
    source files.  It may be incomplete, incorrect or include features that
    are considered implementation detail and may vary between Python
    implementations.  When in doubt, consult the module reference at the
    location listed above.

PACKAGE CONTENTS
    __main__
    ann_module
    ann_module2
    ann_module3
    libregrtest (package)
    regrtest
    support (package)
    test_support

FILE
    /usr/lib/python3.10/test/__init__.py

(END)
```

When in this mode we can enter `E` to examine files and just pass the file path which gives us the flag.

```
Examine: /home/ductf/flag.txt
```

Flag `DUCTF{sometimes_less_is_more}`