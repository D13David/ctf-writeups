# Urmia CTF 2024

## REVNG

> Numbers hide what words cannot reveal. Can you uncover the secret encoded within them? Investigate carefully; the answer lies deep within the sequence.
>
>  Author: n/a
>
> [`REVNG`](REVNG), [`flag.enc`](flag.enc)

Tags: _rev_

## Solution
This challenge comes with a binary and a file called `flag.enc` which contains probably the encoded flag. Opening the binary in [`Binary Ninja`](https://binary.ninja/) first to get a rough overview. The `main` function is fairly small. But one thing that stands out is, the program was originally written in `c++` which we keep in the back of our heads, since symbols are stripped and we have to reconstruct data structures on our own, to follow the program logic.

Lets see what we have here: The program expects three arguments, the first argument is always the path of the executable, the both remaining arguments are called `src` and `dst` in the `usage message` which is printed when we run the programm with less than three arguments.

If we pass the right amount of arguments, `time(nullptr)` is called and saved for later use. Then the arguments are used to construct two [`std::basic_string`](https://en.cppreference.com/w/cpp/string/basic_string) instances (`sub_4098`). The temporary allocator objects are needed to let std::basic_string allocate any memory.

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    int32_t result;
    
    if (argc == 3)
    {
        int32_t rax_7 = time(nullptr);
        void var_88;
        std::allocator<char>::allocator(&var_88);
        void var_68;
        sub_4098(&var_68, argv[1]);
        std::allocator<char>::~allocator(&var_88);
        std::allocator<char>::allocator(&var_88);
        void var_48;
        sub_4098(&var_48, argv[2]);
        std::allocator<char>::~allocator(&var_88);
        void var_c8;
        sub_3644(&var_c8, &var_68);
        void var_a8;
        sub_26a9(&var_a8, 0, sub_3ee4(&var_c8), rax_7);
        sub_3523(&var_88, &var_a8, &var_c8);
        sub_37d9(&var_48, &var_88, rax_7);
        result = 0;
        sub_3e9c(&var_88);
        sub_2a10(&var_a8);
        sub_3e9c(&var_c8);
        std::string::~string(&var_48);
        std::string::~string(&var_68);
    }
    else
    {
        std::ostream::operator<<(std::operator<<<std::char_traits<char> >(std::operator<<<std::char_traits<char> >(std::operator<<<std::char_traits<char> >(&std::cerr, "Usage: "), *(uint64_t*)argv), " <src> <dst>"), std::endl<char>);
        result = 1;
    }
    
    *(uint64_t*)((char*)fsbase + 0x28);
    
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
        return result;
    
    __stack_chk_fail();
    /* no return */
}
```

If we pass the right amount of arguments, `time(nullptr)` is called and saved for later use. Then the arguments are used to construct two [`std::basic_string`](https://en.cppreference.com/w/cpp/string/basic_string) instances (`sub_4098`). The temporary allocator objects are needed to let std::basic_string allocate any memory. We can easily rename a few things of the first part already, for better readability.

```c
/// ...
int32_t currentTime = time(nullptr);
void tmp;
std::allocator<char>::allocator(&tmp);
void sourceFileName;
create_string(&sourceFileName, argv[1]);
std::allocator<char>::~allocator(&tmp);
std::allocator<char>::allocator(&tmp);
void destFileName;
create_string(&destFileName, argv[2]);
std::allocator<char>::~allocator(&tmp);
/// ...
```

The original code could have been looked something like this:

```c
int main(int argc, char** argv)
{
    if (argc == 3)
    {
        std::time_t currentTime = std::time(nullptr);
        std::string sourceFileName = argv[1];
        std::string destFileName = argv[2];

        /// ... more code here
    }
    else
    {
        std::cerr << "Usage: " << *argv << " <src> <dst>" << std::endl;
    }
}
```

Ok, thats not very interesting so far, but there is more of course, lets look at `sub_3644`.

```c
int64_t* sub_3644(int64_t* arg1, std::string_1* arg2)
{
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    void var_228;
    std::ifstream::ifstream(&var_228, arg2);
    
    if (std::ifstream::is_open(&var_228) != 1)
    {
        std::ostream::operator<<(std::operator<<<char>(std::operator<<<std::char_traits<char> >(&std::cerr, "Error opening file: ")), std::endl<char>);
        exit(1);
        /* no return */
    }
    
    sub_3d30(arg1);
    
    while (true)
    {
        char __s;
        std::istream::__istream_type* rax_9 = std::istream::read(&var_228, &__s, 1);
        
        if (std::basic_ios<char, std::char_traits<char> >::operator bool(((char*)rax_9 + *(uint64_t*)(rax_9->_vptr.basic_istream - 0x18))) == 0)
            break;
        
        char __s_1 = __s;
        sub_3f4c(arg1, &__s_1);
    }
    
    std::ifstream::close(&var_228);
    std::ifstream::~ifstream(&var_228);
    *(uint64_t*)((char*)fsbase + 0x28);
    
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
        return arg1;
    
    __stack_chk_fail();
    /* no return */
}
```

This one is easy, since many names Binary Ninja thankfully reconstructed for us. The function just reads all bytes of a given file, but what does it return? Function `sub_3d30` triggers a call chain with very less logic, but eventually will initialize a small memory chunk with some values:

```c
*(uint64_t*)arg1 = 0;
arg1[1] = 0;
arg1[2] = 0;
return arg1;
```

Function `sub_3f4c` ends up executing this logic:

```c
int64_t sub_424a(int64_t* arg1, int64_t arg2)
{
    if (arg1[1] == arg1[2])
    {
        int64_t rax_11 = sub_450d(arg2);
        sub_45ac(arg1, sub_455c(arg1), rax_11);
    }
    else
    {
        int64_t rax_4 = sub_450d(arg2);
        sub_451f(arg1, arg1[1], rax_4);
        arg1[1] += 1;
    }
    
    return sub_4752(arg1);
}
```

We can guess that this is adding a single byte to a buffer or something. If `arg1[1]` is idendical when `arg1[2]` another path is chosen, probably to increase the memory to make space for the new element. This `could` be something like [`https://en.cppreference.com/w/cpp/container/vector`](std::vector<uint8_t>). Interestingly, we get more hints by checking function `sub_45ac`. There a validation is done that gives away the original function name `vector::_M_realloc_insert`, so we basically have an std::vector here. The std::vector holds three values, a pointer to the allocated memory region, a pointer indicating the next free element and a pointer pointing to the end of the allocated memory region.

Back to `sub_3644`, the function reads the content of a file and returns a std::vector with the content, we therefore rename the function to `read_content_from_file`. The pendant is `sub_37d9` where we can see `destFileName` is passed into. Lets check this function first.

```c
int64_t sub_37d9(std::string_1* arg1, int64_t* arg2, int32_t arg3)
{
    int32_t __s = arg3;
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    void var_228;
    std::ofstream::ofstream(&var_228, arg1);
    
    if (std::ofstream::is_open(&var_228) != 1)
    {
        std::ostream::operator<<(std::operator<<<char>(std::operator<<<std::char_traits<char> >(&std::cerr, "Error opening file: ")), std::endl<char>);
        exit(1);
        /* no return */
    }
    
    int64_t var_240 = sub_3f82(arg2);
    int64_t var_238 = sub_3fce(arg2);
    
    while (sub_401e(&var_240, &var_238) != 0)
    {
        char __s_1 = *(uint8_t*)sub_4082(&var_240);
        std::ostream::write(&var_228, &__s_1);
        sub_405e(&var_240);
    }
    
    std::ostream::write(&var_228, &__s);
    std::ofstream::close(&var_228);
    std::ofstream::~ofstream(&var_228);
    
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
        return (rax - *(uint64_t*)((char*)fsbase + 0x28));
    
    __stack_chk_fail();
    /* no return */
}
```

Yes, a filestream is opened and content is written to. There are again some remnants of C++. Functions `sub_3f82` and `sub_3fce` giving us `begin()` and `end()` iterators, which are used to iterate the vector element by element. Function `sub_401e` only compares both iterators and `sub_4082` is dereferencing the current element, while `sub_405e` increments the iterator. 

The loop looks something like this:
```c++
for (auto it : fileContent) {
    file.write((const char*)&it, 1);
}
```

One interesting bit is, that the function also writes the timestamp to the file. We keep this in mind and rename the function to `write_content_to_file` and our `main` function looks now like this:

```c++
int main(int argc, char** argv)
{
    if (argc == 3)
    {
        std::time_t currentTime = std::time(nullptr);
        std::string sourceFileName = argv[1];
        std::string destFileName = argv[2];

        std::vector<uint8_t> sourceBuffer;
        read_byte_from_file(sourceBuffer, sourceFileName);

        std::vector<uint8_t> destBuffer;

        /// .. more code here
        // sub_26a9(&var_a8, 0, sub_3ee4(&sourceBuffer), currentTime);
        // sub_3523(&tmp, &var_a8, &sourceBuffer);

        write_content_to_file(destFileName, destBuffer, currentTime);
    }
    else
    {
        std::cerr << "Usage: " << *argv << " <src> <dst>" << std::endl;
    }
}
```

Lets have a look at function `sub_26a9` next:

```c
int64_t* sub_26a9(int64_t* arg1, int32_t arg2, int32_t arg3, int32_t arg4)
{
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    void var_38;
    sub_2862(&var_38, arg4);
    sub_2952(arg1);
    
    for (int32_t i = arg2; arg3 > i; i += 1)
        sub_2a58(arg1, &i);
    
    int32_t var_40 = 0;
    
    while (true)
    {
        int64_t rax_18;
        rax_18 = ((int64_t)var_40) < sub_2ad8(arg1);
        
        if (rax_18 == 0)
            break;
        
        int32_t* rax_12 = sub_2b00(arg1, ((int64_t)sub_28da(&var_38, var_40, sub_2ad8(arg1))));
        sub_2b36(sub_2b00(arg1, ((int64_t)var_40)), rax_12);
        var_40 += 1;
    }
    
    *(uint64_t*)((char*)fsbase + 0x28);
    
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
        return arg1;
    
    __stack_chk_fail();
    /* no return */
}
```

This looks complicated at first, many more function calls from here... Lets start from the top, `sub_2862` initializes yet another data structure with some weird numbers. Function `sub_2952` we already, is constructing an empty `std::vector` again. Then there is the loop starting from `arg2` going up to `arg3` calling `sub_2a58(arg1, &i);` which is basically just inserting `i` to the before created vector.

```c
int32_t* sub_2862(int32_t* arg1, int32_t arg2)
{
    *(uint32_t*)arg1 = arg2;
    arg1[1] = 0x19660d;
    arg1[2] = 0x3c6ef35f;
    arg1[3] = 0xffffffff;
    return arg1;
}
```

Since we know the function is called like `sub_26a9(&var_a8, 0, sub_3ee4(&sourceBuffer), currentTime);` we see that the loop starts at value `0` and guess `sub_3ee4` just gives us the size of the `sourceBuffer` vector.

Well, we don't guess, we know the first element of the vector data layout is the pointer to the `start` of the memory and the second is the pointer to the `next free` element, so subtracting both pointers gives us the number of elements currently stored within the vector.

```c
int64_t sub_3ee4(int64_t* arg1)
{
    return (arg1[1] - *(uint64_t*)arg1);
}
```

Perfect, we are looping from `0` to `buffer.size()` and storing the indices (0, 1, 2, ...) into an `std::vector<int>`. Lets have a look at the other loop. Function `sub_2ad8` is basically identical to `sub_3ee4` but divides the byte difference by `four`, since we hold 4 bytes per element, this gives us again the size of the vector. Function `sub_2b00` is again a vector operation and gives us a pointer to an vector element with offset from the first element, basically [`std::vector::at`](https://en.cppreference.com/w/cpp/container/vector/operator_at). Also `sub_2b36` is swapping two elements [`std::swap`](https://en.cppreference.com/w/cpp/algorithm/swap) Lets see what we have so far:

```c
initialize_struct_with_values(&var_38, arg4);
construct_vector_int32(arg1);

for (int32_t i = arg2; arg3 > i; i += 1)
    push_back_vector_int32(arg1, &i);

int32_t var_40 = 0;

while (true)
{
    int64_t rax_18;
    rax_18 = ((int64_t)var_40) < size_vector_int32(arg1);
    
    if (rax_18 == 0)
        break;
    
    int32_t* rax_12 = vector_at_int32(arg1, ((int64_t)sub_28da(&var_38, var_40, size_vector_int32(arg1))));
    std::swap(vector_at_int32(arg1, ((int64_t)var_40)), rax_12);
    var_40 += 1;
}
```

Not so bad anymore... Lets check `sub_28da`.

```c
uint64_t sub_289e(int32_t* arg1)
{
    *(uint32_t*)arg1 = (((arg1[1] * *(uint32_t*)arg1) + arg1[2]) & arg1[3]);
    return ((uint64_t)*(uint32_t*)arg1);
}

uint64_t sub_28da(int32_t* arg1, int32_t arg2, int32_t arg3)
{
    return ((uint64_t)(arg2 + (COMBINE(0, sub_289e(arg1)) % (arg3 - arg2))));
}
```

The functions use the values from the struct that where initialized in `initialize_struct_with_values`. This can be cleaned up a bit but we can see `arg[3]` is used as a bitmask and stays constant (`0xffffffff`), also `arg[2]` and `arg[1]` stay constant (`0x3c6ef35f`, `0x19660d`) but `arg[0]` changes with every function call (initialized with the timestamp). This certainly looks like some sort of random number generator, where the timestamp is used as a seed, ok lets rename `initialize_struct_with_values` to `initialize_rng`, then we have:

```c++
void initialize_rng(rng_t& rng, uint32_t seed)
{
    rng.seed = seed;
    rng.mul = 0x19660d;
    rng.add = 0x3c6ef35f;
    rng.mask = 0xffffffff;
}

uint64_t next_value(rng_t& rng)
{
    rng.seed = (rng.mul * rng.seed + rng.add) & rng.mask;
    return rng.seed;
}

uint64_t next_value_in_range(rng_t& rng, int32_t start, int32_t end)
{
    return start + (next_value(rng) % (end - start));
}
```

So, after cleaning up the function even further we are left with the following:

```c++
void generate_number_vector(std::vector<int>& result, int32_t start, int32_t end, std::time_t currentTime)
{
    rng_t rng;
    initialize_rng(rng, currentTime);

    for (int32_t i = start; i < end; ++i) {
        result.push_back(i);
    }

    for (int32_t i = 0; i < result.size(); ++i)
    {
        int index = result.at(next_value_in_range(rng, i, result.size()));
        std::swap(result.at(i), index);
    }
}
```

While our main function looks like this:

```c++
int main(int argc, char** argv)
{
    if (argc == 3)
    {
        std::time_t currentTime = std::time(nullptr);
        std::string sourceFileName = argv[1];
        std::string destFileName = argv[2];

        std::vector<uint8_t> sourceBuffer;
        read_byte_from_file(sourceBuffer, sourceFileName);

        std::vector<int> numbers;
        generate_number_vector(numbers, 0, sourceBuffer.size(), currentTime);

        std::vector<uint8_t> destBuffer;
        // sub_3523(&destBuffer, &numbers, &sourceBuffer);

        write_content_to_file(destFileName, destBuffer, currentTime);
    }
    else
    {
        std::cerr << "Usage: " << *argv << " <src> <dst>" << std::endl;
    }
}
```

Ah, we are getting really close. Lets check for the last function `sub_3523`. It takes the numbers vector and the source buffer as input.

```c
int64_t* sub_3523(int64_t* arg1, int64_t* arg2, int64_t* arg3)
{
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    sub_3d30(arg1);
    int64_t var_28 = 0;
    
    while (true)
    {
        int64_t rax_18;
        rax_18 = var_28 < sub_3ee4(arg3);
        
        if (rax_18 == 0)
            break;
        
        char var_31 = sub_34f4((((uint32_t)*(uint8_t*)sub_3f08(arg3, var_28)) ^ *(uint32_t*)sub_3f28(arg2, (COMBINE(0, var_28) % size_vector_int32(arg2)))), 5);
        sub_3f4c(arg1, &var_31);
        var_28 += 1;
    }
    
    *(uint64_t*)((char*)fsbase + 0x28);
    
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
        return arg1;
    
    __stack_chk_fail();
    /* no return */
}
```

With everything we did before this is no real issue anymore. Function `sub_3d30` constructs our output vector. Then we loop over the `source buffer` (`sub_3ee4` gives is the size, `sub_3f08` gives us the element at the loop index and `sub_3f4c` adds the resulting value to our output buffer). The source buffer element is xored with a element of our number buffer. So lets quickly rewrite this:

```c++
void encrypt_data(std::vector<uint8_t>& output, const std::vector<int>& key, const std::vector<uint8_t>& sourceData)
{
    for (int32_t i = 0; i < sourceData.size(); ++i)
    {
        char value = sub_34f4(sourceData[i] ^ key[i % key.size()], 5);
        output.push_back(value);
    }
}
```

There is still function `sub_34f4`, but this one is easy, it swaps two bit chunks of a byte.

```c
uint64_t swap_bits(int32_t arg1, char arg2) __pure
{
    return ((uint64_t)((arg1 << (8 - arg2)) | (arg1 >> arg2)));
}
```

The final result can be found [`here`](main.cpp). Now we know what the program is doing, we can easily write a script that reads the seed from the file, generates the correct sequence for the xor key and then decodes the flag.

```python
from ctypes import c_uint32
from struct import unpack_from

t = 0

def sub_289e():
    global t
    t = c_uint32(c_uint32(0x19660d * t).value + 0x3c6ef35f).value & 0xffffffff
    return t

def sub_28da(index, size):
    return index + (sub_289e() % (size - index))

def swap(a):
    return (((a&0xf8)>>3) | ((a&7) << 5))&0xff

data = open("flag.enc", "rb").read()
flag = data[0:-4]
t = unpack_from("<I", data, offset=len(flag))[0]
buffer = []
for i in range(len(flag)):
    buffer.append(i)

for i in range(len(buffer)):
    idx1 = sub_28da(i, len(buffer))
    idx2 = i
    buffer[idx2], buffer[idx1] = buffer[idx1], buffer[idx2]

for i in range(len(flag)):
    c = swap(flag[i]) ^ buffer[i]
    print(chr(c),end="")
```

Running this on `flag.enc` gives us the flag.

Flag `UCTF{S33D1N6_Th3_PRNG_F0r_FUN_In_Urm14!!!}`