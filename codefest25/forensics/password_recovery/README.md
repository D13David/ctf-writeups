# Codefest CTF 2025

## Password Recovery

> 
> Back in 2019, I wrote a secret and encrypted it using a password on Republic Day of India. Now I forgot the password :(
>
> I only have the passgen utility I used and the encrypted file. Can you help me?
>
>  Author: 0xkn1gh7
>
> [`passgen`](passgen), [`encrypted.zip`](encrypted.zip)

Tags: _forensics_

## Solution
This challenge comes with the password generator executable (mentioned in the description) and the encrypted zip archive. Lets first have a look at what the executable does.

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    banner();
    int64_t var_58;
    __builtin_strcpy(&var_58, "abcdefghijklmnoqprstuvwyzxABCDEFGHIJKLMNOQPRSTUYWVZX0123456789");
    srand(time(nullptr));
    void var_68;
    
    for (int32_t i = 0; i <= 0xe; i += 1)
        *(uint8_t*)(&var_68 + (int64_t)i) = *(uint8_t*)(&var_58 + (int64_t)(rand() % 0x3e));
    
    char var_59 = 0;
    printf("[*] HERE IS YOUR SECURELY GENERA…", &var_68);
    *(uint64_t*)((char*)fsbase + 0x28);
    
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
        return 0;
    
    __stack_chk_fail();
    /* no return */
}
```

It's fairly simple. The password generated is always 15 characters long while characters are randomly choosen from an `lower-` and `uppercase` alphanumeric alphabet. The random seed is set to `time(nullptr)` which is typically a good indicator for us to find the correct timestamp, so we can regenerate the same random number sequence.

```python
from ctypes import CDLL

ALPHABET = b"abcdefghijklmnoqprstuvwyzxABCDEFGHIJKLMNOQPRSTUYWVZX0123456789"

libc = CDLL("libc.so.6")

def gen_password(timestamp):
    result = bytearray()
    libc.srand(timestamp)
    for i in range(0, 15):
        result.append(ALPHABET[libc.rand() % len(ALPHABET)])

    return bytes(result)

print(gen_password(0))
```

Very well, now we can generate passwords. We only need to have the exact same timestamp that was used when the password was generated back in `2019`. While we easily can bruteforce the whole `32 bit range`, this takes a bit of time. So often it is a good idea to use the current timestamp and work backwards. But here we have a even better hint, the archive was packed in 2019, so we only have to look at a single year.

```python
from ctypes import CDLL
from zipfile import ZipFile
from datetime import datetime

ALPHABET = b"abcdefghijklmnoqprstuvwyzxABCDEFGHIJKLMNOQPRSTUYWVZX0123456789"

libc = CDLL("libc.so.6")

def gen_password(timestamp):
    result = bytearray()
    libc.srand(timestamp)
    for i in range(0, 15):
        result.append(ALPHABET[libc.rand() % len(ALPHABET)])

    return bytes(result)

start = 1546297200          # 01.01.2019
end   = start + 31540000    # start plus one year worth of seconds

for ts in range(start, end + 1):
    password = gen_password(ts)
    try:
        with ZipFile("encrypted.zip", "r") as archive:
            with archive.open("flag.txt", pwd = password) as flag_file:
                content = flag_file.read()
                print(f"found {password.decode()} at {datetime.fromtimestamp(ts)}")
                print(f"content: {content.decode()}")
                exit(0)
    except:
        pass
```

The script automates all this, and after a while, we get the flag.

```bash
$ python extract.py
found kFEbD1Pzxyu69Yw at 2019-01-26 13:42:56
content: CodefestCTF{rand_15_n07_4c7ua11y_r4nd0m}
```

Flag `CodefestCTF{rand_15_n07_4c7ua11y_r4nd0m}`