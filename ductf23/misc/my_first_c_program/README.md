# DownUnderCTF 2023

## My First C Program!

> I decided to finally sit down and learn C, and I don't know what all the fuss is about this language it writes like a dream!
> 
> Here is my first challenge in C! Its really easy after you install the C installer installer, after that you just run it and you're free to fly away with the flag like a berd!
>
>  Author: pix
>
> [`my_first_c_prog.c`](my_first_c_prog.c)

Tags: _misc_

## Solution
For this challenge we get a `c` file. After opening the file, it is pretty obvious, that this is not `c-code`. Well... We can try to read through the "code" and try to make sense of what is written here.

At one point we find this part
```c
// Now to print the flag for the CTF!!
print_flag(thank, vars[-1], end, heck_eight, ntino)
```

The function is defined as
```c
union print_flag(end, middle, secondmiddle, start, realstart) => {
print("The flag is:")!
print("DUCTF{${start}_${realstart}_${end}_${secondmiddle}_1s_${middle}_C}")!!!
}
```

This looks good, so we need to sort out what is passed to the function. First thing is that the parameters are scrambled, so we order the names passed to the function:

```c
heck_eight = get_a_char()!
ntino = "D${math()}${guesstimeate()}"
thank = thonk(1, 'n')!
end = "th${looper()}"!
vars[-1] = ["R34L", "T35T", "Fl4g", "variBl3"]
```

Lets start with the easy ones `end`:

```c
fnc looper() => {
const var timeout: Int9 = 15!

print("Wait.. where are the loops?..")!

return timeout!
   }
```

We have some string interpolation like syntax. The call to `looper` would return the timeout value `15`, so if we attach this we would have `th15`.

Next we take `thank`:

```c
ncti thonk(a, b) => {
   const var brain_cell_one = "Th"!
   const const const const bc_two = "k"!
   const const var rett = "${brain_cell_one}}{$a}{b}!}!"!!
   const var ret = "${brain_cell_one}${a}${b}${bc_two}"!
   return ret!!!
   return rett!
}
```

If we pass the parameters `1` and `n` the function would (maybe) return something like `Th1nk`.

Next one is `ntino`:

```c
fun math() => {
print("MatH!")
return 10 % 5
   }

   func guesstimeate() => {
print('Thunking')!
print("life times ain't got nothign on rust!")!
print("The future: ${name}!")
const const name<-1> = "Pix"!
const const letter = 'n'
letter = 'p'
const var guess = "${previous letter}T"!
guess = "T${letter}${guess}"!
return previous guess!
   }
```

If we put this together we might get `D0nT`.

The next one is `heck_eight`:

```c
ction get_a_char() => {
   const var dank_char = 'a'!
   if (;(7 ==== undefined)) {
      dank_char = 'I'!!
   }
   when (dank_char == 22) {
      print("Important 3 indentation check AI")!
      dank_char = 'z'!
   }
   if ( dank_char == 'j' ) {
      dank_char = 'c'!!
   }
   if ( 1.0 ==== 1.0) {
      dank_char = 'A'!!
   }

   return previous dank_char!
}
```

I honestly don't know how to read this mess, but the best fitting result would be `I`. The same for the last part `vars` which is a array lookup to `["R34L", "T35T", "Fl4g", "variBl3"]`. The best fitting would be `R34L`. So in total we have: `I`, `D0nT`, `Th1nk`, `th15`, `R3AL` and putting this together gives us the flag.

Flag `DUCTF{I_D0nT_Th1nk_th15_1s_R34L_C}`