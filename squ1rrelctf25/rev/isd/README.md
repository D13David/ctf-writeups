# squ1rrel CTF 2025

## Intermediate Software Design

> I love design patterns and c++!
>
>  Author: AJ
>
> [`output.txt`](output.txt), [`isd`](isd)

Tags: _rev_

## Solution
This reversing challenge gives us a textfile with some cryptic output, as well as a binary.

```bash
Transformed output as chars: Yu*4-v)mXzjzso$~0vX_&Z	rB~
```

Let's fire up `BinaryNinja` and see what `isd` is doing. The threat from the challenge title becomes clear by looking at the decompiled code, it was written in C++, but at least the binary is not stripped and we have all the naming still in place.

The first part just reads in the content of a textfile `flag.txt` and stores the characters in a `std::vector<uint32_t>`.

```c
00001349    int32_t main(int32_t argc, char** argv, char** envp)

00001349    {
00001349        void* fsbase;
00001359        int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
00001381        void __is;
00001381        std::ifstream::ifstream(&__is, "flag.txt");
00001390        void __str;
00001390        std::string::string(&__str);
000013a9        std::getline<char>(&__is, &__str);
000013b8        std::vector<int32_t>::vector();
000013c4        void* var_3f8 = &__str;
000013da        std::string::iterator var_3c8 = std::string::begin(var_3f8);
000013f0        std::string::iterator var_3a8 = std::string::end(var_3f8);
0000145a        int32_t var_410;
0000145a        
0000145a        while (operator!=<char*, std::string>(&var_3c8, &var_3a8))
0000145a        {
0000145a            var_410 = (int32_t)*(uint8_t*)__normal_iterator<char*, std::string>::operator*();
00001432            void var_3e8;
00001432            std::vector<int32_t>::push_back(&var_3e8);
00001441            __normal_iterator<char*, std::string>::operator++();
0000145a        }
// ...
```

The next part uses a non standard class (`CustomVector`). The program loops over every entry of the vector we filled before with the flag characters and computes a xor operation. The key is hardcoded on the stack (`var_29`). But it's using a `CustomVector`, so just to be sure, we have a closer look so see what happens there.

```c
// ...
00001477        std::vector<int32_t>::vector(&var_3a8);
00001490        CustomVector::CustomVector(&var_3c8);
0000149f        std::vector<int32_t>::~vector();
000014ae        int64_t var_29;
000014ae        __builtin_strncpy(&var_29, "*QcM\"\\7~", 8);
000014b2        char var_21 = 0x19;
000014b6        int64_t var_408 = 0;
000014d0        var_410 = CustomVector::begin();
000014d0        
00001558        while (true)
00001558        {
00001558            var_3a8 = CustomVector::end();
00001558            
0000157a            if (!CustomIterator::operator!=(&var_410))
0000157a                break;
0000157a            
00001530            *(uint32_t*)CustomIterator::operator*() ^= (uint32_t)*(uint8_t*)(&var_29 + var_408 % 9);
0000153c            CustomIterator::operator++();
00001541            var_408 += 1;
00001558        }
// ...
```

While the `constructor`, `CustomVector::begin`, `CustomVector::end`, `CustomIterator::operator!=` and `CustomIterator::operator*` seem to just forward to the standard library `__normal_iterator` there is something weird in `CustomIterator::operator++`, that is not obvious from the decompiled result BinaryNinja delivers:

```c
00001876    int64_t CustomIterator::operator++()
00001876    {
00001876        int64_t result;
00001892        __normal_iterator<int32_t*, std::vector<int32_t> >::operator+=(result);
0000189c        return result;
00001876    }
```

But if we put the disassembly on the side...

```c
00001876    int64_t CustomIterator::operator++()

00001876  f30f1efa           endbr64 
0000187a  55                 push    rbp {__saved_rbp}
0000187b  4889e5             mov     rbp, rsp {__saved_rbp}
0000187e  4883ec10           sub     rsp, 0x10
00001882  48897df8           mov     qword [rbp-0x8 {var_10}], rdi
00001886  488b45f8           mov     rax, qword [rbp-0x8 {var_10}]
0000188a  be02000000         mov     esi, 0x2
0000188f  4889c7             mov     rdi, rax
00001892  e8bb010000         call    __normal_iterator<int32_t*, std::vector<int32_t> >::operator+=
00001897  488b45f8           mov     rax, qword [rbp-0x8 {var_10}]
0000189b  c9                 leave    {__saved_rbp}
0000189c  c3                 retn     {__return_addr}
```

... we see that `esi` is set to `2` before calling `__normal_iterator::operator+=`. So, `CustomIterator` actually increments in two-steps not in single-steps. This is an important thing to know. Also, there is some minor pitfall with the key:

