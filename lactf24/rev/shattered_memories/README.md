# LACTF 2023

## shattered-memories

> I swear I knew what the flag was but I can't seem to remember it anymore... can you dig it out from my inner psyche?
> 
> Author: aplet123
> 
> [`shattered-memories`](shattered-memories)

Tags: _rev_

## Solution
Inspecting the given binary with Ghidra gives a fairly small `main` function to look at. The user is prompted for input, then the input is checked to be of length `40`. Afterwards a various parts of the input are compared to strings and for each comparison a counter is increased. If the counter hits value `5` we get the message `Yes! That's it! That's the flag! I remember now!`. 

To retrieve the flag all comparisons need to succeed, the only thing to do is, to sort the parts and concatinate them to get the flag.

```c++
undefined8 main(void)
{
  int iVar1;
  size_t sVar2;
  undefined8 uVar3;
  char local_98 [8];
  char acStack_90 [8];
  char acStack_88 [8];
  char acStack_80 [8];
  char acStack_78 [108];
  int local_c;
  
  puts("What was the flag again?");
  fgets(local_98,0x80,stdin);
  strip_newline(local_98);
  sVar2 = strlen(local_98);
  if (sVar2 == 0x28) {
    local_c = 0;
    iVar1 = strncmp(acStack_90,"t_what_f",8);
    local_c = local_c + (uint)(iVar1 == 0);
    iVar1 = strncmp(acStack_78,"t_means}",8);
    local_c = local_c + (uint)(iVar1 == 0);
    iVar1 = strncmp(acStack_80,"nd_forge",8);
    local_c = local_c + (uint)(iVar1 == 0);
    iVar1 = strncmp(local_98,"lactf{no",8);
    local_c = local_c + (uint)(iVar1 == 0);
    iVar1 = strncmp(acStack_88,"orgive_a",8);
    local_c = local_c + (uint)(iVar1 == 0);
    switch(local_c) {
    case 0:
      puts("No, that definitely isn\'t it.");
      uVar3 = 1;
      break;
    case 1:
      puts("I\'m pretty sure that isn\'t it.");
      uVar3 = 1;
      break;
    case 2:
      puts("I don\'t think that\'s it...");
      uVar3 = 1;
      break;
    case 3:
      puts("I think it\'s something like that but not quite...");
      uVar3 = 1;
      break;
    case 4:
      puts("There\'s something so slightly off but I can\'t quite put my finger on it...");
      uVar3 = 1;
      break;
    case 5:
      puts("Yes! That\'s it! That\'s the flag! I remember now!");
      uVar3 = 0;
      break;
    default:
      uVar3 = 0;
    }
  }
  else {
    puts("No, I definitely remember it being a different length...");
    uVar3 = 1;
  }
  return uVar3;
}
```

Flag `lactf{not_what_forgive_and_forget_means}`