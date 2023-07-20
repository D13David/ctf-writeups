# AmateursCTF 2023

## Minceraft

> I found these suspicious files on my minecraft server and I think there's a flag in them. I'm not sure where though.
>
>Note: you do not need minecraft to solve this challenge. Maybe reference the minecraft region file format wiki?
>
>  Author: hellopir2
>
> [`r.1.135.mca`](r.1.135.mca) [`r.1.136.mca`](r.1.136.mca) [`r.2.135.mca`](r.2.135.mca) [`r.2.136.mca`](r.2.136.mca)

Tags: _forensics_

## Solution
The challenge comes with a bunch of [`region files`](https://minecraft.fandom.com/wiki/Region_file_format) used by minecraft to specify world regions. The format is relatively simple.

```c
typedef struct loca_entry
{
	uint32_t offset;
	uint32_t size;
} loca_entry_t;

typedef struct chunk_header
{
	uint32_t length;
	uint8_t compression;
} chunk_header_t;

typedef struct region_header
{
	loca_entry_t loca_entry_table[1024];
	uint32_t timestamp[1024];
} region_header_t;

typedef struct region
{
	region_header_t header;
	chunk_header_t chunks[1024];
} region_t;
```

The format starts with a header that contains two 4KiB tables. First a table with locations and after this a table of timestamps specifying which location was modified when. Information are generally serialized in big endian byte order. The timestamps are 4 bytes representing epoche seconds. The location table contains and offset (3 byte) and the sector count (1 byte).

Reading the header gives access to all the chunks (blocks) that are present in this region. The offset is the offset into the file where the chunk starts. Every chunk then has a `chunk_header` that contains the length and a constant indicating the compression method (1 = GZIP, 2 = ZLib, 3 = Uncompressed). So chunks can be decompressed. The chunk data then is in [`NTB Format`](https://minecraft.fandom.com/wiki/NBT_format) and hidden in one of the entries is the flag.

```c
bool loadRegionFile(const char* name, region_t* region)
{
    FILE* fp;
    if (fopen_s(&fp, name, "rb") != 0)
        return false;

    uint32_t buffer[1024*2];
    fread(buffer, sizeof(uint32_t), 1024*2, fp);

    region_header_t* header = &region->header;
    for (int i = 0; i < 1024; ++i)
    {
        uint32_t offset = ((buffer[i] & 0xff) << 16) | ((buffer[i] >> 16) & 0xff) | (buffer[i] & 0xff00);
        header->loca_entry_table[i].size = ((buffer[i] >> 24) & 0xff) * 4096;
        header->loca_entry_table[i].offset = (offset & 0xffffff) * 4096;
        header->timestamp[i] = buffer[i+1024];
    }

#define SIZE (1024 * 1024 * 10 * sizeof(Bytef))
    Bytef* chunkData = (Bytef*)malloc(SIZE * 2);
    Bytef* uncompressedChunkData = (Bytef*)chunkData + SIZE;

    for (int i = 0; i < 1024; ++i)
    {
        if (header->loca_entry_table[i].offset == 0) {
            region->chunks[i].compression = 0;
            region->chunks[i].length = 0;
            continue;
        }

        fseek(fp, header->loca_entry_table[i].offset, SEEK_SET);
        fread(&region->chunks[i], sizeof(chunk_header_t), 1, fp);
        fread(chunkData, sizeof(Bytef), region->chunks[i].length, fp);

        uint32_t length = ((region->chunks[i].length & 0x0000ffff) << 16) | ((region->chunks[i].length & 0xffff0000) >> 16);
        region->chunks[i].length = ((length & 0x00ff00ff) << 8) | ((length & 0xff00ff00) >> 8);

        printf("Chunk %d @ %04ld %04ld: ", i, header->loca_entry_table[i].offset, header->loca_entry_table[i].size);
        printf("%04ld %d\n", region->chunks[i].length, region->chunks[i].compression);

        uLongf size = SIZE;
        int result = uncompress(uncompressedChunkData, &size, chunkData, region->chunks[i].length-1);
        if (memsearch(uncompressedChunkData, "amateursCTF") != -1)
        {
            printf("found...");
        }
    }

    fclose(fp);

    return true;
}
```

Flag `amateursCTF{cow_wear_thing_lmao_0f9183ca}`