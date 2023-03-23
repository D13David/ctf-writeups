# Cyber Apocalypse 2023

## Needle in a Haystack

> You've obtained an ancient alien Datasphere, containing categorized and sorted recordings of every word in the forgotten intergalactic common language. Hidden within it is the password to a tomb, but the sphere has been worn with age and the search function no longer works, only playing random recordings. You don't have time to search through every recording - can you crack it open and extract the answer?
>
>  Author: N/A
>
> [`rev_needle_haystack.zip`](rev_needle_haystack.zip)

Tags: _rev_

## Solution
For this solution one file is delivered. Opening the file in Ghidra and inspecting the `main` function.

```c++
undefined8 main(void)

{
  int iVar1;
  time_t tVar2;
  int local_c;
  
  setbuf(stdout,(char *)0x0);
  printf("Hit enter to select a recording: ");
  getchar();
  tVar2 = time((time_t *)0x0);
  srand((uint)tVar2);
  for (local_c = 0; local_c < 3; local_c = local_c + 1) {
    putchar(0x2e);
    sleep(1);
  }
  iVar1 = rand();
  printf("\"%s\"\n",
         *(undefined8 *)(words + (long)(iVar1 + (int)((ulong)(long)iVar1 / 0xcb) * -0xcb) * 8));
  return 0;
}
```

The program is fairly simple. First it does a small 'processing' animation and then chooses a random word out of a word list. The assumption is that inside the word list the flag might be hidden.

Following the reference to `words` we see a big table of numbers.

```
   00105080 08 30 10        undefine
            00 00 00 
            00 00 10 
    00105080 08              undefined108h                     [0]
    00105081 30              undefined130h                     [1]
    00105082 10              undefined110h                     [2]
    00105083 00              undefined100h                     [3]
    00105084 00              undefined100h                     [4]
    00105085 00              undefined100h                     [5]
    00105086 00              undefined100h                     [6]
    00105087 00              undefined100h                     [7]
    00105088 10              undefined110h                     [8]
    00105089 30              undefined130h                     [9]
    0010508a 10              undefined110h                     [10]
    0010508b 00              undefined100h                     [11]
    0010508c 00              undefined100h                     [12]
    0010508d 00              undefined100h                     [13]
    0010508e 00              undefined100h                     [14]
    ...
```

This is not usefull at all, since Ghidra did not the best job in interpreting the data. After changing the type to `pointer` we see that it's an array of pointers to strings.

```
    001054f0 f5 33 10        addr       s_solguyum_001033f5                         = "solguyum"
                00 00 00 
                00 00
    001054f8 fe 33 10        addr       s_summeg_001033fe                           = "summeg"
                00 00 00 
                00 00
    00105500 05 34 10        addr       s_cyunkro_00103405                          = "cyunkro"
                00 00 00 
                00 00
    00105508 0d 34 10        addr       s_kroucaloc,_0010340d                       = "kroucaloc,"
                00 00 00 
                00 00
    00105510 18 34 10        addr       s_HTB{d1v1ng_1nt0_th3_d4tab4nk5}_00103418   = "HTB{d1v1ng_1nt0_th3_d4tab4nk5}"
                00 00 00 
                00 00
    00105518 37 34 10        addr       s_huarg_00103437                            = "huarg"
                00 00 00 
                00 00
    00105520 3d 34 10        addr       s_voremtc_0010343d                          = "voremtc"
                00 00 00 
                00 00
    00105528 45 34 10        addr       s_glyubyuur_00103445                        = "glyubyuur"
                00 00 00 
                00 00
    00105530 4f 34 10        addr       s_klesalo_0010344f                          = "klesalo"
                00 00 00 
                00 00
```

And somewhere in the middle is also the flag `HTB{d1v1ng_1nt0_th3_d4tab4nk5}`.