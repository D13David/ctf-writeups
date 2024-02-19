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