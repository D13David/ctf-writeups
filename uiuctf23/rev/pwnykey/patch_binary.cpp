#include <cstdio>
#include <cstdint>
#include <malloc.h>
#include <algorithm>
#include <cassert>

#include "devs_builtin_names.h"

#define DEVS_FIX_HEADER_SIZE 32
#define DEVS_ASCII_HEADER_SIZE 2
#define DEVS_FIRST_MULTIBYTE_INT 0xf8

#define DEVS_BYTECODEFLAG_IS_STMT 0x10
#define DEVS_BYTECODEFLAG_TAKES_NUMBER 0x20

#define DEVS_OP_PROPS                                                                              \
    "\x7f\x60\x11\x12\x13\x14\x15\x16\x17\x18\x19\x12\x51\x70\x31\x42\x60\x31\x31\x14\x40\x20\x20" \
    "\x41\x02\x13\x21\x21\x21\x60\x60\x10\x11\x11\x60\x60\x60\x60\x60\x60\x60\x60\x10\x03\x00\x41" \
    "\x40\x41\x40\x40\x41\x40\x41\x41\x41\x41\x41\x41\x42\x42\x42\x42\x42\x42\x42\x42\x42\x42\x42" \
    "\x42\x42\x42\x41\x32\x21\x20\x41\x10\x30\x12\x30\x70\x10\x10\x51\x51\x71\x10\x41\x42\x40\x42" \
    "\x42\x11\x60"

#define DEVS_STMTx_JMP 13 // JMP jmpoffset

//https://github.com/microsoft/devicescript/blob/main/runtime/devicescript/devs_format.h#L34
typedef struct {
	uint32_t start;  // in bytes
	uint32_t length; // in bytes
} devs_img_section_t;

typedef struct {
	uint32_t magic0;
	uint32_t magic1;
	uint32_t version;
	uint16_t num_globals;
	uint16_t num_service_specs;
	uint8_t reserved[DEVS_FIX_HEADER_SIZE - 4 - 4 - 4 - 2 - 2];

	devs_img_section_t functions;      // devs_function_desc_t[]
	devs_img_section_t functions_data; // uint16_t[]
	devs_img_section_t float_literals; // value_t[]
	devs_img_section_t roles_removed;  // no longer used
	devs_img_section_t ascii_strings;  // uint16_t[]
	devs_img_section_t utf8_strings;   // uint32_t[]
	devs_img_section_t buffers;        // devs_img_section_t[]
	devs_img_section_t string_data;    // "*_strings" and "buffers" point in here
	devs_img_section_t service_specs;  // devs_service_spec_t[] followed by other stuff
	devs_img_section_t dcfg;           // see jd_dcfg.h
} devs_img_header_t;

typedef struct {
	// position of function (must be within code section)
	uint32_t start;  // in bytes, in whole image
	uint32_t length; // in bytes
	uint16_t num_slots;
	uint8_t num_args;
	uint8_t flags;
	uint16_t name_idx;
	uint8_t num_try_frames;
	uint8_t reserved;
} devs_function_desc_t;

typedef struct {
	union {
		uint8_t* data;
		const devs_img_header_t* header;
	};
} devs_img_t;

enum StrIdx {
	BUFFER = 0,
	BUILTIN = 1,
	ASCII = 2,
	UTF8 = 3,
	_SHIFT = 14
};

static inline uint32_t devs_img_num_functions(devs_img_t img) 
{
	return img.header->functions.length / sizeof(devs_function_desc_t);
}

static inline const devs_function_desc_t* devs_img_get_function(devs_img_t img, uint32_t idx) 
{
	return (const devs_function_desc_t*)(img.data + img.header->functions.start +
		idx * sizeof(devs_function_desc_t));
}

static inline uint8_t* devs_img_get_function_bytecode(devs_img_t img, const devs_function_desc_t* func) 
{
	return (img.data + func->start);
}

