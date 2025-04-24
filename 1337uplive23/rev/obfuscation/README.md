# 1337UP LIVE CTF 2023

## Obfuscation

> I think I made my code harder to read. Can you let me know if that's true?
> 
> Author: 0xM4hm0ud
>
> [`obfuscation.zip`](obfuscation.zip)

Tags: _rev_

## Solution
For this challenge we get some obfuscated `c` code and a `output` file.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
int o_a8d9bf17d390687c168fe26f2c3a58b1[]={42, 77, 3, 8, 69, 86, 60, 99, 50, 76, 15, 14, 41, 87, 45, 61, 16, 50, 20, 5, 13, 33, 62, 70, 70, 77, 28, 85, 82, 26, 28, 32, 56, 22, 21, 48, 38, 42, 98, 20, 44, 66, 21, 55, 98, 17, 20, 93, 99, 54, 21, 43, 80, 99, 64, 98, 55, 3, 95, 16, 56, 62, 42, 83, 72, 23, 71, 61, 90, 14, 33, 45, 84, 25, 24, 96, 74, 2, 1, 92, 25, 33, 36, 6, 26, 14, 37, 33, 100, 3, 30, 1, 31, 31, 86, 92, 61, 86, 81, 38};void o_e5c0d3fd217ec5a6cd022874d7ffe0b9(char* o_0d88b09f1a0045467fd9afc4aa07208c,int o_8ce986b6b3a519615b6244d7fb2b62f8){assert(o_8ce986b6b3a519615b6244d7fb2b62f8 == 24);for (int o_b7290d834b61bc1707c4a86bad6bd5be=(0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00);(o_b7290d834b61bc1707c4a86bad6bd5be < o_8ce986b6b3a519615b6244d7fb2b62f8) & !!(o_b7290d834b61bc1707c4a86bad6bd5be < o_8ce986b6b3a519615b6244d7fb2b62f8);++o_b7290d834b61bc1707c4a86bad6bd5be){o_0d88b09f1a0045467fd9afc4aa07208c[o_b7290d834b61bc1707c4a86bad6bd5be] ^= o_a8d9bf17d390687c168fe26f2c3a58b1[o_b7290d834b61bc1707c4a86bad6bd5be % sizeof((o_a8d9bf17d390687c168fe26f2c3a58b1))] ^ (0x000000000000266E + 0x0000000000001537 + 0x0000000000001B37 - 0x00000000000043A5);};};int o_0b97aabd0b9aa9e13aa47794b5f2236f(FILE* o_eb476a115ee8ac0bf24504a3d4580a7d){if ((fseek(o_eb476a115ee8ac0bf24504a3d4580a7d,(0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00),(0x0000000000000004 + 0x0000000000000202 + 0x0000000000000802 - 0x0000000000000A06)) < (0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00)) & !!(fseek(o_eb476a115ee8ac0bf24504a3d4580a7d,(0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00),(0x0000000000000004 + 0x0000000000000202 + 0x0000000000000802 - 0x0000000000000A06)) < (0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00))){fclose(o_eb476a115ee8ac0bf24504a3d4580a7d);return -(0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03);};int o_6a9bff7d60c7b6a5994fcfc414626a59=ftell(o_eb476a115ee8ac0bf24504a3d4580a7d);rewind(o_eb476a115ee8ac0bf24504a3d4580a7d);return o_6a9bff7d60c7b6a5994fcfc414626a59;};int main(int o_f7555198c17cb3ded31a7035484d2431,const char * o_5e042cacd1c140691195c705f92970b7[]){char* o_3477329883c7cec16c17f91f8ad672df;char* o_dff85fa18ec0427292f5c00c89a0a9b4=NULL;FILE* o_fba04eb96883892ddecbb0f397b51bd7;if ((o_f7555198c17cb3ded31a7035484d2431 ^ 0x0000000000000002)){printf("\x4E""o\164 \x65""n\157u\x67""h\040a\x72""g\165m\x65""n\164s\x20""p\162o\x76""i\144e\x64""!");exit(-(0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03));};o_fba04eb96883892ddecbb0f397b51bd7 = fopen(o_5e042cacd1c140691195c705f92970b7[(0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03)],"\x72""");if (o_fba04eb96883892ddecbb0f397b51bd7 == NULL){perror("\x45""r\162o\x72"" \157p\x65""n\151n\x67"" \146i\x6C""e");return -(0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03);};int o_102862e33b75e75f672f441cfa6f7640=o_0b97aabd0b9aa9e13aa47794b5f2236f(o_fba04eb96883892ddecbb0f397b51bd7);o_dff85fa18ec0427292f5c00c89a0a9b4 = (char* )malloc(o_102862e33b75e75f672f441cfa6f7640 + (0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03));if (o_dff85fa18ec0427292f5c00c89a0a9b4 == NULL){perror("\x4D""e\155o\x72""y\040a\x6C""l\157c\x61""t\151o\x6E"" \145r\x72""o\162");fclose(o_fba04eb96883892ddecbb0f397b51bd7);return -(0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03);};fgets(o_dff85fa18ec0427292f5c00c89a0a9b4,o_102862e33b75e75f672f441cfa6f7640,o_fba04eb96883892ddecbb0f397b51bd7);fclose(o_fba04eb96883892ddecbb0f397b51bd7);o_e5c0d3fd217ec5a6cd022874d7ffe0b9(o_dff85fa18ec0427292f5c00c89a0a9b4,o_102862e33b75e75f672f441cfa6f7640);o_fba04eb96883892ddecbb0f397b51bd7 = fopen("\x6F""u\164p\x75""t","\x77""b");if (o_fba04eb96883892ddecbb0f397b51bd7 == NULL){perror("\x45""r\162o\x72"" \157p\x65""n\151n\x67"" \146i\x6C""e");return -(0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03);};fwrite(o_dff85fa18ec0427292f5c00c89a0a9b4,o_102862e33b75e75f672f441cfa6f7640,sizeof(char),o_fba04eb96883892ddecbb0f397b51bd7);fclose(o_fba04eb96883892ddecbb0f397b51bd7);free(o_dff85fa18ec0427292f5c00c89a0a9b4);return (0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00);};
```

After a bit of manual cleanup the code starts to be readable:

```c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int lut[] = {
    42, 77, 3,  8,   69, 86, 60, 99, 50, 76, 15, 14, 41, 87, 45, 61, 16,
    50, 20, 5,  13,  33, 62, 70, 70, 77, 28, 85, 82, 26, 28, 32, 56, 22,
    21, 48, 38, 42,  98, 20, 44, 66, 21, 55, 98, 17, 20, 93, 99, 54, 21,
    43, 80, 99, 64,  98, 55, 3,  95, 16, 56, 62, 42, 83, 72, 23, 71, 61,
    90, 14, 33, 45,  84, 25, 24, 96, 74, 2,  1,  92, 25, 33, 36, 6,  26,
    14, 37, 33, 100, 3,  30, 1,  31, 31, 86, 92, 61, 86, 81, 38};
