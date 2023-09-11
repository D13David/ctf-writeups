# CyberHeroines 2023

## Mary Combs

> [Mary Clare Coombs](https://en.wikipedia.org/wiki/Mary_Coombs) (née Blood, 4 February 1929 – 28 February 2022) was a British computer programmer and schoolteacher. Employed in 1952 as the first female programmer to work on the LEO computers, she is recognised as the first female commercial programmer. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Mary_Coombs)
> 
> Chal: Mary Combs was the [first to program the LEO Computer](https://www.youtube.com/watch?v=C6DRr0Dhn4Q) used for accounting, stock, and cost control. Inspire her with your best symbolic execution to solve this math-filled binary.
>
>  Author: [TJ](https://www.tjoconnor.org/)
>
> [`mary`](mary)

Tags: _rev_

## Solution
For this challenge we get a stripped binary. Opening it in `Ghidra` we start at the `entry` function to find the `main` (first parameter in `__libc_start_main`).

```c
undefined8 main(void)
{
  long lVar1;
  long in_FS_OFFSET;
  
  lVar1 = *(long *)(in_FS_OFFSET + 0x28);
  signal(0xe,FUN_00401240);
  alarm(0x1e);
  FUN_00401273();
  FUN_00401754();
  if (lVar1 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

The main is very short. `FUN_00401273` is printing a banner. The interesting part is in `FUN_00401754` (we call it `printFlag`).

```c
void printFlag(void)
{
  long lVar1;
  int iVar2;
  int iVar3;
  time_t tVar4;
  long in_FS_OFFSET;
  int local_1c;
  
  lVar1 = *(long *)(in_FS_OFFSET + 0x28);
  tVar4 = time((time_t *)0x0);
  srand((uint)tVar4);
  for (local_1c = 1; local_1c < 100; local_1c = local_1c + 1) {
    iVar2 = rand();
    iVar3 = rand();
    FUN_0040167a(iVar2,iVar3,local_1c);
  }
  system("cat flag.txt");
  if (lVar1 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return;
}
```

Here a loop runs `99` times doing something. Afterwards the flag is printed. We beatify this on our way a bit for better readability.

```c
  for (i = 1; i < 100; i = i + 1) {
    random_val1 = rand();
    random_val2 = rand();
    FUN_0040167a(random_val1,random_val2,i);
  }
```

Lets have a look at `FUN_0040167a`. The function prints both random values and then the user can input a integer value. Four values (random values, counter and user input) are passed to another function and the result is checked. If the result does not equal `1337` a `incorrect` message is printed and the program exits. We can call this function maybe `printValuesAndUserInput`

```c
void FUN_0040167a(uint random_val1,uint random_val2,undefined4 counter)

{
  int iVar1;
  long in_FS_OFFSET;
  undefined4 userInput;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  printf("Random 1 >>> %i\n",(ulong)random_val1);
  printf("Random 2 >>> %i\n",(ulong)random_val2);
  printf("Your Response >>> ");
  __isoc99_scanf(&DAT_00402c85,&userInput);
  iVar1 = FUN_00401526(random_val1,random_val2,counter,userInput);
  if (iVar1 != 1337) {
    puts("<<< Incorrect. Exiting");
                    /* WARNING: Subroutine does not return */
    exit(0);
  }
  puts("<<< Correct. Continuing");
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return;
}
```

`FUN_00401526` does some equations based on the modulo-10 of the current counter value and returns the result. Since we know that the result is expected to be `1337` we can reorder the equations for `userInput` to calculate the correct values.

```c
int FUN_00401526(int random_val1,int random_val2,int counter,int userInput)
{
  long in_FS_OFFSET;
  
  switch(counter % 10) {
  case 0:
    userInput = userInput + (random_val1 - random_val2) + counter;
    break;
  case 1:
    userInput = (counter + random_val1 + random_val2) - userInput;
    break;
  case 2:
    userInput = userInput + ((random_val1 - random_val2) - counter);
    break;
  case 3:
    userInput = (counter + (random_val1 - random_val2)) - userInput;
    break;
  case 4:
    userInput = ((random_val2 + random_val1) - counter) - userInput;
    break;
  case 5:
    userInput = userInput + random_val1 * random_val2 + counter;
    break;
  case 6:
    userInput = userInput + random_val2 * counter + random_val1;
    break;
  case 7:
    userInput = counter * userInput + random_val1 + random_val2;
    break;
  case 8:
    userInput = userInput + random_val1 * random_val2 * counter;
    break;
  default:
    userInput = userInput + random_val1 + random_val2 + counter;
  }
  if (*(long *)(in_FS_OFFSET + 0x28) == *(long *)(in_FS_OFFSET + 0x28)) {
    return userInput;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
}
```

Since we don't want to do this 99 times by hand we can write a quick python script to do this work for us.

```python
from pwn import *
from ctypes import c_int

p = remote("0.cloud.chals.io", 16577)

for counter in range(1,100):
    p.recvuntil(b"Random 1 >>> ")
    random_val1 = int(p.recvline(), 10)

    p.recvuntil(b"Random 2 >>> ")
    random_val2 = int(p.recvline(), 10)

    print(f"recevied: {random_val1} {random_val2}")

    result = 0
    x = counter % 10
    if x == 0:
        result = 1337 - (random_val1 - random_val2) - counter
    elif x == 1:
        result = -(1337 - (counter + random_val1 + random_val2))
    elif x == 2:
        result = 1337 - ((random_val1 - random_val2) - counter)
    elif x == 3:
        result = -(1337 - (counter + (random_val1 - random_val2)))
    elif x == 4:
        result = -(1337 - ((random_val2 + random_val1) - counter))
    elif x == 5:
        result = 1337 - (random_val1 * random_val2) - counter
    elif x == 6:
        result = 1337 - (random_val2 * counter) - random_val1
    elif x == 7:
        result = (1337 - random_val1 - random_val2) * pow(counter, -1, pow(2,64))
    elif x == 8:
        result = 1337 - (random_val1 * random_val2 * counter)
    else:
        result = 1337 - random_val1 - random_val2 - counter

    print(f"round {counter}")
    print(f"sending result: {result}")
    p.sendlineafter(b"Your Response >>> ", str(c_int(result).value).encode())
    counter = counter + 1

p.interactive()
```

Letting this script do it's magic eventually gives us the flag.

Flag `chctf{th3_F1RST_female_coMM3rcial_pr0graMM3r}`