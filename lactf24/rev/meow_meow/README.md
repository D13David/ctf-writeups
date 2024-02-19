# LACTF 2023

## meow meow

> When I was running my cyber lab, I asked if anyone doesn't like cats, and no one raised their hard, so it is FINAL, **CATS >> DOGS**!!!!! As a test, you need to find the cat in the sea of dogs in order to get the flag.
> 
> Note: data.zip expands to around 575 MB.
> 
> Author: burturt
> 
> [`data.zip`](data.zip)
> [`meow`](meow)

Tags: _rev_

## Solution
We have a stripped binary that we want to look at first with `Ghidra`. Since it's stripped we have to find the main by inspecting `entry`. But easily enough we get the main functionality. Lets break this down a bit.

The first part simply prints a message and reads some user input. Then the length of the input is calculated and tested to be a multiple of `5`. If not the program prints `WOOOOOOOF BARK BARK BARK` and exists.

```c++
printf("Meow Meow? ");
fgets((char *)&local_138,0x5f,stdin);
sVar3 = strcspn((char *)&local_138,"\n");
*(undefined *)((long)&local_138 + sVar3) = 0;
sVar3 = strlen((char *)&local_138);
if (sVar3 == (sVar3 / 5) * 5) {
    // ...
}
else {
    puts("WOOOOOOOF BARK BARK BARK");
    uVar4 = 1;
}
return uVar4;
```

The next part loops over the user input and calls `FUN_00101225`. The function basically maps all lower case characters `a-z` to `0-25` as well as `_` to `26`, `{` to `27` and `}` to `28`. In any other case the function returns `-1` causing the program to print a error message and exit. This strongly smells like a flag format validation, so we can assume the flag is all lower-case `a-z` plus `{`, `}` and `_`.

```c++
for (local_1c = 0; uVar5 = (ulong)local_1c, sVar3 = strlen((char *)&local_138), uVar5 < sVar3; local_1c = local_1c + 1) {
    uVar1 = FUN_00101225((int)*(char *)((long)&local_138 + (long)local_1c));
    *(undefined *)((long)&local_1a8 + (long)local_1c) = uVar1;
    if (*(char *)((long)&local_1a8 + (long)local_1c) == -1) {
        puts("WOOOOOOOF BARK BARK BARK");
        return 2;
    }
}
```

```c++
int FUN_00101225(byte param_1)
{
  int iVar1;
  ushort **ppuVar2;
  
  ppuVar2 = __ctype_b_loc();
  if (((*ppuVar2)[(char)param_1] & 0x200) == 0) {
    if (param_1 == 0x5f) {
      iVar1 = 0x1a;
    }
    else if (param_1 == 0x7b) {
      iVar1 = 0x1b;
    }
    else if (param_1 == 0x7d) {
      iVar1 = 0x1c;
    }
    else {
      iVar1 = -1;
    }
  }
  else {
    iVar1 = param_1 - 0x61;
  }
  return iVar1;
}
```

The magic numbers `0x61746164` and `0x30` expand to `data` and `0`. Then the program loops through `data0` - `data7` and checks if the files are accessible. If not again a error is printed and the program exits. This part obviously tests if the data files are present and accessible.

```c++
local_1ae = 0x61746164;
local_1aa = 0x30;
local_20 = 0;
while( true ) {
    uVar5 = (ulong)local_20;
    sVar3 = strlen((char *)&local_138);
    if (sVar3 / 5 <= uVar5) break;
    local_1aa = CONCAT11(local_1aa._1_1_,(char)local_1aa + '\x01');
    iVar2 = access((char *)&local_1ae,0);
    if (iVar2 != 0) {
        if (local_20 == 0) {
            puts(
                "Error: make sure you have downloaded and extracted the data.zip files into the same folder as the executable."
                );
            return 1;
        }
        puts("WOOOOOOOF BARK BARK BARK");
        return 3;
    }
    local_20 = local_20 + 1;
}
```

The last part of the main function runs a parallel loop on the user input calling function `FUN_0010167a`. Then `local_b8` is assumed to have the value `7`, that looks like our success path. We also can assume that `local_b8` is somehow written by the parallel loop, even though Ghidra misses this in the decompiled code. Passed into the function are the user input `local_c8`, and the user input transformed to an index array `local_c0` (as we talked about when covering function `FUN_00101225`).

```c++
local_28 = 0;
local_b8 = 0;
local_c8 = &local_138;
local_c0 = &local_1a8;
GOMP_parallel(FUN_0010167a,&local_c8,0,0);
local_28 = local_b8;
if (local_b8 == 7) {
    printf("MEOW");
    for (local_24 = 0; local_24 < 1000; local_24 = local_24 + 1) {
        putchar(0x21);
        fflush(stdout);
        usleep(1000);
    }
    putchar(10);
    uVar4 = 0;
}
else {
    puts("Woof.....");
    uVar4 = 0xffffffff;
}
```

Function `FUN_0010167a` has a lot of parallel loop boilerplate code we can ignore. The input data is split in parts and assigned each as thead workload etc... The interesting part comes afterwards. Each workload works on one of the `data` files. The file is opened. The program jumps to an offset (`local_24*0x74`) and reads `0x74` bytes from this position. From this buffer the next offset is read whereas the index is coming from `local_2d = param_1[1][local_20 * 5 + local_28]`, that is our flag in index form (remember function `FUN_00101225`).

