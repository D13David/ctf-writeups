# OS CTF 2024

## Avengers Assemble

> The Avengers have assembled but for what? To solve this!? Why call Avengers for such a simple thing, when you can solve it yourself
> 
> FLAG FORMAT: OSCTF{Inp1_Inp2_Inp3} (Integer values)
>
>  Author: @Inv1s1bl3
>
> [`code.asm`](code.asm)

Tags: _rev_

## Solution
This challenge comes with a short assembler listing and is mostly about reading/understanding the source code. The full listing is [`here`](code.asm), lets quickly dissect it.

```js
asm
extern printf
extern scanf
```

This first part links two external functions (`printf` and `scanf`) to the module, for later use.

```js
section .data
        fmt: db "%ld",0
        output: db "Correct",10,0
        out: db "Not Correct",10,0
        inp1: db "Input 1st number:",0
        inp2: db "Input 2nd number:",0
        inp3: db "Input 3rd number:",0
```

Next up comes the data section where structured data is defined. The code defines a few byte arrays, all terminated with a `null` byte, so probably ment to be used as strings for display etc..

```js
section .text
        global main
```

Next comes the text (or code) section where the executable instructions are contained. First symbol `main` is exported from the module.

```js 
        main:
        push ebp
        mov ebp,esp
        sub esp,0x20
```

Then the main function starts with setting up the stack. This is a rather typical preamble. The base pointer (which typically points to the previous stack frame) is saved and redirected to the current stack position. Then a certain amount is reserved on the stack, by decrementing the stack pointer. Here `32 bytes` are reserved on the stack for the function.
 
```js
        push inp1
        call printf
        lea eax,[ebp-0x4]
        push eax
        push fmt
        call scanf

        push inp2
        call printf
        lea eax,[ebp-0xc]
        push eax
        push fmt
        call scanf

        push inp3
        call printf
        lea eax,[ebp-0x14]
        push eax
        push fmt
        call scanf
```

The following three blocks have all the same logic. A message is printed (`Input 1st number:`, ...) and then user scanf is called (with `%ld`) and lets the user enter a long double value. The values are written at offsets `ebp-4`, `ebp-12` and `ebp-20` to the stack. So our stack should look something like this (we expect long decimal to be 32 bit integer values).

```bash
+-----------------------+ 
|                       | ESP
|                       |
/       ...snip         /
|                       |
|                       | EBP-20
|Number3 Number3 Number3|
|Number3 Number3 Number3|
|Number3 Number3 Number3|
|Number3 Number3 Number3| EBP-16
|                       |
|                       |
|                       |
|                       | EBP-12
|Number2 Number2 Number2|
|Number2 Number2 Number2|
|Number2 Number2 Number2|
|Number2 Number2 Number2| EBP-8
|                       |
|                       |
|                       |
|                       | EBP-4
|Number1 Number1 Number1|
|Number1 Number1 Number1|
|Number1 Number1 Number1| 
|Number1 Number1 Number1| EBP
+-----------------------+ 
```

```js
        mov ebx, DWORD[ebp-0xc]
        add ebx, DWORD[ebp-0x4]
        cmp ebx,0xdeadbeef
        jne N
```

Afterwards the values are checked to fulfil certain criteria. The code reads value 2 and value 3, adds them and compares against `0xdeadbeef`. This means: `value1 + value2 == 0xdeadbeef`.

```js
        cmp DWORD[ebp-0x4], 0x6f56df65
        jg N
```

The second part checks value 1 to be smaller or equal to `0x6f56df65`. 

```js
        cmp DWORD[ebp-0xc], 0x6f56df8d
        jg N
        cmp DWORD[ebp-0xc], 0x6f56df8d
        jl N
```

The third part checks value 2 to be smaller or equal to `0x6f56df8d` and larger or equal to `0x6f56df8d`. This is a complicated expression to say, value2 == 0x6f56df8d.

```js
        mov ecx, DWORD[ebp-0x14]
        mov ebx, DWORD[ebp-0xc]
        xor ecx, ebx
        cmp ecx, 2103609845
        jne N
        jmp O
```

And finally the last part calculates a xor of value 2 and value 3 and tests if the result is `2103609845`. If all tests succeeded the code jumps to label `O`.

```js
        N:
        push out
        call printf
        leave
        ret

        O:
        push output
        call printf

        leave
        ret
```

The last part of the code is for outputting response. Label `N` marks the part where a fail message is printed (`Not Correct`), label `O` prints a succeed message (`Correct`). In both cases the program is terminated afterwards.

So, we have the following requirements for our three inputs.

```bash
value1 + value2 == 0xdeadbeef
value1 >= 0x6f56df65
value2 == 0x6f56df8d
value2 ^ value3 == 2103609845
```

The value of `value2` we already have (`1867964301`). So calculating the rest is trivial, `value1 = 0xdeadbeef - 1867964301`, therefore `value1` will be `1867964258` and `value3 = 2103609845 ^ value2` so `value3` is `305419896`. Stitching this together gives us the flag.

Flag `OSCTF{1867964258_1867964301_305419896}`