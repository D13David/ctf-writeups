#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

typedef struct cache_s
{
    FILE* fp;
    uint32_t version;
    uint32_t dataOffset;
} cache_t;

#pragma push(pack, 0)
typedef struct tile_header_s
{
    uint32_t keys[2];
    uint16_t width;
    uint16_t height;
} tile_header_t;
#pragma pop(pack)

void writeTga(const char* filename, uint32_t width, uint32_t height, const uint8_t* data);

int openCache(const char* name, cache_t& cache)
{
    FILE* fp = NULL;
    int version;
    if (fopen_s(&fp, name, "rb") != 0) {
        goto error;
    }

    char buffer[8];
    if (fread_s(buffer, sizeof(buffer), 1, 8, fp) != 8) {
        goto error;
    }

    if (memcmp(buffer, "RDP8bmp\x00", sizeof(buffer)) != 0) {
        goto error;
    }

    if (fread_s(buffer, sizeof(buffer), 1, 4, fp) != 4) {
        goto error;
    }

    version = *(int*)buffer;

    cache.fp = fp;
    cache.version = version;
    cache.dataOffset = ftell(fp);
    return 1;

error:
    if (fp) {
        fclose(fp);
    }
    return -1;
}

void closeCache(cache_t& cache)
{
    if (cache.fp) 
    {
        fclose(cache.fp);
        cache.fp = NULL;
    }
}

void dumpTiles(const char* folder, const cache_t& cache)
{
    if (cache.fp == NULL) {
        return;
    }

    fseek(cache.fp, cache.dataOffset, SEEK_SET);

    for (int tile = 0; ; ++tile)
    {
        tile_header_t tileHeader;
        if (fread_s(&tileHeader, sizeof(tile_header_t), sizeof(tile_header_t), 1, cache.fp) != 1) {
            break;
        }

        uint32_t dataSize = tileHeader.width * tileHeader.height * 4;
        uint8_t data[64 * 64 * 4];

        assert(dataSize <= sizeof(data) && "tile dimension exceeding 64 pixels, increase buffer");
        if (fread_s(data, sizeof(data), 1, dataSize, cache.fp) != dataSize) {
            break;
        }

        printf("%d: %dx%d\n", tile, tileHeader.width, tileHeader.height);
        char fileName[255];
        sprintf(fileName, "%s/%d.tga", folder, tile);
        writeTga(fileName, tileHeader.width, tileHeader.height, data);
    }
}

void writeTga(const char* filename, uint32_t width, uint32_t height, const uint8_t* data)
{
    FILE* fp = NULL;
    fopen_s(&fp, filename, "wb");
    if (fp == NULL) {
        return;
    }

    uint8_t header[18] = { 0,0,2,0,0,0,0,0,0,0,0,0, (uint8_t)(width % 256), (uint8_t)(width / 256), (uint8_t)(height % 256), (uint8_t)(height / 256), (uint8_t)(4 * 8), 0x20 };
    fwrite(&header, 18, 1, fp);
    fwrite(data, 1, width * height * 4, fp);
    fclose(fp);
}

int main()
{
    cache_t cache;
    if (openCache("Cache_chal.bin", cache))
    {
        dumpTiles("output", cache);
        closeCache(cache);
    }
}