void encrypt(char* input, int size) {
  assert(size == 24);
  for (int i = 0; (i < size) & !!(i < size); ++i) 
  {
    input[i] ^= lut [i % sizeof((lut))] ^ 4919;
  };
};
int get_file_size(FILE* fp) 
{
  if ((fseek(fp, 0, 2) < 0) & !!(fseek(fp, 0, 2) < 0)) 
  {
    fclose(fp);
    return -1;
  };
  int pos = ftell(fp);
  rewind(fp);
  return pos;
};

int main(int argc, const char* argv[]) 
{
  char* o_3477329883c7cec16c17f91f8ad672df;
  char* buffer = NULL;
  
  if (argc != 2) 
  {
    printf("Not enough arguments provided!");
    exit(-1);
  };
  
  FILE* fp = fopen(argv[1], "r");
  if (fp == NULL) 
  {
    perror("Error opening file");
    return -1;
  };
  
  int size = get_file_size(fp);
  buffer = (char*)malloc(size + 1);
  if (buffer == NULL) {
    perror("Memory allocation error");
    fclose(fp);
    return -1;
  };
  
  fgets(buffer, size, fp);
  fclose(fp);
  
  encrypt(buffer, size);
  fp = fopen("output","wb");
  if (fp == NULL) 
  {
    perror("Error opening file");
    return -1;
  };
  
  fwrite(buffer, size, sizeof(char), fp);
  fclose(fp);
  free(buffer);
  return 0;
};
```

The function `encrypt` is a pretty basic xor encryption. To get the flag we can write a script that reveres the process. 

```python
from ctypes import *

key = [42, 77, 3,  8,   69, 86, 60, 99, 50, 76, 15, 14, 41, 87, 45, 61, 16,
    50, 20, 5,  13,  33, 62, 70, 70, 77, 28, 85, 82, 26, 28, 32, 56, 22,
    21, 48, 38, 42,  98, 20, 44, 66, 21, 55, 98, 17, 20, 93, 99, 54, 21,
    43, 80, 99, 64,  98, 55, 3,  95, 16, 56, 62, 42, 83, 72, 23, 71, 61,
    90, 14, 33, 45,  84, 25, 24, 96, 74, 2,  1,  92, 25, 33, 36, 6,  26,
    14, 37, 33, 100, 3,  30, 1,  31, 31, 86, 92, 61, 86, 81, 38]

data = open("output", "rb").read()

for i in range(len(data)):
    print(chr(data[i]^c_int8(key[i%len(key)]^4919).value),end="")
```

Flag `INTIGRITI{Z29vZGpvYg==}`