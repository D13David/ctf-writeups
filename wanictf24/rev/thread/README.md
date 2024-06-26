# WaniCTF 2024

## Thread

> ワ...ワァ...!?
>
>  Author: hi120ki
>
> [`rev-thread.zip`](rev-thread.zip)

Tags: _rev_

## Solution
For this challenge we get another binary to reverse. Opening it in `Binary Ninja` gives us the following `main` function.

```c
int32_t main(int32_t argc, char** argv, char** envp)
{
    void* fsbase;
    int64_t rax = *(uint64_t*)((char*)fsbase + 0x28);
    printf("FLAG: ");
    void var_48;
    int32_t rax_4;
    if (__isoc99_scanf("%45s", &var_48) != 1)
    {
        puts("Failed to scan.");
        rax_4 = 1;
    }
    else if (strlen(&var_48) != 0x2d)
    {
        puts("Incorrect.");
        rax_4 = 1;
    }
    else
    {
        for (int32_t i = 0; i <= 0x2c; i = (i + 1))
        {
            *(uint32_t*)((((int64_t)i) << 2) + &data_4140) = ((int32_t)*(uint8_t*)(&var_48 + ((int64_t)i)));
        }
        pthread_mutex_init(&data_4100, nullptr);
        void var_1b8;
        for (int32_t i_1 = 0; i_1 <= 0x2c; i_1 = (i_1 + 1))
        {
            void var_278;
            *(uint32_t*)(&var_278 + (((int64_t)i_1) << 2)) = i_1;
            pthread_create(((((int64_t)i_1) << 3) + &var_1b8), 0, sub_1289, (&var_278 + (((int64_t)i_1) << 2)));
        }
        for (int32_t i_2 = 0; i_2 <= 0x2c; i_2 = (i_2 + 1))
        {
            pthread_join(*(uint64_t*)(&var_1b8 + (((int64_t)i_2) << 3)), 0);
        }
        pthread_mutex_destroy(&data_4100);
        int32_t var_27c_1 = 0;
        while (true)
        {
            if (var_27c_1 > 0x2c)
            {
                puts("Correct!");
                rax_4 = 0;
                break;
            }
            if (*(uint32_t*)((((int64_t)var_27c_1) << 2) + &data_4140) != *(uint32_t*)((((int64_t)var_27c_1) << 2) + &data_4020))
            {
                puts("Incorrect.");
                rax_4 = 1;
                break;
            }
            var_27c_1 = (var_27c_1 + 1);
        }
    }
    *(uint64_t*)((char*)fsbase + 0x28);
    if (rax == *(uint64_t*)((char*)fsbase + 0x28))
    {
        return rax_4;
    }
    __stack_chk_fail();
    /* no return */
}
```

Lets clean this up a bit by renaming some of the variables to something more meaningful. The program reads a user input with max 45 characters and checks then if the input really is 45 characters long. We can assume the input is the flag.

```c
printf("FLAG: ");
char userInput[45];
int32_t result;
if (__isoc99_scanf("%45s", &userInput) != 1)
{
    puts("Failed to scan.");
    result = 1;
}
else if (strlen(&userInput) != 45)
{
    puts("Incorrect.");
    result = 1;
}
else
{
    // ... rest here
}
```

In case the check passed the program copies the user input to some global memory buffer, creates one mutex and then spawns `45` threads. Eeach of the threads gets the `index` of the thread passed in as parameter. After all threas are spawned, the programm waits 'till all threads end their specifiy workload and destroys the mutex afterwards.

```c
for (int32_t i = 0; i <= 44; i = (i + 1))
{
    g_UserInput[((int64_t)i)] = ((int32_t)userInput[((int64_t)i)]);
}
pthread_mutex_init(&g_GlobalLock, nullptr);
pthread_t threads[0x2d];
for (int32_t i_1 = 0; i_1 <= 44; i_1 = (i_1 + 1))
{
    uint32_t threadParams[0x2d];
    threadParams[((int64_t)i_1)] = i_1;
    pthread_create(&threads[((int64_t)i_1)], 0, theadFunc, &threadParams[((int64_t)i_1)]);
}
for (int32_t i_2 = 0; i_2 <= 44; i_2 = (i_2 + 1))
{
    pthread_join(threads[((int64_t)i_2)], 0);
}
pthread_mutex_destroy(&g_GlobalLock);
// ...
```

Finally the `user input` is compared with another buffer, we call this `encoded flag` here. If all the entries are identical the program prints `Correct!`, otherwise `Incorrect.`. This seems to be a typical flag checker. 

```c
int32_t index = 0;
while (true)
{
    if (index > 44)
    {
        puts("Correct!");
        result = 0;
        break;
    }
    if (g_UserInput[((int64_t)index)] != g_EncodedFlag[((int64_t)index)])
    {
        puts("Incorrect.");
        result = 1;
        break;
    }
    index = (index + 1);
}
```

Now we need to find out what the threads are actually doing.

```c
int64_t theadFunc(int32_t* param)
{
    int32_t threadIndex = *(uint32_t*)param;
    int32_t i = 0;
    while (i <= 2)
    {
        pthread_mutex_lock(&g_GlobalLock);
        int32_t operation = ((threadIndex + g_ThreadLoopCounter[((int64_t)threadIndex)]) % 3);
        if (operation == 0)
        {
            g_UserInput[((int64_t)threadIndex)] = (g_UserInput[((int64_t)threadIndex)] * 3);
        }
        if (operation == 1)
        {
            g_UserInput[((int64_t)threadIndex)] = (g_UserInput[((int64_t)threadIndex)] + 5);
        }
        if (operation == 2)
        {
            g_UserInput[((int64_t)threadIndex)] = (g_UserInput[((int64_t)threadIndex)] ^ 0x7f);
        }
        g_ThreadLoopCounter[((int64_t)threadIndex)] = (g_ThreadLoopCounter[((int64_t)threadIndex)] + 1);
        i = g_ThreadLoopCounter[((int64_t)threadIndex)];
        pthread_mutex_unlock(&g_GlobalLock);
    }
    return 0;
}
```

Most of the function was `cleaned up` already, there was just one array that contains a counter per each thread, we call it here `ThreadLoopCounter`. The counters are initialized with zero, then are icreased for every loop. Each thread works on a specific character of the user input and loops `3 times` doing a sequence of operations on the flag character. The operation is calculated by adding the thread loop counter (`ThreadLoopCounter`) to the thread index (`threadIndex`) modulo 3. Looking at this, the loop counter could also just have been a local variable, probably.. 

The operations are:

```bash
0 = flag[index] = flag[index] * 3
1 = flag[index] = flag[index] + 5
2 = flag[index] = flag[index] ^ 0x7f
```

We have to work our way back now, starting with the values of `g_EncodedFlag` and undoing the operation sequence for each character. The following script does exactly this and running it gives us the script.

```python
data = [168,138,191,165,765,89,222,36,101,271,222,35,349,66,44,222,9,101,222,81,239,319,36,83,349,72,83,222,9,83,331,36,101,222,54,83,349,18,74,292,63,95,334,213,11]

or threadIndex in range(len(data)):
    char = data[threadIndex]
    for i in range(3):
        operation = (threadIndex + (2-i)) % 3

        if operation == 0:
            char = char // 3
        elif operation == 1:
            char = char - 5
        else:
            char = char ^ 0x7f
    data[threadIndex] = char

for c in data: print(chr(c), end="")
```

Flag `FLAG{c4n_y0u_dr4w_4_1ine_be4ween_4he_thread3}`