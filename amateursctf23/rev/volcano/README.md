# AmateursCTF 2023

## volcano

> Inspired by recent "traumatic" events.
>
>  Author: flocto
>
> [`volcano`](volcano)

Tags: _rev_

## Solution
The challenge comes with an executable that can be analysed with Ghidra. Ghira gives the following output

```c  
  printf("Give me a bear: ");
  local_d0 = 0;
  __isoc99_scanf(&DAT_00102019,&local_d0);
  cVar1 = FUN_001012bb(local_d0);
  if (cVar1 == '\x01') {
    printf("Give me a volcano: ");
    local_c8 = 0;
    __isoc99_scanf(&DAT_00102019,&local_c8);
    cVar1 = FUN_001013d9(local_c8);
    if (cVar1 == '\x01') {
      printf("Prove to me they are the same: ");
      local_c0 = 0;
      local_b8 = 0x1337;
      __isoc99_scanf(&DAT_00102019,&local_c0);
      if (((local_c0 & 1) == 0) || (local_c0 == 1)) {
        puts("That\'s not a valid proof!");
        uVar2 = 1;
      }
      else {
        lVar3 = FUN_00101209(local_c8);
        lVar4 = FUN_00101209(local_d0);
        if (lVar3 == lVar4) {
          lVar3 = FUN_0010124d(local_c8);
          lVar4 = FUN_0010124d(local_d0);
          if (lVar3 == lVar4) {
            lVar3 = FUN_00101430(local_b8,local_c8,local_c0);
            lVar4 = FUN_00101430(local_b8,local_d0,local_c0);
            if (lVar3 == lVar4) {
              puts("That looks right to me!");
              local_b0 = fopen("flag.txt","r");
              fgets(local_a8,0x80,local_b0);
              puts(local_a8);
              uVar2 = 0;
              goto LAB_00101740;
            }
          }
        }
        puts("Nope that\'s not right!");
        uVar2 = 1;
      }
    }
    else {
      puts("That doesn\'t look like a volcano!");
      uVar2 = 1;
    }
  }
  else {
    puts("That doesn\'t look like a bear!");
    uVar2 = 1;
  }
```

So basically two values need to be provided and there are all sorts of constraints which are checked. First `bear` is checked to fulfill the following constraint. I don't even went deeper into what exactly is tested here, since for constraints `z3` is just perfect.

```c
undefined8 FUN_001012bb(ulong param_1)

{
  undefined8 uVar1;
  
  if ((param_1 & 1) == 0) {
    if (param_1 % 3 == 2) {
      if (param_1 % 5 == 1) {
        if (param_1 + ((param_1 - param_1 / 7 >> 1) + param_1 / 7 >> 2) * -7 == 3) {
          if (param_1 % 0x6d == 0x37) {
            uVar1 = 1;
          }
          else {
            uVar1 = 0;
          }
        }
        else {
          uVar1 = 0;
        }
      }
      else {
        uVar1 = 0;
      }
    }
    else {
      uVar1 = 0;
    }
  }
  else {
    uVar1 = 0;
  }
  return uVar1;
}
```

Then a value for `volcano` is requested and checked against the following constraint. This basically sums the number of `1` bits and does a range check.

```c
undefined8 FUN_001013d9(ulong param_1)

{
  undefined8 uVar1;
  ulong local_18;
  ulong local_10;
  
  local_18 = 0;
  for (local_10 = param_1; local_10 != 0; local_10 = local_10 >> 1) {
    local_18 = local_18 + ((uint)local_10 & 1);
  }
  if (local_18 < 0x11) {
    uVar1 = 0;
  }
  else if (local_18 < 0x1b) {
    uVar1 = 1;
  }
  else {
    uVar1 = 0;
  }
  return uVar1;
}
```

As a next step, a `proof` value is requested that needs to be a even number greater than 1.
```c
printf("Prove to me they are the same: ");
local_c0 = 0;
local_b8 = 0x1337;
__isoc99_scanf(&DAT_00102019,&local_c0);
if (((local_c0 & 1) == 0) || (local_c0 == 1)) {
puts("That\'s not a valid proof!");
uVar2 = 1;
}
```

Then the log10 and checksum is calculated for both `volcano` and `bear` and tested to be idendical.
```c
long FUN_00101209(ulong param_1)
{
  ulong local_20;
  long local_10;
  
  local_10 = 0;
  for (local_20 = param_1; local_20 != 0; local_20 = local_20 / 10) {
    local_10 = local_10 + 1;
  }
  return local_10;
}
```

```c
long FUN_0010124d(ulong param_1)
{
  ulong local_20;
  long local_10;
  
  local_10 = 0;
  for (local_20 = param_1; local_20 != 0; local_20 = local_20 / 10) {
    local_10 = local_10 + local_20 % 10;
  }
  return local_10;
}
```

And finally the `proof` value is used to do some calculation on both `bear` and `volcano` and again, check if the results are identical.

```c
ulong FUN_00101430(ulong _1337,ulong value,ulong proof)
{
  ulong local_28;
  ulong local_20;
  ulong local_10;
  
  local_10 = 1;
  local_20 = _1337 % proof;
  for (local_28 = value; local_28 != 0; local_28 = local_28 >> 1) {
    if ((local_28 & 1) != 0) {
      local_10 = (local_10 * local_20) % proof;
    }
    local_20 = (local_20 * local_20) % proof;
  }
  return local_10;
}
```

Ok, we need fitting candidates, for this bruteforce can be [`used`](volcano.cpp). There are a lot of numbers passing the first few checks. For the proof I choose the smallest working number `3` and indeed got the flag back.

```bash
$ nc amt.rs 31010
Give me a bear: 1048526
Give me a volcano: 1048526
Prove to me they are the same: 3
That looks right to me!

amateursCTF{yep_th0se_l00k_th3_s4me_to_m3!_:clueless:}
```

Flag `amateursCTF{yep_th0se_l00k_th3_s4me_to_m3!_:clueless:}`