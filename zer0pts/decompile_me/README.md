# zer0pts CTF 2023

## decompile me

> Reverse engineering is getting easier thanks to IDA/Ghidra decompiler!
>
>  Author: N/A
>
> [`decompile_me.tar`](decompile_me.tar)

Tags: _rev_

## Solution
The challenge comes with a binary that needs to be analyzed. Following the hint we open the file with Ghidra and get a short progam code decompiled.

```c
void main(void)
{
  int iVar1;
  undefined4 extraout_var;
  long i;
  undefined8 *ptr;
  undefined8 flag [16];
  undefined buffer [384];

  ptr = flag;
  for (i = 0x200; i != 0; i = i + -1) {
    *(undefined *)ptr = 0;
    ptr = (undefined8 *)((long)ptr + 1);
  }
  flag[0] = 0x80;
  write(1,"FLAG: ",0xe);
  read(0,flag,0x80);
  RC4_setkey(&key,sbox);
  RC4_encrypt(flag,buffer,sbox);
  iVar1 = memcmp(buffer,&enc,0x80);
  if (CONCAT44(extraout_var,iVar1) == 0) {
    puts("Correct!");
  }
  else {
    puts("Wrong...");
  }
  return;
}
```

So, the application reads a flag, then initializes a `RC4 sbox`, then encrypts the flag with the sbox and finally compares the encrypted data with another chunk of data. Simple enough, the `key` seems to be present in the binary as well as the encoded chunk. Since [`RC4`](https://en.wikipedia.org/wiki/RC4) is symmetric we can easily decrypt the encoded data `enc` with the `key`.

Grabbing the `key` with the melodious content `0xdeadbeefcafebabe` and `enc`. This must be ok, since, who would not choose this key?

```

                        key                                             XREF[1]:     main:00101286(*)
0010201d be              ??         BEh
0010201e ba              ??         BAh
0010201f fe              ??         FEh
00102020 ca              ??         CAh
00102021 ef              ??         EFh
00102022 be              ??         BEh
00102023 ad              ??         ADh
00102024 de              ??         DEh
```

```
                        enc                                             XREF[1]:     main:001012ae(*)
00102025 08              ??         08h
00102026 09              ??         09h
00102027 dc              ??         DCh
00102028 cf              ??         CFh
00102029 97              ??         97h
0010202a 88              ??         88h
0010202b 8c              ??         8Ch
0010202c d0              ??         D0h
0010202d a1              ??         A1h
0010202e 33              ??         33h    3
...
```

But sadly enough, no flag appears. So what went wrong? I checked `RC4_setkey` and `RC4_encrypt` if there are any specialities, but it is vanilla `RC4`. So running the application in GDB for dynamic analysis reveils that, the generated `sbox` looks completely different. Going back to my implementation, but no.. all looks fine here.

```c
int RSA_setkey(const unsigned char* key, int len, unsigned char* S) 
{
    int j = 0;

    for (int i = 0; i < N; i++)
        S[i] = i;

    for (int i = 0; i < N; i++) 
    {
        j = (j + S[i] + key[i % len]) % N;
        swap(&S[i], &S[j]);
    }

    return 0;
}
```

The next weird thing, the key is not `0xdeadbeefcafebabe` but something random. Where does this come from? The dissassembly showed exactly that `key` is passed to `RSA_setkey`. So, next thing I did was to grab the key values which really where used and compute the sbox with this key. Now the sbox values matched exactly what could be seen in GDB. But why is this? Inspecting the assembly confirms that, the key is passed via `rdi` and the sbox is passed via `rsi`. But in `RSA_setkey` the values in rdi and rsi are never used but the memory regions pointed by `r12` and `r13`, where the key is referenced in `r12` and the sbox in `r13`.

```
  0x55555555527f <main+100>    lea    rsi, [rip + 0x2d92]           <0x555555558018>
  0x555555555286 <main+107>    lea    rdi, [rip + 0xd90]            <0x55555555601d>
► 0x55555555528d <main+114>    call   RC4_setkey                <RC4_setkey>
    rdi: 0x55555555601d (key) ◂— 0xdeadbeefcafebabe
    rsi: 0x555555558018 (sbox) ◂— 0x0
    rdx: 0x80
    rcx: 0x55555555515a (read+14) ◂— ret

...

  0x55555555518d <loop_key_schedule>       movzx  eax, byte ptr [r13 + rcx]
  0x555555555193 <loop_key_schedule+6>     add    edx, eax
  0x555555555195 <loop_key_schedule+8>     movzx  eax, byte ptr [r12 + rbx]
  0x55555555519a <loop_key_schedule+13>    add    edx, eax
► 0x55555555519c <loop_key_schedule+15>    movzx  edx, dl
  0x55555555519f <loop_key_schedule+18>    mov    dil, byte ptr [r13 + rdx]
  0x5555555551a4 <loop_key_schedule+23>    mov    sil, byte ptr [r13 + rcx]
  0x5555555551a9 <loop_key_schedule+28>    mov    byte ptr [r13 + rdx], sil
  0x5555555551ae <loop_key_schedule+33>    mov    byte ptr [r13 + rcx], dil
  0x5555555551b3 <loop_key_schedule+38>    inc    ebx
```

Good, so the decompiler lied to us.. Well, we can grab the real key (`31 09 81 19 19 14 45 11`) or just the sbox (`50, 59, 103, 54, 247, 111, 159, 115, 172, 18, 73, 28, 146, 179, 189, 68, 46, 37, 9, 251, 26, 139, 61, 43, 87, 34, 250, 15, 125, ...`) and decompile the message with those values. But well... the flag still doesn't appear. Whats going on now? Going back and check my RC4 code.

```c
void RC4(const unsigned char* key, int key_len, const unsigned char* plaintext, int text_len, unsigned char* ciphertext) 
{
    unsigned char S[N];
    RSA_setkey(key, key_len, S);

    int i = 0;
    int j = 0;

    for (int n = 0; n < text_len; n++)
    {
        i = (i + 1) % N;
        j = (j + S[i]) % N;

        swap(&S[i], &S[j]);
        int foo = (S[i] + S[j]) % N;
        int rnd = S[foo];

        ciphertext[n] = rnd ^ plaintext[n];
    }
}
```

But all looks good. It works with testcases, there is no issue but still the flag cannot be decoded. So, inspecting the disassembly.

```
  0x5555555552a9 <main+142>    mov    edx, 0x80
  0x5555555552ae <main+147>    lea    rsi, [rip + 0xd70]            <0x555555556025>
  0x5555555552b5 <main+154>    lea    rdi, [rsp + 0x80]
► 0x5555555552bd <main+162>    call   memcmp                <memcmp>
    s1: 0x7fffffffdd70 ◂— 0x561526cdd4d7cb63
    s2: 0x555555556025 (enc) ◂— 0xd08c8897cfdc0908
    n: 0x80

...
  0x55555555515b <memcmp>      xor    eax, eax
► 0x55555555515d <memcmp+2>    xor    ecx, ecx
  0x55555555515f <memcmp+4>    lea    rsi, [rip + 0x2e1a]           <0x555555557f80>
  0x555555555166 <lx>          mov    bl, byte ptr [r14 + rcx]
  0x55555555516a <lx+4>        xor    bl, byte ptr [rsi + rcx]
  0x55555555516d <lx+7>        or     al, bl
  0x55555555516f <lx+9>        inc    ecx
  0x555555555171 <lx+11>       cmp    ecx, edx
  0x555555555173 <lx+13>       jb     lx                <lx>
```

And here we have the same thing `enc` is passed into `memcmp` but never used. But rather than what is referenced in `r14`. Ok, so the Ghidra played the same trick here, and finally, after grabbing the right encoded buffer, and the right flag...

```
enc:
78    cf    c4    85    dc    33    07    4c
93    35    fb    7c    10    8e    be    93
28    e6    2e    75    da    5e    85    c5
91    15    75    89    48    0e    29    a4
f9    a6    3a    6e    1f    84    f7    42
b0    93    31    f0    68    c0    43    38
07    32    09    57    da    32    44    cf
cd    8f    e5    bf    e3    d6    bb    59
9a    6a    84    85    d3    22    a9    8e
b5    ea    bd    57    de    b1    6c    93
e4    74    70    ac    1a    03    d9    16
9f    bc    97    fb    85    d9    a6    9e
d4    d6    02    59    d5    28    b3    93
16    b6    c4    78    c4    a2    12    d2
ef    b1    54    18    fd    76    51    a3
5e    57    b8    58    4b    1e    e2    41
```

... we get the flag.
```
C:\zer0pts\>ConsoleApplication3.exe
zer0pts{d0n'7_4lw4y5_7ru57_d3c0mp1l3r}
```

Flag `zer0pts{d0n'7_4lw4y5_7ru57_d3c0mp1l3r}`