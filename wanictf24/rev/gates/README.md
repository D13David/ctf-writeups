# WaniCTF 2024

## gates

> In to the gates go the flag, out comes something. What is the flag?
>
>  Author: southball
>
> [`rev-gates.zip`](rev-gates.zip)

Tags: _rev_

## Solution
Another reversing challenge another binary. Opening the binary with `Binary Ninja` gives us the following `main` function.

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    void* i = &data_404c;
    do
    {
        i = ((char*)i + 0x10);
        char rax_1 = getc(stdin);
        *(uint8_t*)((char*)i - 0x10) = 1;
        *(uint8_t*)((char*)i - 0xf) = rax_1;
    } while (i != &data_424c);
    int32_t i_2 = 0x100;
    int32_t i_1;
    do
    {
        sub_1220();
        i_1 = i_2;
        i_2 = (i_2 - 1);
    } while (i_1 != 1);
    void* rax_3 = &data_4e4d;
    void* rdx = &data_4020;
    int32_t rax_4;
    while (true)
    {
        if (*(uint8_t*)rax_3 != *(uint8_t*)rdx)
        {
            puts("Wrong!");
            rax_4 = 1;
            break;
        }
        rax_3 = ((char*)rax_3 + 0x10);
        rdx = ((char*)rdx + 1);
        if (rax_3 == &data_504d)
        {
            puts("Correct!");
            rax_4 = 0;
            break;
        }
    }
    return rax_4;
}
```

Thats not too much code. First the user is required to enter input via `stdin`, the input is read char by char and is written to some global memory section (at `0x404c`). Then A function is called `255` times (we will inspect this later). In the last step, two memory areas are compared to be identical, we can assume that our `obfuscated` flag values can be found starting from address `0x4020` and we have to reverse the previous steps to end up with the correct user input. 

Lets see what `sub_1220` is doing.

```c
void* sub_1220()
{
    void* i = &data_4040;
    do
    {
        int32_t rdx_4 = *(uint32_t*)i;
        if (rdx_4 == 3)
        {
            void* rdx_11 = ((((int64_t)*(uint32_t*)((char*)i + 4)) << 4) + &data_4040);
            if (*(uint8_t*)((char*)rdx_11 + 0xc) != 0)
            {
                void* rdi_7 = ((((int64_t)*(uint32_t*)((char*)i + 8)) << 4) + &data_4040);
                if (*(uint8_t*)((char*)rdi_7 + 0xc) != 0)
                {
                    char rdx_12 = (*(uint8_t*)((char*)rdx_11 + 0xd) ^ *(uint8_t*)((char*)rdi_7 + 0xd));
                    *(uint8_t*)((char*)i + 0xc) = 1;
                    *(uint8_t*)((char*)i + 0xd) = rdx_12;
                }
            }
        }
        else
        {
            if ((rdx_4 == 1 || rdx_4 == 2))
            {
                void* rdx_3 = ((((int64_t)*(uint32_t*)((char*)i + 4)) << 4) + &data_4040);
                if (*(uint8_t*)((char*)rdx_3 + 0xc) != 0)
                {
                    void* rdi_3 = ((((int64_t)*(uint32_t*)((char*)i + 8)) << 4) + &data_4040);
                    if (*(uint8_t*)((char*)rdi_3 + 0xc) != 0)
                    {
                        char rdi_4 = (*(uint8_t*)((char*)rdi_3 + 0xd) + *(uint8_t*)((char*)rdx_3 + 0xd));
                        *(uint8_t*)((char*)i + 0xc) = 1;
                        *(uint8_t*)((char*)i + 0xd) = rdi_4;
                    }
                }
            }
            if (rdx_4 == 4)
            {
                void* rdx_7 = ((((int64_t)*(uint32_t*)((char*)i + 4)) << 4) + &data_4040);
                if (*(uint8_t*)((char*)rdx_7 + 0xc) != 0)
                {
                    char rdx_8 = *(uint8_t*)((char*)rdx_7 + 0xd);
                    i = ((char*)i + 0x10);
                    *(uint8_t*)((char*)i - 4) = 1;
                    *(uint8_t*)((char*)i - 3) = rdx_8;
                    if (i == &stdin)
                    {
                        break;
                    }
                    continue;
                }
            }
        }
        i = ((char*)i + 0x10);
    } while (i != &stdin);
    return i;
}
```

The function loops over a memory reagion (starting at `0x4040`) and reads values from this region. Based on the values other operations are done, in total there are 3 `types` of operations: `1, 2, 3 and 4` whereas operation type `1` and `2` are invoking the same logic. Another thing we can see is that the pointer `i` is incremented in `16 byte` steps, we therefore can assume the memory region is structured in some way.

The semantic if the first 4 bytes (uint32_t) we already know, they describe the operation type. We therefore can call the field `type`. Lets create a new structure with `Binary Ninja` so the code becomes more clear, we'll call it `buffer_data_t`.

```c
struct buffer_data_t __packed
{
    uint32_t type;
    __padding char _4[0xc];
};
```

Also we can `re-type` our pointer to update the code.

```c
struct buffer_data_t* ptr = &data_4040;
do
{
    uint32_t type = ptr->type;
    if (type == 3)
    {
        void* rdx_10 = ((((int64_t)*(int64_t*)((char*)ptr + 4)) << 4) + &data_4040);
        if (*(uint8_t*)((char*)rdx_10 + 0xc) != 0)
        {
            void* rdi_7 = ((((int64_t)*(int64_t*)((char*)ptr + 8)) << 4) + &data_4040);
            if (*(uint8_t*)((char*)rdi_7 + 0xc) != 0)
            {
                char rdx_11 = (*(uint8_t*)((char*)rdx_10 + 0xd) ^ *(uint8_t*)((char*)rdi_7 + 0xd));
                *(int64_t*)((char*)ptr + 0xc) = 1;
                *(int64_t*)((char*)ptr + 0xd) = rdx_11;
            }
        }
    }
    else
    {
        // ...
```

Wow, so clean... Lets see what the other fields are doing. We are reading two more 32 bit values from `ptr+4` and `ptr+8`, so we update our structure accordingly. Also we write one byte at `ptr+0xc` and one byte at `ptr+0xd`.

```c
struct buffer_data_t __packed
{
    uint32_t type;
    uint32_t unknown1;
    uint32_t unknown2;
    uint8_t unknown3;
	uint8_t unknown4;
    __padding char _d[2];
};
```

The code looks now something like this.

```c
struct buffer_data_t* ptr = &data_4040;
do
{
    uint32_t type = ptr->type;
    if (type == 3)
    {
        void* rdx_10 = ((((int64_t)ptr->unknown1) << 4) + &data_4040);
        if (*(uint8_t*)((char*)rdx_10 + 0xc) != 0)
        {
            void* rdi_7 = ((((int64_t)ptr->unknown2) << 4) + &data_4040);
            if (*(uint8_t*)((char*)rdi_7 + 0xc) != 0)
            {
                uint8_t rdx_11 = (*(uint8_t*)((char*)rdx_10 + 0xd) ^ *(uint8_t*)((char*)rdi_7 + 0xd));
                ptr->unknown3 = 1;
                ptr->unknown4 = rdx_11;
            }
        }
    }
    else
    {
        // ...
```

What we have in `rdx_10` and `rdx_7` are index values for sure. They are left-shifted by 4 bits (which is a multiplication with 16) and then used to access memory region `0x4040` again. Lets call them accordingly `index1` and `index2`. Also we can re-type `rdx_10` and `rdx_7` since we know we access an item of the same datastructure. Now we have the following.

```c
uint32_t type = ptr->type;
if (type == 3)
{
    struct buffer_data_t* rdx_10 = ((((int64_t)ptr->index1) << 4) + &data_4040);
    if (rdx_10->unknown3 != 0)
    {
        struct buffer_data_t* rdi_7 = ((((int64_t)ptr->index2) << 4) + &data_4040);
        if (rdi_7->unknown3 != 0)
        {
            uint8_t rdx_11 = (rdx_10->unknown4 ^ rdi_7->unknown4);
            ptr->unknown3 = 1;
            ptr->unknown4 = rdx_11;
        }
    }
}
```

The next interesting bit is field `unknown4`. We can see the two lookup-items are used as operants and the result is assigned to the current item `unknown4`. We can rename this to `value` or something alike. Also we can see that `unknown3` is always set to `1` and tested against `0`. This strongly smells like a boolean value, lets call it `flag` for the lack of a better name.

Lets have a look at the whole function again.

```c
struct buffer_data_t* sub_1220()
{
    struct buffer_data_t* ptr = &data_4040;
    do
    {
        uint32_t type = ptr->type;
        if (type == 3)
        {
            struct buffer_data_t* rdx_10 = ((((int64_t)ptr->index1) << 4) + &data_4040);
            if (rdx_10->flag != 0)
            {
                struct buffer_data_t* rdi_7 = ((((int64_t)ptr->index2) << 4) + &data_4040);
                if (rdi_7->flag != 0)
                {
                    uint8_t rdx_9 = (rdx_10->value ^ rdi_7->value);
                    ptr->flag = 1;
                    ptr->value = rdx_9;
                }
            }
        }
        else
        {
            if ((type == 1 || type == 2))
            {
                struct buffer_data_t* rdx_3 = ((((int64_t)ptr->index1) << 4) + &data_4040);
                if (rdx_3->flag != 0)
                {
                    struct buffer_data_t* rdi_3 = ((((int64_t)ptr->index2) << 4) + &data_4040);
                    if (rdi_3->flag != 0)
                    {
                        uint8_t rdi_4 = (rdi_3->value + rdx_3->value);
                        ptr->flag = 1;
                        ptr->value = rdi_4;
                    }
                }
            }
            if (type == 4)
            {
                struct buffer_data_t* rdx_6 = ((((int64_t)ptr->index1) << 4) + &data_4040);
                if (rdx_6->flag != 0)
                {
                    uint8_t value = rdx_6->value;
                    ptr = &ptr[1];
                    *(uint8_t*)((char*)ptr - 4) = 1;
                    *(uint8_t*)((char*)ptr - 3) = value;
                    if (ptr == &stdin)
                    {
                        break;
                    }
                    continue;
                }
            }
        }
        ptr = &ptr[1];
    } while (ptr != &stdin);
    return ptr;
}
```

This looks way more readable. We loop the array of `buffer_data_t` items. For each item with a valid operation value (1-4) we calculate the operation, set `value` to the result and `flag` to `true`. The operands are also items within the array. Now we have the operation types. Operation `1` and operation `2` are adding the values, operation `3` is an xor and operation `4` just an assign (the logic is expressed a bit weird, but thats fault of the 1:1 transfer from disassembly). In main the function is called `255` times.

Nice and easy. Lets have a look at the memory layout we found so far.

```bash
+--------------------------------------+  0x4020 (start of target values)
|                                      |
|               32 bytes               |
|                                      |
+--------------------------------------+  0x4040
|               12 bytes               |
+--------------------------------------+  0x404c (start of user input)
|                                      |
|                                      |
|              512 bytes               |
|                                      |
|                                      |
+--------------------------------------+  0x424c (end of user input)
|                                      |
|                                      |
|                                      |
|                                      |
|                                      |
|                                      |
|                                      |
|                                      |
|                                      |
+--------------------------------------+  0x5040 (stdin)
```

Now, this makes sense. Our flag is 32 bytes long, we know this since the target values are stored from `0x4020` to `0x403f`. The user input is written to `0x404c` in 16 byte chunks. We assume the same structure is used here and since the code only stores `value` and `flag` the actual offset needs to be `0x404c-0xc = 0x4040`, so right after the target value region (moving the actual end offset to `0x4240`), giving us a total of `512 bytes` for the user input or `512/16=32` items. The rest of the region is preinitialized with values.

Right, to play around with all this we extract the whole memory region. I split off the target value buffer, since it is handled somewhat seperate, from the rest. 

```python
from data import memory, output
from struct import unpack_from

for i in range(0, len(memory), 16):
    print(hex(0x4020+i),end=": ")

    type_ = unpack_from("<I", memory, offset=i+0)[0]
    target_index = i//16
    index_lhs = unpack_from("<I", memory, offset=i+4)[0]

    if 1 <= type_ <= 3:
        index_rhs = unpack_from("<I", memory, offset=i+8)[0]
        if type_ == 1 or type_ == 2:
            print(f"value[{target_index}] = value[{index_lhs}] + value[{index_rhs}]")
        elif type_ == 3:
            print(f"value[{target_index}] = user_input[{index_lhs}] ^ user_input[{index_rhs}]")
    elif type_ == 4:
        print(f"value[{target_index}] = value[{index_lhs}]")
```

This gives us a sequence of operations. 

```bash
0x4240: 0x4250: value[35] = value[1] + value[34]
0x4260: 0x4270: value[37] = value[2] + value[36]
...
0x45c0: 0x45d0: value[91] = value[29] + value[90]
0x45e0: 0x45f0: value[93] = value[30] + value[92]
0x4600: 0x4610: value[95] = value[31] + value[94]
0x4620: 0x4630: value[97] = user_input[33] ^ user_input[96]
0x4640: 0x4650: value[99] = user_input[35] ^ user_input[98]
0x4660: 0x4670: value[101] = user_input[37] ^ user_input[100]
...
0x49e0: 0x49f0: value[157] = user_input[93] ^ user_input[156]
0x4a00: 0x4a10: value[159] = user_input[95] ^ user_input[158]
0x4a20: 0x4a30: value[161] = value[97] + value[160]
0x4a40: 0x4a50: value[163] = value[99] + value[162]
...
0x4de0: 0x4df0: value[221] = value[157] + value[220]
0x4e00: 0x4e10: value[223] = value[159] + value[222]
0x4e20: value[224] = value[161]
...
0x5000: value[254] = value[221]
0x5010: value[255] = value[223]
```

Looks good so far. What we have to do is, to do the operations in reverse order, and also take care to replace the final assignment with the values coming from the target value array. So instead of printing the values, we track the operations in an array. Note that the `target address` is changed for operation type `4` (assignment), to point to the target value array.

```python
ops = []

for i in range(0, len(memory), 16):
    type_ = unpack_from("<I", memory, offset=i+0)[0]
    target_index = i//16
    index_lhs = unpack_from("<I", memory, offset=i+4)[0]

    if 1 <= type_ <= 3:
        index_rhs = unpack_from("<I", memory, offset=i+8)[0]
        ops.append((type_, target_index*16+OFFSET_VALUE, index_lhs, index_rhs))
    elif type_ == 4:
        ops.append((type_, (i-0xe00)//16, index_lhs, -1))
```

In the next step, we walk backwards through the operations and calculate the reverse of the functions.

```python
mem = bytearray(memory)
for type_, dst, idx1, idx2 in ops[::-1]:
    idx1 = idx1 * 16 + OFFSET_VALUE
    idx2 = idx2 * 16 + OFFSET_VALUE
    if type_ == 4:
        mem[idx1] = output[dst]
    if type_ == 1 or type_ == 2:
        mem[idx1] = (mem[dst] - mem[idx2])&0xff
        mem[idx2] = (mem[dst] + mem[idx1])&0xff
    if type_ == 3:
        mem[idx1] = mem[dst] ^ mem[idx2]
        mem[idx2] = mem[dst] ^ mem[idx1]
```

After this is done, the only thing to do is to read the `32` first items from the memory, which should contain the flag (see the full script [`here`](solve.py)).

```python
for i in range(OFFSET_VALUE, 32*16, 16):
    print(chr(mem[i]),end="")
```

Flag `FLAG{INTr0dUction_70_R3v3R$1NG1}`