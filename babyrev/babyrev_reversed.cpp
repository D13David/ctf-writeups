#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <assert.h>

const int data[] = 
{
	0x66, 0xD9, 0x188, 0x341, 0x7C0, 0x6F9, 0x18A4, 0x95, 0x10A, 0x1D5, 
	0x37C, 0x3A9, 0x7B0, 0x1969, 0x127, 0x1A3, 0x1C4, 0x2B9, 0x754, 0x889, 
	0xF50, 0x1F0, 0x254, 0x2D9, 0x558, 0x571, 0x924, 0x1019, 0x342, 0x3AD, 
	0x508, 0x6E9, 0xA30, 0x10E1, 0x1284, 0x500, 0x5D2, 0x74D 
};

void processPassword(const char* password, int* buffer)
{
	for (size_t i = 0; i < strlen(password); ++i)
	{
		buffer[i] = i * i + (password[i] << ((char)i % 7));
	}
}

int validatePassword(const char* password)
{
	int length = strlen(password);
	int bufferSize = (((length * 4) + 15) / 16) * 16;
	int* buffer = (int*)_malloca(bufferSize);
	assert(buffer);
	processPassword(password, buffer);

	int result = 0;
	for (int i = 0; i < length; ++i)
	{
		if (data[i] == buffer[i])
			++result;
	}

	return result;
}

int main()
{
	char name[512]{};
	char password[512]{};

	printf("Welcome to baby's first rev! :>\n");
	printf("Please enter your name: ");
	scanf_s("%s", name, _countof(name));
	printf("Please enter your password: ");
	scanf_s("%s", password, _countof(password));

	if (strcmp(name, "bossbaby"))
	{
		printf("%s? I don't know you... stranger danger...\n", name);
		exit(0);
	}

	printf("You're almost there!\n");

	if (validatePassword(password) == 38)
	{
		printf("You're boss baby!\n");
	}
}