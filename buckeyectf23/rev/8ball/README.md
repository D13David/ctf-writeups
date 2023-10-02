# BuckeyeCTF 2023

## 8ball

> Let me guide you to the flag.
>
>  Author: rene
>
> [`dist.zip`](dist.zip)

Tags: _rev_

## Solution
For this challenge we get a binary to reverse. Opening it with [`dogbolt``](https://dogbolt.org/) gives us this main (here via Hex-Rays):

```c
int __fastcall main(int argc, const char **argv, const char **envp)
{
  unsigned int v3; // eax
  char *s[41]; // [rsp+10h] [rbp-160h] BYREF
  int v6; // [rsp+15Ch] [rbp-14h]
  __int64 v7; // [rsp+160h] [rbp-10h]
  int v8; // [rsp+16Ch] [rbp-4h]

  setvbuf(stdout, 0LL, 2, 0LL);
  v3 = time(0LL);
  srand(v3);
  if ( argc != 2 )
  {
    puts("Every question has answer... if you know how to ask");
    printf("Go ahead, ask me anything.\n");
    exit(0);
  }
  v8 = 0;
  if ( !strcmp(*argv, "./magic8ball") )
  {
    puts("Why, I guess you're right... I am magic :D");
    v8 = 1;
  }
  qmemcpy(s, off_4024A0, 0x140uLL);
  puts("You asked:");
  msleep();
  printf("\"%s\"\n", argv[1]);
  msleep();
  printf("Hmmm");
  msleep();
  putchar(46);
  msleep();
  putchar(46);
  msleep();
  putchar(46);
  msleep();
  puts(".");
  msleep();
  if ( v8 && strstr(argv[1], "flag") )
  {
    puts("Why yes, here is your flag!");
    print_flag();
  }
  else
  {
    v7 = 40LL;
    v6 = rand() % 0x28uLL;
    puts(s[v6]);
  }
  return 0;
}
```

We need at least one argument otherwise the program immediately terminates. If we are moving on a bit, we can se that the program checks if the first passed argument contains the string `flag` and then prints the flag. But doing so will still not print the flag? We can note that there is a second condition `v8` needs to have a `true` value, and this only is set when the filename of the executed binary is `magic8ball` (the name is passed as argb[0] automatically). So we rename the file from `8ball` to `magic8ball` and call again with a string containing `flag` to get the flag.

```bash
$ mv 8ball magic8ball
$ ./magic8ball hmmmflag??
Why, I guess you're right... I am magic :D
You asked:
"hmmmflag??"
Hmmm....
Why yes, here is your flag!
bctf{Aw_$hucK$_Y0ur3_m@k1Ng_m3_bLu$h}
```

Flag `bctf{Aw_$hucK$_Y0ur3_m@k1Ng_m3_bLu$h}`