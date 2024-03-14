# Cyber Apocalypse 2024

## BoxCutter

> You've received a supply of valuable food and medicine from a generous sponsor. There's just one problem - the box is made of solid steel! Luckily, there's a dumb automated defense robot which you may be able to trick into opening the box for you - it's programmed to only attack things with the correct label.
> 
> Author: clubby789
> 
> [`rev_boxcutter.zip`](rev_boxcutter.zip)

Tags: _rev_

## Solution
We get a binary for this challenge. If we put it to `Ghidra` we can see that a file is opened. The filename is xor encrypted. So we can decrypt it on our own, or we call the binary with strace, that logs the open call with the filename.

```c 
local_28 = 0x540345434c75637f;
local_20 = 0x45f4368505906;
uStack_19 = 0x68;
uStack_18 = 0x374a025b5b0354;
for (i = 0; i < 23; i = i + 1) {
     *(byte *)((long)&local_28 + (long)(int)i) = *(byte *)((long)&local_28 + (long)(int)i) ^ 0x37;
}
local_10 = open((char *)&local_28,0);
if (local_10 < 1) {
     puts("[X] Error: Box Not Found");
}
else {
     puts("[*] Box Opened Successfully");
     close(local_10);
}
```

```bash
$ strace rev_boxcutter/cutter
execve("rev_boxcutter/cutter", ["rev_boxcutter/cutter"], 0x7fff030197b0 /* 30 vars */) = 0
brk(NULL)                               = 0x55b3236ec000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f432a0e3000
....
openat(AT_FDCWD, "HTB{tr4c1ng_th3_c4ll5}", O_RDONLY) = -1 ENOENT (No such file or directory)
...
```

Flag `HTB{tr4c1ng_th3_c4ll5}`