#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <malloc.h>
#include <memory.h>
#include <stdlib.h>
#include <stdarg.h>

#define TRACE 0

typedef struct vm 
{
	uint32_t eip; // field_0
	bool shutdown; // field_4
	uint32_t mem[128]; // padding_4		
	uint8_t* cseg; // field_90
	uint32_t* stack; // field_98
	uint32_t esp; // field_a0
} vm_t;

#define MEM_READ(addr) vm->mem[((addr)/* * 4*/)]
#define MEM_WRITE(addr, value) vm->mem[((addr)/* * 4*/)] = (value)
#define ARG8(idx) vm->cseg[vm->eip + idx]
#define ARG32(idx) *((uint32_t*)&vm->cseg[vm->eip + idx])
#define SET_EIP(offset) vm->eip = (offset) * 6
#define INC_EIP(size) vm->eip = vm->eip + (size) * 6

FILE* log;

void trace(vm_t* vm, const char* msg, ...)
{
	char buffer[512];
	va_list args;
	va_start(args, msg);
	vsprintf_s(buffer, sizeof(buffer), msg, args);
	va_end(args);
	fprintf(log, "%04x\t%s\n", vm->eip, buffer);
}

void dump_memory(vm_t* vm)
{
	int size = sizeof(vm->mem)/4;
	for (int i = 0; i < size; i += 16)
	{
		printf("#%04x:\t", i);
		for (int j = 0; j < 16; ++j)
		{
			printf("%04x ", vm->mem[i + j]);
		}
		printf("\n");
	}
}

void vm_add(vm_t* vm) 
{
	uint32_t v1 = MEM_READ(ARG8(2));
	uint32_t v2 = MEM_READ(ARG8(3));
	MEM_WRITE(ARG8(1), v1 + v2);
#if TRACE
	trace(vm, "ADD [%d], [%d], [%d]\targs: %d, %d\t-> %d", ARG8(1), ARG8(2), ARG8(3), v1, v2, MEM_READ(ARG8(1)));
#endif
	INC_EIP(1);
}
void vm_addi(vm_t* vm) 
{
	uint32_t v1 = MEM_READ(ARG8(2));
	uint32_t v2 = ARG8(3);
	MEM_WRITE(ARG8(1), v1 + v2);
#if TRACE
	trace(vm, "ADDI [%d], [%d], %d\targs: %d, %d\t-> %d", ARG8(1), ARG8(2), ARG8(3), v1, v2, MEM_READ(ARG8(1)));
#endif
	INC_EIP(1);
}
void vm_sub(vm_t* vm) { printf("not implemented sub"); exit(0); }
void vm_subi(vm_t* vm) { printf("not implemented subi"); exit(0); }
void vm_mul(vm_t* vm) { printf("not implemented mul"); exit(0); }
void vm_muli(vm_t* vm) 
{ 
	uint32_t v1 = MEM_READ(ARG8(2));
	uint32_t v2 = ARG8(3);
	MEM_WRITE(ARG8(1), v1 * v2);
#if TRACE
	trace(vm, "MULI [%d], [%d], %d\t\targs: %d %d\t-> %d", ARG8(1), ARG8(2), ARG8(3), v1, v2, v1 * v2);
#endif
	INC_EIP(1);
}
void vm_div(vm_t* vm) { printf("not implemented div"); exit(0); }
void vm_cmp(vm_t* vm) { printf("not implemented cmp"); exit(0); }
void vm_jmp(vm_t* vm) { printf("not implemented jmp"); exit(0); }
void vm_inv(vm_t* vm) 
{ 

	uint32_t v0 = ARG8(1);
	uint32_t v1 = ARG8(2);

	vm->esp = vm->esp - v1;

	*((uint32_t*)&vm->cseg[vm->eip + 6 + 2]) = 4011; //syscall(101)

#if TRACE
	trace(vm, "INV");
#endif
	INC_EIP(1);
}
void vm_push(vm_t* vm) 
{ 
	vm->stack[vm->esp] = MEM_READ(ARG8(1));
#if TRACE
	trace(vm, "PUSH [%d]\t\targs: %d", ARG8(1), vm->stack[vm->esp]);
#endif
	vm->esp = vm->esp + 1;
	INC_EIP(1);
}
void vm_pop(vm_t* vm) 
{ 
	vm->esp = vm->esp - 1;
	MEM_WRITE(ARG8(1), vm->stack[vm->esp]);
#if TRACE
	trace(vm, "POP [%d]\t\targs: %d", ARG8(1), vm->stack[vm->esp]);
#endif
	INC_EIP(1);
}
void vm_mov(vm_t* vm) 
{
	MEM_WRITE(ARG8(1), ARG32(2));
#if TRACE
	trace(vm, "MOV [%d], %d", ARG8(1), ARG32(2));
#endif
	INC_EIP(1);
}
void vm_nop(vm_t* vm) { printf("not implemented nop"); exit(0); }
void vm_exit(vm_t* vm) 
{
	vm->shutdown = true;
	INC_EIP(1);
}
void vm_print(vm_t* vm) { printf("not implemented print"); exit(0); }
void vm_putc(vm_t* vm) 
{ 
#if TRACE
	trace(vm, "PUTC #%02x", ARG8(1));
#else
	putchar(ARG8(1));
#endif
	INC_EIP(1);
}
void vm_je(vm_t* vm) 
{
	uint32_t v0 = MEM_READ(ARG8(1));
	uint32_t v1 = MEM_READ(ARG8(2));
#if TRACE
	trace(vm, "JE %04x, [%d], [%d]\targs: %d, %d", ARG8(3) * 6, ARG8(1), ARG8(2), v0, v1);
#endif
	if (v0 == v1)
	{
		SET_EIP(ARG8(3));
		return;
	}
	INC_EIP(1);
}
void vm_jne(vm_t* vm) { printf("not implemented jne"); exit(0); }
void vm_jle(vm_t* vm) 
{ 
	uint32_t v0 = MEM_READ(ARG8(1));
	uint32_t v1 = MEM_READ(ARG8(2));
#if TRACE
	trace(vm, "JLE %04x, [%d], [%d]\targs: %d, %d", ARG8(3)*6, ARG8(1), ARG8(2), v0, v1);
#endif
	if (v0 <= v1)
	{
		SET_EIP(ARG8(3));
		return;
	}
	INC_EIP(1);
}
void vm_jge(vm_t* vm) { printf("not implemented jge"); exit(0); }
void vm_xor(vm_t* vm) 
{
	uint32_t v0 = MEM_READ(ARG8(2));
	uint32_t v1 = MEM_READ(ARG8(3));
	MEM_WRITE(ARG8(1), v0 ^ v1);
#if TRACE
	trace(vm, "XOR [%d], [%d], [%d]\targs: %d, %d\t-> %d", ARG8(1), ARG8(2), ARG8(3), v0, v1, v0 ^ v1);
#endif
	INC_EIP(1);
}
void vm_store(vm_t* vm) 
{
	uint32_t offset = MEM_READ(ARG8(1));
	vm->cseg[offset] = MEM_READ(ARG8(2));
#if TRACE
	trace(vm, "STORE [%d], [%d]\targs: %d, %d\t-> %d", ARG8(1), ARG8(2), MEM_READ(ARG8(1)), MEM_READ(ARG8(2)), vm->cseg[offset]);
#endif
	INC_EIP(1);
}
void vm_load(vm_t* vm) 
{
	uint32_t offset = MEM_READ(ARG8(2));
	MEM_WRITE(ARG8(1), vm->cseg[offset]);
#if TRACE
	trace(vm, "LOAD [%d], [%d]\t\targs: %d, %d\t-> %d", ARG8(1), ARG8(2), MEM_READ(ARG8(1)), MEM_READ(ARG8(2)), vm->cseg[offset]);
#endif
	INC_EIP(1);
}

