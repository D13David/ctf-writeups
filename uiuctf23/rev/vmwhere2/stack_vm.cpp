#include <cstdio>
#include <malloc.h>
#include <ctype.h>
#include <string.h>

typedef unsigned char byte_t;
typedef unsigned int uint32_t;
//typedef unsigned long ulong;
typedef unsigned long long uint64_t;

#define VERSION2 0

#define DO_TRACE 1

#if DO_TRACE
#define TRACE(x) x
#else
#define TRACE(x)
#endif

void* load(long& size)
{
	FILE* fp;
	fp = fopen("program", "rb");
	fseek(fp, 0, SEEK_END);
	size = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	void* buffer = malloc(size);
	fread(buffer, 1, size, fp);
	fclose(fp);
	return buffer;
}

#define CONCAT11(a, b) ((a << 8) | b)

void pop(byte_t*& stack)
{
    stack = (stack - 1);
    *stack = 0xfe;
}

int run(byte_t* incode, long size)
{
#if VERSION2
    int readIndex = 0;
    int alphabetIndex = 33;
    char message[] = "uiuctf{lllllllllllllllllllllllllllllllllllllll";
    int flagIndex = sizeof(message)-2;

    const int flag[] = { 0xc6, 0x8b, 0xd9, 0xcf, 0x63, 0x60, 0xd8, 0x7b, 0xd8, 0x60, 0xf6, 0xd3, 0x7b, 0xf6, 0xd8, 0xc1, 0xcf, 0xd0, 0xf6, 0x72, 0x63, 0x75, 0xbe, 0xf6, 0x7f, 0xd8, 0x63, 0xe7, 0x6d, 0xf6, 0x63, 0xcf, 0xf6, 0xd8, 0xf6, 0xd8, 0x63, 0xe7, 0x6d, 0xb4, 0x88, 0x72, 0x70, 0x75, 0xb8, 0x75, 0x00, 0x0a, 0x21, 0x64, 0x72, 0x6f, 0x77, 0x73, 0x73, 0x61, 0x70, 0x20, 0x74, 0x63, 0x65, 0x72, 0x72, 0x6f, 0x63, 0x6e, 0x49 };
    int index = 0;
#endif

    byte_t* stackMem = (byte_t*)malloc(0x1000);

start:
    byte_t* code = incode;
    byte_t* stack = stackMem;
    uint64_t rax_10;

#if VERSION2
    readIndex = 0;

    if (flagIndex == 0)
    {
        printf("%s\n", message);
        return 0;
    }
    if (alphabetIndex == 255)
    {
        printf("foo");
        return 0;
    }
    if (alphabetIndex == '@') ++alphabetIndex;
    message[flagIndex] = alphabetIndex++;
#endif

    while (true) 
    {
        byte_t* rax_3 = code;
        code = &rax_3[1];
        uint32_t rax_5 = *rax_3;
        int offset = (int)(code - incode);
        TRACE(printf("%04x ", offset));
        switch (rax_5)
        {
        case 0:
        {
            TRACE(printf("RET\n"));
            rax_10 = 0;
            return 0;
        }
        case 1: // add s(2), s(2), s(1)
        {
            TRACE(printf("ADD %02x %02x\n", *(stack - 2), *(stack - 1)));
            *(stack - 2) = (*(stack - 2) + *(stack - 1));
            pop(stack);
            break;
        }
        case 2: // sub s(2), s(2), s(1)
        {
            TRACE(printf("SUB\n"));
            *(stack - 2) = (*(stack - 2) - *(stack - 1));
            pop(stack);
            break;
        }
        case 3: // and s(2), s(2), s(1)
        {
            TRACE(printf("AND\n"));
            *(stack - 2) = (*(stack - 2) & *(stack - 1));
            pop(stack);
            break;
        }
        case 4: // or s(2), s(2), s(1)
        {
            TRACE(printf("OR\n"));
            *(stack - 2) = (*(stack - 2) | *(stack - 1));
            pop(stack);
            break;
        }
        case 5: // xor s(2), s(2), s(1)
        {
            TRACE(printf("XOR %02x %02x\n", *(stack - 2), *(stack - 1)));
            *(stack - 2) = (*(stack - 2) ^ *(stack - 1));
            pop(stack);
            break;
        }
        case 6: // shl s(2), s(2), s(1)
        {
            TRACE(printf("SHL\n"));
            *(stack - 2) = (*(stack - 2) << *(stack - 1));
            pop(stack);
            break;
        }
        case 7: // shr s(2), s(2), s(1)
        {
            TRACE(printf("SHR\n"));
            *(stack - 2) = (*(stack - 2) >> *(stack - 1));
            pop(stack);
            break;
        }
        case 8: // read s(0)
        {
            TRACE(printf("READ\n"));
#if VERSION2
            *stack = message[readIndex++];
#else
            *stack = getchar();
#endif
            long offset = stack - stackMem;
            stack = (stack + 1);
            break;
        }
        case 9: // put s(1)
        {
            byte_t value = *(stack - 1);
            pop(stack);
            TRACE(printf("PUT #%02x\n", value));
#if !DO_TRACE
            putchar(value);
#endif
            break;
        }
        case 0xa: // push param
        {
            byte_t* rax_56 = code;
#if VERSION2
            if ((int)(code - incode) >= 0x973)
            {
                //printf("0x%02x, ", *rax_56);

                if ((stack[-(index + 1)] ^ flag[index]) == 0)
                {
                    flagIndex = flagIndex - 1;
                    alphabetIndex = 33;
                    ++index;
                }

                goto start;
            }
#endif

#if DO_TRACE
            if (isprint((int)*rax_56)) printf("PUSH %c\n", *rax_56);
            else printf("PUSH #%02x\n", *rax_56);
#endif
            code = (rax_56 + 1);
            *stack = *rax_56;
            stack = (stack + 1);
            break;
        }
        case 0xb: // jle s(1)
        {
            TRACE(printf("JLE\n"));
            if (*(stack - 1) < 0)
            {
                code = (code + (*(code + 1) | (*code << 8)));
            }
            code = (code + 2);
            break;
        }
        case 0xc: // jz s(1)
        {
            TRACE(printf("JZ "));
            if (*(stack - 1) == 0)
            {
                TRACE(printf("yes\n"));
                code = (code + (*(code + 1) | (*code << 8)));
            }
            else
            {
                TRACE(printf("no\n"));
            }
            code = (code + 2);
            break;
        }
        case 0xd: // jmp
        {
            TRACE(printf("JMP\n"));
            long offset = (long)(short)(*(code + 1) | (*code << 8));
            code = ((code + offset) + 2);
            break;
        }
        case 0xe: // pop
        {
            TRACE(printf("POP\n"));
            pop(stack);
            break;
        }
        case 0xf: // push s(1)
        {
            TRACE(printf("PUSHS %d\n", *(stack - 1)));
            *stack = *(stack - 1);
            stack = (stack + 1);
            break;
        }
#if VERSION2
        case 0x10: // bits reverse
        {
            byte_t* rax_96 = code;
            code = (rax_96 + 1);
            byte_t rax_97 = *rax_96;
            TRACE(printf("BREV %d\n", rax_97));
            uint64_t rdx_28 = rax_97;
            if (rdx_28 > (stack - stackMem))
            {
                printf("Stack underflow in reverse at 0x%p %d", (code - incode), rdx_28);
            }
            for (int i = 0; i < (rax_97 >> 1); ++i)
            {
                char rax_107 = *(stack + (i - rax_97));
                *(stack + (i - rax_97)) = *(stack + (~i));
                *((~i) + stack) = rax_107;
            }
            break;
        }
        case 0x11: // bit expand
        {
            TRACE(printf("BEXP\n"));
            byte_t var_30_1 = *(stack - 1);
            for (int var_28_1 = 0; var_28_1 <= 7; var_28_1 = (var_28_1 + 1))
            {
                *((stack - 1) + var_28_1) = (var_30_1 & 1);
                var_30_1 = (var_30_1 >> 1);
            }
            stack = (stack + 7);
            break;
        }
        case 0x12: // bit pack
        {
            TRACE(printf("BPCK\n"));
            char var_2f_1 = 0;
            for (int var_24_1 = 7; var_24_1 >= 0; var_24_1 = (var_24_1 - 1))
            {
                var_2f_1 = ((var_2f_1 << 1) | ((stack - 8)[var_24_1] & 1));
            }
            *(stack - 8) = var_2f_1;
            stack = (stack - 7);
            break;
        }
#endif
        default:
        {
            printf("unknown opcode %d", rax_5);
            break;
        }
        }
    }
	return 1;
}

int main()
{
	long size;
	byte_t* code = (byte_t*)load(size);
	run(code, size);
	free(code);
}
