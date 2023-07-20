#include <cstdio>

typedef unsigned long ulong;
typedef unsigned int uint;

int checkBear(ulong param_1)
{
    int uVar1;

    if ((param_1 & 1) == 0) {
        if (param_1 % 3 == 2) {
            if (param_1 % 5 == 1) {
                if (param_1 + ((param_1 - param_1 / 7 >> 1) + param_1 / 7 >> 2) * -7 == 3) {
                    if (param_1 % 0x6d == 0x37) {
                        uVar1 = 1;
                    }
                    else {
                        uVar1 = 0;
                    }
                }
                else {
                    uVar1 = 0;
                }
            }
            else {
                uVar1 = 0;
            }
        }
        else {
            uVar1 = 0;
        }
    }
    else {
        uVar1 = 0;
    }
    return uVar1;
}

int checkVolcano(ulong param_1)

{
    int uVar1;
    ulong local_18;
    ulong local_10;

    local_18 = 0;
    for (local_10 = param_1; local_10 != 0; local_10 = local_10 >> 1) {
        local_18 = local_18 + ((uint)local_10 & 1);
    }
    if (local_18 < 0x11) {
        uVar1 = 0;
    }
    else if (local_18 < 0x1b) {
        uVar1 = 1;
    }
    else {
        uVar1 = 0;
    }
    return uVar1;
}

int main()
{
    for (ulong i = 0; i < 0xffffffff; ++i)
    {
        if (checkBear(i) == 1 && checkVolcano(i))
            printf("%u\n", i);
    }
}