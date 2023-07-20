# AmateursCTF 2023

## funny factorials

> bryanguo (not associated with the ctf), keeps saying it's pronouced latek not latex like the glove material. anyways i made this simple app so he stops paying for overleaf.
>
>  Author: smashmaster
>

Tags: _web_

## Solution
For this challenge there is a little Latex editor given. The user can input Latex and the application compiles the input into a pdf. Appart from this there is no input, so research needs to be done. There is a nice [`cheatsheet`](https://salmonsec.com/cheatsheets/exploitation/latex_injection) covering various Latex injection payloads. Most of them do not work, but the `verbatimeinput` is compiled successfully.

```latex
\usepackage{verbatim}
\verbatiminput{/etc/passwd}
```

Passing `\verbatiminput{flag.txt}` gives some output, but certainly not the flag:

```
foo 1
foo 2
\textbf{foo 3}
```

In other challenges the `flag.txt` was at the root, so trying this `\verbatiminput{/flag.txt}` happily compiles the flag into the [`pdf`](flag.pdf).

Flag `amateursCTF{th3_l0w_budg3t_and_n0_1nstanc3ing_caus3d_us_t0_n0t_all0w_rc3_sadly}`