```c++
void FUN_0010167a(char **param_1)
{
  // ... boilerplate

  for (; local_20 < iVar6; local_20 = local_20 + 1) {
    local_33 = 0x61746164; // "data"
    local_2f = (ushort)(byte)((char)local_20 + 0x31); // '0' + worker index
    local_2c = open((char *)&local_33,0);
    local_24 = 0;
    for (local_28 = 0; local_28 < 5; local_28 = local_28 + 1) {
      lseek(local_2c,(ulong)(uint)(local_24 * 0x74),0);
      local_2d = param_1[1][local_20 * 5 + local_28];
      read(local_2c,local_a8,0x74);
      local_24 = local_a8[(int)local_2d];
    }
    if (local_24 == 0x63617400) { // "cat\0"
      local_1c = local_1c + 1;
    }
  }
  LOCK();
  *(int *)(param_1 + 2) = *(int *)(param_1 + 2) + local_1c;
  UNLOCK();
  return;
}
```

So we can basically untangle the file format. Every of the data files is split into 0x74 chunks. The chunks are a list of indice to other chunks, for each of the 29 alphabet characters one index that can be looked up. Every data file handles `5` consecutive characters of the flag and for each character this index chain is done `4` times. The last index points to a pseudochunk that doesn't contain indice but `dog\0` or `cat\0` sequences. If we reach a `cat\0` at the end, the character is validated as correct.

To get the flag we can just move backwards for each character, starting at th `cat\0` position (only one is given per data file) and searching what chunk references this position. Doing this 4 times gives us the starting chunk and the index of the flag character. The [`following program`](reconstruct.cpp) will do this to reconstruct the flag.

```c++
#include <stdio.h>
#include <malloc.h>
#include <assert.h>

#define MAX_DATA_FILES  7
#define SECTION_SIZE    116
#define ALPHABET_LENGTH 29

#define MAKE_WORD(a,b,c,d) (((a)<<24)|((b)<<16)|((c)<<8)|(d))

typedef struct data_s
{
    unsigned char* buffer;
    int numSections;
    int startOffset;
} data_t;

void readDataFile(int index, data_t& data)
{
    char buffer[16];
    sprintf_s(buffer, "data%d", index);

    FILE* fp;
    if (fopen_s(&fp, buffer, "rb") != 0)
    {
        printf("failed reading '%s'\n", buffer);
        return;
    }

    fseek(fp, 0L, SEEK_END);
    long size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);

    data.buffer = (unsigned char*)malloc(size);
    if (data.buffer == NULL || fread_s(data.buffer, size, sizeof(unsigned char), size, fp) != size)
    {
        printf("failed reading '%s'\n", buffer);
    }
    else
    {
        data.startOffset = -1;
        data.numSections = size / SECTION_SIZE;

        for (int offset = SECTION_SIZE; offset < size && data.startOffset == -1; offset += SECTION_SIZE)
        {
            for (int j = offset; j < offset + SECTION_SIZE; ++j)
            {
                if ((*(unsigned int*)&data.buffer[j]) == MAKE_WORD('c','a','t',0))
                {
                    data.startOffset = j;
                    break;
                }
            }
        }

        assert(data.startOffset != -1 && "no start section found");
    }

    fclose(fp);
}

char indexToChar(int index)
{
    if (index < 26) {
        return index + 'a';
    }

    if (index == 26) {
        return '_';
    }
    if (index == 27) {
        return '{';
    }
    if (index == 28) {
        return '}';
    }

    return 0;
}

int findNextSection(const data_t& data, int currentSection, int& index)
{
    for (int section = 0; section < data.numSections; ++section)
    {
        unsigned int* offsets = (unsigned int*)&data.buffer[section * SECTION_SIZE];
        for (int offset = 0; offset < ALPHABET_LENGTH; ++offset)
        {
            if (offsets[offset] == currentSection)
            {
                index = offset;
                return section;
            }
        }
    }
    return -1;
}

int sectionOffsetToIndex(int offset, int section)
{
    return (offset - section * SECTION_SIZE) / sizeof(int);
}

int main()
{
    data_t data[7];
    for (int i = 0; i < MAX_DATA_FILES; ++i) 
    {
        readDataFile(i + 1, data[i]);
    }

    for (int i = 0; i < MAX_DATA_FILES; ++i)
    {
        int currentSection = data[i].startOffset / SECTION_SIZE;
        char buff[6] = { 0 };
        int bufferIndex = 4;

        buff[bufferIndex] = indexToChar(sectionOffsetToIndex(data[i].startOffset, currentSection));
        bufferIndex--;

        do
        {
            int index = 0;
            int nextSection = findNextSection(data[i], currentSection, index);
            if (nextSection >= 0) 
            {
                buff[bufferIndex] = indexToChar(index);
                bufferIndex--;
            }
            currentSection = nextSection;
        } while (currentSection != -1);

        printf(buff);
    }
}
```

Flag `lactf{meow_you_found_me_epcsihnxos}`