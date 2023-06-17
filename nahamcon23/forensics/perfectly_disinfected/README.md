# NahamCon 2023

## Perfectly Disinfected

> Ever had to deal with dirty files? No more! Our patented technology will make your files sparkling clean! Sample included.
>
>  Author: @NightWolf#0268
>
> [`clean_document.pdf`](clean_document.pdf)

Tags: _forensics_

## Solution
Just dumping the file content will reveal the flag:

```bash
$ cat clean_document.pdf
...
/Title (��flag{b00acdc78749b378f8f4889f8243789304abe928})
...
```
Flag `flag{b00acdc78749b378f8f4889f8243789304abe928}`