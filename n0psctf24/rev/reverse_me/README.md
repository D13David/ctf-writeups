# N0PSctf 2024

## Reverse Me

> Don't complain if you can't see me, because I have to be reversed to make me run 🙃
> 
> Author: Simone Aonzo
> 
> [`img.jpg`](img.jpg)

Tags: _rev_

## Solution
The challenge comes with an image. But as the image cannot be viewed we check again with `file`.

```bash
$ file img.jpg
img.jpg: JPEG image data
```

This looks off somehow, there should be more information extracted from the header. When opening the file with a hexeditor we see it indeed starts with a `JFIF` marker but the following bytes don't look like an image at all. Further down we find some strings we would expect in a binary file (`elf`) and right at the bottom we find the bytes `FLE` which reversed reads `ELF`. So we do what the description tells us and reverse the image bytes giving us...

```bash
$ file img
img: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=ae64a94832a94702644e170ebf1177740605cb34, for GNU/Linux 3.2.0, stripped
```

This looks better. Opening this in `Ghidra` and following the `_start` function we get this `main`:

```c
void FUN_001011e0(int param_1,long param_2)
{
  char cVar1;
  ulong uVar2;
  ulong uVar3;
  ulong uVar4;
  ulong uVar5;
  ulong uVar6;
  char *__s;
  long lVar7;
  undefined1 *puVar8;
  undefined *puVar9;
  long in_FS_OFFSET;
  byte bVar10;
  undefined local_a0 [8];
  undefined local_98 [32];
  undefined local_78 [56];
  undefined8 local_40;
  
  bVar10 = 0;
  local_40 = *(undefined8 *)(in_FS_OFFSET + 0x28);
  if (param_1 == 5) {
    uVar2 = strtol(*(char **)(param_2 + 8),(char **)0x0,10);
    uVar3 = strtol(*(char **)(param_2 + 0x10),(char **)0x0,10);
    uVar4 = strtol(*(char **)(param_2 + 0x18),(char **)0x0,10);
    uVar5 = strtol(*(char **)(param_2 + 0x20),(char **)0x0,10);
    cVar1 = FUN_00101460(uVar2 & 0xffffffff,uVar3 & 0xffffffff,uVar4 & 0xffffffff,uVar5 & 0xffffffff
                        );
    if (cVar1 != '\0') {
      uVar6 = (ulong)(uint)-(int)uVar5;
      if (0 < (int)uVar5) {
        uVar6 = uVar5 & 0xffffffff;
      }
      uVar5 = (ulong)(uint)-(int)uVar4;
      if (0 < (int)uVar4) {
        uVar5 = uVar4 & 0xffffffff;
      }
      uVar4 = (ulong)(uint)-(int)uVar3;
      if (0 < (int)uVar3) {
        uVar4 = uVar3 & 0xffffffff;
      }
      uVar3 = (ulong)(uint)-(int)uVar2;
      if (0 < (int)uVar2) {
        uVar3 = uVar2 & 0xffffffff;
      }
      __sprintf_chk(local_78,1,0x2a,"%d%d%d%d",uVar3,uVar4,uVar5,uVar6);
      puVar8 = &DAT_00102016;
      puVar9 = local_98;
      for (lVar7 = 0x19; lVar7 != 0; lVar7 = lVar7 + -1) {
        *puVar9 = *puVar8;
        puVar8 = puVar8 + (ulong)bVar10 * -2 + 1;
        puVar9 = puVar9 + (ulong)bVar10 * -2 + 1;
      }
      __s = (char *)FUN_00101a50(local_98,0x18,local_78,local_a0);
      puts(__s);
      free(__s);
                    // WARNING: Subroutine does not return
      exit(0);
    }
  }
                    // WARNING: Subroutine does not return
  exit(-1);
}
```

Four commandline arguments are expected when the programm is called, each of them is converted to an 32 bit integer and then passed to another function. The result of the function is expected to be not zero for the program to proceed. Lets see what `FUN_00101460` does.

```c
bool FUN_00101460(int param_1,int param_2,int param_3,int param_4)
{
  bool bVar1;
  
  bVar1 = false;
  if (param_1 * -10 + param_2 * 4 + param_3 + param_4 * 3 != 0x1c) {
    return false;
  }
  if ((param_2 * 9 + param_1 * -8 + param_3 * 6 + param_4 * -2 == 0x48) &&
     (param_2 * -3 + param_1 * -2 + param_3 * -8 + param_4 == 0x1d)) {
    bVar1 = param_2 * 7 + param_1 * 5 + param_3 + param_4 * -6 == 0x58;
  }
  return bVar1;
}
```

The function returns true if some conditions are met, the get a valid set of parameters we can use `z3py`.

```python
from z3 import *

part1 = BitVec('part1', 32)
part2 = BitVec('part2', 32)
part3 = BitVec('part3', 32)
part4 = BitVec('part4', 32)

solver = Solver()

solver.add(part1 * -10 + part2 * 4 + part3 + part4 * 3 == 0x1c)
solver.add(part2 * 9 + part1 * -8 + part3 * 6 + part4 * -2 == 0x48)
solver.add(part2 * -3 + part1 * -2 + part3 * -8 + part4 == 0x1d)
solver.add(part2 * 7 + part1 * 5 + part3 + part4 * -6 == 0x58)

if solver.check() == sat:
    model = solver.model()
    print(f"part1: {model[part1].as_long()}")
    print(f"part2: {model[part2].as_long()}")
    print(f"part3: {model[part3].as_long()}")
    print(f"part4: {model[part4].as_long()}")
else:
    print("No solution found")
```

This script gives us the numbers
```bash
part1: 4294967293
part2: 8
part3: 4294967289
part4: 4294967287
```

Instead of reversing the binary further, lets see what happens if we call it with the computed numbers:

```bash
$ ./img 4294967293 8 4294967289 4294967287
N0PS{r1CKUNr0111N6}
```

Flag `N0PS{r1CKUNr0111N6}`