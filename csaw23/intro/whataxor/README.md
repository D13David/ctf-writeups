# CSAW'23

## my_first_pwnie

> 
> Now you actually need to figure what the binary is doing.......maybe try a tool like https://dogbolt.org/; It shows you the output of several tools that try to extract a representation similar to what the original code might have looked like.....which is a lot nicer than reading bytes.
>
>  Author: ElykDeer
>
> [`readme.txt`](readme.txt), [`whataxor`](whataxor)

Tags: _intro_

## Solution
For this challenge get get another binary and another readme with instructions. The description mentiones `dogbolt` but we have `Ghidra` installed and open the binary here.

```c
  printf("Enter your password: ");
  __isoc99_scanf(&DAT_00100b1a,local_78);
  xor_transform(local_78,0xffffffaa);
  local_c8 = -0x37;
  local_c7 = 0xd9;
  local_c6 = 0xcb;
  local_c5 = 0xdd;
  local_c4 = 0xc9;
  local_c3 = 0xde;
  local_c2 = 0xcc;
  local_c1 = 0xd1;
  // ...
  iVar1 = strcmp(local_78,&local_c8);
  if (iVar1 == 0) {
    puts("Correct!");
  }
  else {
    puts("Access denied.");
  }
```

The user is required to input a value, then `xor_transform` is called and the result is tested against a local array. If the result is identical we are getting the information `Correct!`. The function `xor_transform` really does what the name suggests: Looping over the input and xoring with a value. The function is called with the xor key `0xffffffaa` but since the parameter is expecting a `byte` the actual key is `0xaa`.

```c
void xor_transform(long param_1,byte param_2)
{
  int local_c;
  
  for (local_c = 0; *(char *)(param_1 + local_c) != '\0'; local_c = local_c + 1) {
    *(byte *)(param_1 + local_c) = *(byte *)(param_1 + local_c) ^ param_2;
  }
  return;
}
```

We can retrieve the flag easily by grabbing the xor result and xoring again with `0xaa`. Lets do this.

```python
flag = [0xc9,0xd9,0xcb,0xdd,0xc9,0xde,0xcc,0xd1,0x9a,0xc4,0xcf,0xf5,0xd9,0xc2,0xcf,0xcf,0xfa,0xf5,0x9b,0xdd,0xc5,0xf5,0xd9,0xc2,0xcf,0xfd,0xda,0xf5,0x98,0xc2,0xd8,0xcf,0xcf,0xf5,0x9f,0xc2,0xcf,0xcf,0xc1,0xd9,0xf5,0xf5,0xf5,0xf5,0xf5,0xd0,0xf5,0xf5,0xf5,0xd0,0xd0,0xd0,0xf5,0xf5,0xf5,0xf5,0xf5,0xd0,0xd0,0xd0,0xd0,0xd0,0xd0,0xf5,0xf5,0xf5,0xf5,0xd2,0xc5,0xd8,0xd7]

for c in flag:
    print(chr(c^0xaa), end="")
```

```bash
$ python solve.py
csawctf{0ne_sheeP_1wo_sheWp_2hree_5heeks_____z___zzz_____zzzzzz____xor}
```

Flag `csawctf{0ne_sheeP_1wo_sheWp_2hree_5heeks_____z___zzz_____zzzzzz____xor}`