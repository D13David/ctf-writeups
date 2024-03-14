# Cyber Apocalypse 2024

## FollowThePath

> A dark tunnel has been placed in the arena. Within it is a powerful cache of weapons, but reaching them won't be easy. You must navigate the depths, barely able to see the ground beyond your feet...
> 
> Author: es3n1n
> 
> [`rev_followthepath.zip`](rev_followthepath.zip)

Tags: _rev_

## Solution
For this challenge we get a win32 binary. After opening in `Ghidra` we find the program main.

```c
void FUN_140001960(void)
{
  _iobuf *p_Var1;
  undefined auStack_d8 [32];
  char *local_b8;
  undefined *local_b0;
  undefined *local_a8;
  code *local_a0;
  char local_98 [128];
  ulonglong local_18;
  
  local_18 = DAT_14001c008 ^ (ulonglong)auStack_d8;
  FUN_1400046d0(0x140016ffc);                        // print: "Please enter the flag"
  p_Var1 = (_iobuf *)FUN_140003064(0);
  thunk_FUN_1400045f8(local_98,0x7f,p_Var1);         // read user input
  local_a0 = FUN_140001000;
  local_a8 = &LAB_140001a00;                         // function prints "Nope"
  local_b0 = &LAB_140001a20;                         // function prints "Correct!"
  local_b8 = local_98;
  FUN_140001000(0);                                  // flag checker
  return;
}
```

The function at `140001000` is rather short. `R10` points to the `nope` function, `R11` points to the `correct` function and `R12` points to the user input.

```c
140001000 4d 31 c0        XOR        R8,R8
140001003 45 8a 04 0c     MOV        R8B,byte ptr [R12 + param_1*0x1]       ; loads the first byte of the user input (param_1 is 0 at this point)
140001007 49 81 f0        XOR        R8,0xc4                                ; xor with 0xc4
          c4 00 00 00
14000100e 49 81 f8        CMP        R8,0x8c                                ; check if the result is 0x8c
          8c 00 00 00
140001015 0f 84 03        JZ         LAB_14000101e
          00 00 00
14000101b 41 ff e2        JMP        R10                                    ; if not.. call nope function
                        LAB_14000101e
14000101e 48 ff c1        INC        param_1                                ; if yes.. increment read index
140001021 4c 8d 05        LEA        R8,[LAB_140001039]                     ; load address 140001039
          11 00 00 00
140001028 48 31 d2        XOR        RDX,RDX
                        LAB_14000102b
14000102b 41 80 34        XOR        byte ptr [R8 + RDX*offset LAB_140001039],0xde ; xor byte at mem[140001039+RDX] with 0xde
          10 de
140001030 48 ff c2        INC        RDX                                    ; increment RDX
140001033 48 83 fa 39     CMP        RDX,0x39                               ; check if RDX equals 0x39...
140001037 75 f2           JNZ        LAB_14000102b                          ; ...if not jump back to loop start
                        LAB_140001039
140001039 93              XCHG       EAX,EBX
                        LAB_14000103a
14000103a ef              OUT        DX,EAX
14000103b 1e              ??         1Eh
14000103c 9b              ??         9Bh
```

This code first tests if the first flag character is equal to `H` (0xc4^0x8c = 0x48 = 'H'). If this is not the case the program exits with the message "Nope", otherwise it starts to decrypting some followup code. This basically means, the program decrypts itself and this also explains why the function seems so short.

We could try to use a side-channel-attack, but we also can decrypt the program with a script. Since we also can gather the flag characters on our way we don't even need to analyze the program any further. The following script does the decryption.

```python
buffer = bytearray(open("chall.exe", "rb").read())

# this are the values we gathered from the disassembly. the next chunk starts
# at offset 0x439, is 57 bytes large and the decryption key is 0xde.
offset = 0x439
size = 57
value = 0xde

# first flag character is known
flag = "H"

found = True

while found:
    # we don't want to go too far
    if offset > 0xd5f or offset+size > 0xd5f:
        break
    # decode chunk
    for i in range(offset, offset+size):
        buffer[i] ^= value

    # read flag character for current chunk
    flag += chr(buffer[offset+10]^buffer[offset+17])

    found = False
    # check if we find another 'xor byte ptr [r8+rdx], value instruction. if so we extract the values for the
    # next block. otherwise we assume no more blocks are decrypted
    for i in range(offset, offset+size):
        if buffer[i] == 0x41 and buffer[i+1] == 0x80 and buffer[i+2] == 0x34 and buffer[i+3] == 0x10:
            offset += size
            value = buffer[i+4]
            size = buffer[i+11]
            found = True
            break

print(flag)
```

And running this on the binary gives us the flag.

Flag `HTB{s3lF_d3CRYpt10N-1s_k1nd4_c00l_i5nt_1t}`