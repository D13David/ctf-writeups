# NahamCon 2023

## Fetch

> "Gretchen, stop trying to make fetch happen! It's not going to happen!" - Regina George
>
>  Author: @JohnHammond#6971
>
> [`fetch.7z`](fetch.7z)

Tags: _forensics_

## Solution
Extracting the 7z file leads another file called `fetch`. Inspecting with file command

```bash
$ file fetch
fetch: Windows imaging (WIM) image v1.13, XPRESS compressed, reparse point fixup
```

This can also extracted with `7z`. A whole lot of windows prefetch files are extracted. To investigate [PECmd](https://github.com/EricZimmerman/PECmd) can be used. Downloading the latest release, combiling and running it on the dump directory leads loads of output. To filter this, grep for flag:

```bash
$ ./PECmd.exe -d dump/ | grep -i flag
061: \VOLUME{01d89fa75d2a9f57-245d3454}\USERS\LOCAL_ADMIN\DESKTOP\FLAG{97F33C9783C21DF85D79D613B0B258BD}
```

Flag `FLAG{97F33C9783C21DF85D79D613B0B258BD}`