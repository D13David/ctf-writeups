# CyberHeroines 2023

## Anita Borg

> [Anita Borg](https://cyberheroines.ctfd.io/challenges) (January 17, 1949 – April 6, 2003) was an American computer scientist celebrated for advocating for women’s representation and professional advancement in technology. She founded the Institute for Women and Technology and the Grace Hopper Celebration of Women in Computing. - [Wikipeda Entry](https://en.wikipedia.org/wiki/Anita_Borg)
> 
> Chal: Have the vision to solve this binary and learn more about this [visionary](https://www.youtube.com/watch?v=qMfELzvXpBo)
>
>  Author: [TJ](https://www.tjoconnor.org/)
>
> [`fLag_TRACE`](fLag_TRACE)

Tags: _rev_

## Solution
The challenge binary given is [`movfuscated`](https://github.com/Battelle/movfuscator) meaning the binary only uses `mov` instructions. This works since `mov` turned out to be [`turing complete`](https://stackoverflow.com/questions/61048788/why-is-mov-turing-complete) but makes analysing it complicated.

One of the easier things to check out is running the application through `strace` or `ltrace` and then there is the subtle hint in the filename to use `ltrace`. By doing this we get the flag.

```bash
$ ltrace ./fLag_TRACE
sigaction(SIGSEGV, { 0x8049070, <>, 0, 0 }, nil)                          = 0
sigaction(SIGILL, { 0x80490f7, <>, 0, 0 }, nil)                           = 0
--- SIGSEGV (Segmentation fault) ---
printf("                                "...

)                             = 81
--- SIGSEGV (Segmentation fault) ---
printf("   WXKXNW                       "...   WXKXNW

)
...
strncmp("asdasdasdasdasdasdasd\n\322\367chctf{b_"..., "chctf{b_A_V1s10NArY_2}", 22) = -1
--- SIGSEGV (Segmentation fault) ---
printf(" <<< Keep trying and believe in "...)                             = 41
--- SIGILL (Illegal instruction) ---
--- SIGSEGV (Segmentation fault) ---
exit(1 <<< Keep trying and believe in yourself. <no return ...>
+++ exited (status 1) +++
```

Flag `chctf{b_A_V1s10NArY_2}`