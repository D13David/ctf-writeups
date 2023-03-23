# Cyber Apocalypse 2023

## She Shells C Shells

> You've arrived in the Galactic Archive, sure that a critical clue is hidden here. You wait anxiously for a terminal to boot up, hiding in the shadows from the guards hunting for you. Unfortunately, it looks like you'll need a password to get what you need without setting off the alarms...
>
>  Author: N/A
>
> [`rev_cshells.zip`](rev_cshells.zip)

Tags: _rev_

## Solution
A quick look into Ghidra tells us the file is indeed a very basic shell. The main function parses som user input and gives it to `runcmd`.

```
while( true ) {
    printf("ctfsh-$ ");
    result = fgets((char *)&userInput,0x400,stdin);
    if (result == (char *)0x0) break;
    posOfNewLine = strchr((char *)&userInput,10);
    if (posOfNewLine != (char *)0x0) {
      *posOfNewLine = '\0';
    }
    runcmd(&userInput);
  }
```
We can try the shell and see what it offers
```
$ ./shell 
ctfsh-$ help
ls: ls [directory] - lists files in a directory
whoami: whoami - prints the current user's name
cat: cat [files...] - prints out a sequence of files
getflag: admin only
ctfsh-$ getflag
Password:
```

There is a `getflag` command, thats nice. But it's for admin only. So we have to go back to Ghidra and investigate further.

```
fgets((char *)&local_118,0x100,stdin);
  for (local_c = 0; local_c < 0x4d; local_c = local_c + 1) {
    *(byte *)((long)&local_118 + (long)(int)local_c) =
         *(byte *)((long)&local_118 + (long)(int)local_c) ^ m1[(int)local_c];
  }
  local_14 = memcmp(&local_118,t,0x4d);
  if (local_14 == 0) {
    for (local_10 = 0; local_10 < 0x4d; local_10 = local_10 + 1) {
      *(byte *)((long)&local_118 + (long)(int)local_10) =
           *(byte *)((long)&local_118 + (long)(int)local_10) ^ m2[(int)local_10];
    }
    printf("Flag: %s\n",&local_118);
    uVar1 = 0;
  }
```

So it's a two part process. First the user input is processed with a xor table `m1` and then compared to `t`. If equal the input is again processed with another xor table `m2`. The result is in fact the flag.

Since the first part leads to `t` and the values of `t` are stored in the image, [`it is enough to do the second transformation`](decode.py) but with `t` as source. The values of `t` and `m2` can be retrieved from the `elf` via Ghirda.

```
m2 = [ 0x64, 0x1e, 0xf5, 0xe2, 0xc0, 0x97, 0x44, 0x1b, 0xf8, 0x5f, 0xf9, 0xbe, 0x18, 0x5d, 0x48, 0x8e, 0x91, 0xe4, 0xf6, 0xf1, 0x5c, 0x8d, 0x26, 0x9e, 0x2b, 0xa1, 0x02, 0xf7, 0xc6, 0xf7, 0xe4, 0xb3, 0x98, 0xfe, 0x57, 0xed, 0x4a, 0x4b, 0xd1, 0xf6, 0xa1, 0xeb, 0x09, 0xc6, 0x99, 0xf2, 0x58, 0xfa, 0xcb, 0x6f, 0x6f, 0x5e, 0x1f, 0xbe, 0x2b, 0x13, 0x8e, 0xa5, 0xa9, 0x99, 0x93, 0xab, 0x8f, 0x70, 0x1c, 0xc0, 0xc4, 0x3e, 0xa6, 0xfe, 0x93, 0x35, 0x90, 0xc3, 0xc9, 0x10, 0xe9 ]

t = [ 0x2c, 0x4a, 0xb7, 0x99, 0xa3, 0xe5, 0x70, 0x78, 0x93, 0x6e, 0x97, 0xd9, 0x47, 0x6d, 0x38, 0xbd, 0xff, 0xbb, 0x85, 0x99, 0x6f, 0xe1, 0x4a, 0xab, 0x74, 0xc3, 0x7b, 0xa8, 0xb2, 0x9f, 0xd7, 0xec, 0xeb, 0xcd, 0x63, 0xb2, 0x39, 0x23, 0xe1, 0x84, 0x92, 0x96, 0x09, 0xc6, 0x99, 0xf2, 0x58, 0xfa, 0xcb, 0x6f, 0x6f, 0x5e, 0x1f, 0xbe, 0x2b, 0x13, 0x8e, 0xa5, 0xa9, 0x99, 0x93, 0xab, 0x8f, 0x70, 0x1c, 0xc0, 0xc4, 0x3e, 0xa6, 0xfe, 0x93, 0x35, 0x90, 0xc3, 0xc9, 0x10, 0xe9 ]

foo = [chr(x^m2[i]) for i, x in enumerate(t)]
print("".join(foo))
```

And there it is, the flag `HTB{cr4ck1ng_0p3n_sh3ll5_by_th3_s34_sh0r3}`.