```c
000014ae  488945df           mov     qword [rbp-0x21 {var_29}], rax  {0x7e375c224d63512a}
000014b2  c645e719           mov     byte [rbp-0x19 {var_21}], 0x19  {0x19}
000014b6  48c78500fcffff00…  mov     qword [rbp-0x400 {var_408}], 0x0
```

The key is `9` characters wide so the compiler tried to optimize this by copying `8 bytes` in one block and then the last byte with another operation. The whole key is therefore `b'*QcM"\\7~\x19'` or `[0x2a, 0x51, 0x63, 0x4d, 0x22, 0x5c, 0x37, 0x7e, 0x19]`.

But there is more. The program copies a table from `data_3060` to the stack and loops over the result of the last step. It's interesting that here the CustomIterator is not used but indexing into the result of `CustomVector::raw`. Quickly checking what `raw` returns, but it's only the address to the memory held by `CustomVector`, so nothing special here.

```c
// ...
00001599        void var_368;
00001599        __builtin_memcpy(&var_368, &data_3060, 0x130);
000015a6        std::vector<int32_t>::vector();
000015ab        int64_t var_400 = 0;
000015ab        
0000163e        while (true)
0000163e        {
0000163e            int64_t rax_29;
0000163e            rax_29 = var_400 < std::vector<int32_t>::size();
0000163e            
00001643            if (!rax_29)
00001643                break;
00001643            
000015dc            int32_t rdx_5 = *(uint32_t*)std::vector<int32_t>::operator[](CustomVector::raw());
000015f1            var_410 = *(uint32_t*)(&var_368 + (var_408 << 2)) + rdx_5 - 2;
0000160b            std::vector<int32_t>::push_back(&var_3a8);
00001610            var_408 += 1;
00001618            var_400 += 1;
0000163e        }
// ...
```

The code iterates over *every* character stored in `CustomVector`. Then a value is read from the table mentioned beforehand and added to the current `CustomVector` entry and finally `2` is substracted. 

We also can note that `data_3060` stores 32 bit unsigned integer values (as the index is left shifted by two, that equivalent to multiplying with 4). The result of the operation is stored in yet another standard vector.

But also here is something to point out. We have two counters (`var_408` and `var_400`). `var_400` is initialized with `0` just before the loop starts and is used to index into `CustomVector`. But `var_408` is not reset to `0` but keeps the number from the previous loop. As the previous loop skipped every second flag character `var_408` starts with the value `len(flag)//2`.

The final part of the program then writes the `output` file and just prints the values from the final `std::vector<uint32>`. So we have all the pieces together to reverse the flag. First we need to grab the encoded data from `output.txt` plus the key. Also we need to offset table. Then we can run the offset step first and undo to offset and finally just xor again (every second character) with the key.

```py
enc_data = [0x59, 0x75, 0x2A, 0x34, 0x2D, 0x76, 0x29, 0x6D, 0x58, 0x7A, 0x6A, 0x7A, 0x73, 0x6F, 0x24, 0x7E, 0x30, 0x76, 0x58, 0x5F, 0x26, 0x5A, 0x09, 0x72, 0x42, 0x7E]

key = [0x2a, 0x51, 0x63, 0x4d, 0x22, 0x5c, 0x37, 0x7e, 0x19]

offset = [
    0x3, 0x3,  0x1, 0x5, 0x32, 0x8, 0x1, 0x9,
    0x5, 0x7,  0x9, 0x3, 0x2,  0x2, 0x6, 0x8,
    0x5, 0x1e, 0x6, 0x3, 0x3,  0x1, 0x5, 0x4,
    0x8, 0x1,  0x9, 0x5, 0x7,  0x9, 0x3, 0x2,
    0x2, 0x6,  0x8, 0x5, 0x4,  0x6, 0x3, 0x3,
    0x1, 0x5,  0x4, 0x8, 0x1,  0x9, 0x5, 0x7,
    0x9, 0x3,  0x2, 0x2, 0x6,  0x8, 0x5, 0x4,
    0x6, 0x3,  0x3, 0x1, 0x5,  0x4, 0x8, 0x1,
    0x9, 0x5,  0x7, 0x9, 0x3,  0x2, 0x2, 0x6,
    0x8, 0x5,  0x4, 0x6
]

flag = bytearray(enc_data)

for i, char in enumerate(flag):
    flag[i] = char - offset[len(flag)//2 + i] + 2

for i in range(len(flag)//2):
    flag[i * 2] ^= key[i % len(key)]

print(flag.decode())
```

Running this, gives us the flag.

Flag `squ1rrel{w4tCh_y0ur_sTeps}`