const char* get_utf8(devs_img_t img, int index)
{
	uint16_t ofs = *(uint16_t*)(img.data + img.header->ascii_strings.start + index * DEVS_ASCII_HEADER_SIZE);
	return (const char*)(img.data + img.header->string_data.start + ofs);
}

const char* get_string(devs_img_t img, int tp, int index) 
{
	if (tp == BUILTIN) {
		return BUILTIN_STRING__VAL[index];
	}
	else if (tp == ASCII) {
		return get_utf8(img, index);
	}
	else if (tp == UTF8) {
		return "UNKNOWN: UTF8";
	}
	else if (tp == BUFFER) {
		return "UNKNOWN: BUFFER";
	}
	return NULL;
}

const char* get_string1(devs_img_t img, int index)
{
	int tp = index >> _SHIFT;
	int idx = index & ((1 << _SHIFT) - 1);
	return get_string(img, tp, idx);
}

static inline bool op_takes_number(int opcode) 
{
	return DEVS_OP_PROPS[opcode] & DEVS_BYTECODEFLAG_TAKES_NUMBER;
}

static inline bool op_is_stmt(int opcode) 
{
	return DEVS_OP_PROPS[opcode] & DEVS_BYTECODEFLAG_IS_STMT;
}

static inline int decode_int(const uint8_t* bytecode, int& pc) 
{
	uint8_t v = bytecode[pc++];
	if (v < DEVS_FIRST_MULTIBYTE_INT) {
		return v;
	}

	int result = 0;
	int len = (v & 3) + 1;
	for (int i = 0; i < len; ++i) {
		result = (result << 8) | bytecode[pc++];
	}

	if (v & 4) {
		return -result;
	}
	return result;
}

void* load_binary_image(const char* imageName, devs_img_t* img, long& size)
{
	FILE* fp = nullptr;
	if (fopen_s(&fp, imageName, "rb") != 0) {
		return nullptr;
	}

	fseek(fp, 0L, SEEK_END);
	size = ftell(fp);
	fseek(fp, 0L, SEEK_SET);

	uint8_t* buffer = (uint8_t*)malloc(size);
	if (buffer && fread(buffer, 1, size, fp) == size)
	{
		img->data = (uint8_t*)buffer;
	}

	fclose(fp);

	return buffer;
}

// https://github.com/microsoft/devicescript/blob/main/compiler/src/disassemble.ts#L455
void patch_bytecode(uint8_t* bytecode, int length) 
{
	int pc = 0;
	int bend = length - 1;
	while (bytecode[bend] == 0x0) 
	{
		bend--;
	}
	bend = std::max(length - 4, bend + 1);

	while (pc < bend)
	{
		for (;;)
		{
			int opcode = bytecode[pc++];
			int jumpofs = -1, intArg = 0;
			if (op_takes_number(opcode))
			{
				jumpofs = pc - 1;
				intArg = decode_int(bytecode, pc);
			}

			// we are looking for unconditional forward jumps (plus actually test if the jump target exists or not)
			if (opcode == DEVS_STMTx_JMP)
			{
				int offset = intArg + jumpofs;
				assert(offset >= 0 || offset < length);

				if (offset >= pc) 
				{
					for (int i = jumpofs; i < offset; ++i) {
						bytecode[i] = 0;
					}
					pc = offset;
				}
			}

			if (op_is_stmt(opcode)) {
				break;
			}
		}
	}
}

int main()
{
	long size;
	devs_img_t img;
	void* buffer = load_binary_image("keychecker.devs", &img, size);
	if (!buffer) {
		return 1;
	}

	for (uint32_t i = 0; i < devs_img_num_functions(img); ++i)
	{
		const devs_function_desc_t* desc = devs_img_get_function(img, i);
		printf("Patch: %s_%d\n", get_string1(img, desc->name_idx), i);
		patch_bytecode(devs_img_get_function_bytecode(img, desc), desc->length);
	}

	FILE* fp = fopen("patched.devs", "wb");
	fwrite(buffer, 1, size, fp);
	fclose(fp);

	free(buffer);
}