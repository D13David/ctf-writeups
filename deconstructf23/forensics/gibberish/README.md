# DeconstruCT.F 2023

## Gibberish

> NASA receive a weird transmission yesterday but they were't able to decode it. I mean, it's just a bunch of gibberish. The only thing they have cracked was one word "goodbye"
They have no clue what that means though. Can you help them?
>
>  Author: N/A
>
> [`flag.txt`](flag.txt)

Tags: _forensics_

## Solution
The text file coming with this challenge contains some base64 encoded data. The decoded data seems to be an Linux executable.

```bash
$ cat flag.txt | base64 -d > foo
$ file foo
foo: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV)
```

The decompiled program is very short and simple. It requests a `password` and checks if the entered string equals `goodbye`. The flag is subsequently printed to screen and can just be grabbed from file.

```c
undefined8 main(void)
{
  int iVar1;
  long in_FS_OFFSET;
  char local_58 [72];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  printf("Password: ");
  __isoc99_scanf(&DAT_00102013,local_58);
  iVar1 = strcmp(local_58,"goodbye");
  if (iVar1 == 0) {
    puts("mlh{nc_c4n_4ls0_trnsmit_f1les}");
  }
  else {
    puts("Wrong password.");
  }
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

Flag `dsc{nc_c4n_4ls0_trnsmit_f1les}`