# LACTF 2023

## aplet321

> Unlike Aplet123, Aplet321 might give you the flag if you beg him enough.
> 
> Author: kaiphait
> 
> [`Dockerfile`](Dockerfile)
> [`aplet321`](aplet321)

Tags: _rev_

## Solution
Opening the given binary in `Ghidra` gives the following small `main` function.

```c++
undefined8 main(void)
{
  int iVar1;
  size_t sVar2;
  char *pcVar3;
  int iVar4;
  int iVar5;
  char local_238;
  char acStack_237 [519];
  
  setbuf(stdout,(char *)0x0);
  puts("hi, i\'m aplet321. how can i help?");
  fgets(&local_238,0x200,stdin);
  sVar2 = strlen(&local_238);
  if (5 < sVar2) {
    iVar4 = 0;
    iVar5 = 0;
    pcVar3 = &local_238;
    do {
      iVar1 = strncmp(pcVar3,"pretty",6);
      iVar5 = iVar5 + (uint)(iVar1 == 0);
      iVar1 = strncmp(pcVar3,"please",6);
      iVar4 = iVar4 + (uint)(iVar1 == 0);
      pcVar3 = pcVar3 + 1;
    } while (pcVar3 != acStack_237 + ((int)sVar2 - 6));
    if (iVar4 != 0) {
      pcVar3 = strstr(&local_238,"flag");
      if (pcVar3 == (char *)0x0) {
        puts("sorry, i didn\'t understand what you mean");
        return 0;
      }
      if ((iVar5 + iVar4 == 0x36) && (iVar5 - iVar4 == -0x18)) {
        puts("ok here\'s your flag");
        system("cat flag.txt");
        return 0;
      }
      puts("sorry, i\'m not allowed to do that");
      return 0;
    }
  }
  puts("so rude");
  return 0;
}
```

Here the user is prompted to input a string. Then there's some processing and two integer values are computed.

```c++
do {
      iVar1 = strncmp(pcVar3,"pretty",6);
      iVar5 = iVar5 + (uint)(iVar1 == 0);
      iVar1 = strncmp(pcVar3,"please",6);
      iVar4 = iVar4 + (uint)(iVar1 == 0);
      pcVar3 = pcVar3 + 1;
    } while (pcVar3 != acStack_237 + ((int)sVar2 - 6));
```

This basically scans the user input for the number of `pretty` and `please` occurrences within the string. If at least one `please` is present the program checks if the substring `flag` is also given. In any other case error messages are printed.

```c++
if (iVar4 != 0) {
      pcVar3 = strstr(&local_238,"flag");
      if (pcVar3 == (char *)0x0) {
        puts("sorry, i didn\'t understand what you mean");
        return 0;
      }
// ...
```

The next part is the interesting part, here `flag.txt` is read by the server and printed to us. The condition that needs to be fulfilled is `iVar5 + iVar4 == 54` and `iVar5 - iVar4 == -24`. Now iVar5 is the number of `pretty` occurrences and iVar4 is the number of `please` occurrences.

```c++
if ((iVar5 + iVar4 == 0x36) && (iVar5 - iVar4 == -0x18)) {
        puts("ok here\'s your flag");
        system("cat flag.txt");
        return 0;
      }
```

Its easy to see that we need `15` times pretty and `39` times please (`15+39 = 54`, `15-39=-24`). With this, we can quickly generate a fitting input string to get the flag.

```bash
$ python -c "print('pretty'*15+'please'*39+'flag')" | nc chall.lac.tf 31321
hi, i'm aplet321. how can i help?
ok here's your flag
lactf{next_year_i'll_make_aplet456_hqp3c1a7bip5bmnc}
```

Flag `lactf{next_year_i'll_make_aplet456_hqp3c1a7bip5bmnc}`