const char* input = "c0d3_r3d_5hutd0wn HTB{5w1rl_4r0und_7h3_4l13n_l4ngu4g3}";
int i = 0;

void vm_input(vm_t* vm) 
{ 
	MEM_WRITE(ARG8(1), getchar());
	//MEM_WRITE(ARG8(1), input[i]); ++i;
#if TRACE
	trace(vm, "INPUT [%d]\t\targs: %c", ARG8(1), MEM_READ(ARG8(1)));
#endif
	INC_EIP(1);
}

void (*ops[25])(vm_t*) =
{
	&vm_add,
	&vm_addi,
	&vm_sub,
	&vm_subi,
	&vm_mul,
	&vm_muli,
	&vm_div,
	&vm_cmp,
	&vm_jmp,
	&vm_inv,
	&vm_push,
	&vm_pop,
	&vm_mov,
	&vm_nop,
	&vm_exit,
	&vm_print,
	&vm_putc,
	&vm_je,
	&vm_jne,
	&vm_jle,
	&vm_jge,
	&vm_xor,
	&vm_store,
	&vm_load,
	&vm_input
};

void vm_step(vm_t* vm)
{
	uint8_t op_index = vm->cseg[vm->eip];
	if (op_index < sizeof(ops))
	{
		ops[op_index](vm);
	}
	else
	{
		printf("dead");
		exit(0);
	}
}

vm_t vm_create(const uint8_t* buffer, uint64_t len)
{
	vm_t vm;
	memset(&vm, 0, sizeof(vm_t));
	dump_memory(&vm);
	vm.cseg = calloc(65536, 1);
	memcpy(vm.cseg, buffer+3, (size_t)len-3);
	vm.stack = calloc(512, 4);
	return vm;
}

void vm_shutdown(vm_t vm) 
{
	free(vm.cseg);
	free(vm.stack);
}

int main()
{
	fopen_s(&log, "log.log", "w");

	FILE* fp = NULL;
	if (fopen_s(&fp, "bin", "rb") != 0)
		return 0;

	uint8_t buffer[1024 * 16+3];
	//fseek(fp, 3L, SEEK_SET);
	fread(buffer, 1, sizeof(buffer), fp);
	fclose(fp);

	vm_t vm = vm_create(buffer, sizeof(buffer));

	while (!vm.shutdown)
	{
		vm_step(&vm);
		//dump_memory(&vm);
	}

	vm_shutdown(vm);

	fclose(log);

	return 0;
}