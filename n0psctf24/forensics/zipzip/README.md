# N0PSctf 2024

## ZipZip

> zipzipzipzipzipzip
> 
> Author: algorab
> 
> [`archive.zip`](archive.zip)

Tags: _forensics_

## Solution
The challenge comes with a zip archive. After extracting the archive we find one file, called `4ad9edde81b5526dcd95747a96a90583` containing the `.ZIP File Format Specification`. Sadly no flag, so it must be somewhere else.

We can check the low hanging fruits (like running `binwalk` etc), but I like to open the file in an hexeditor to see if something is off. Zip archives store a [`central directory`](https://en.wikipedia.org/wiki/ZIP_(file_format)) structure at the end of the file containing a list of the files which are contained in the archive. The central directory can be found by searching the *end of central directory record* (`EOCD`) which starts with the magic bytes `0x06054b50` and contains the offset of the first item of the central directory.

Then, from the start offset, the central directory stores one item for each file with additional informations in the file item header (like file-name, compressed and uncompressed size, etc...)

For us the part looks like this:

```
Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

...
0000B080                    50 4B 01 02 14 03 14 00 00 00        PK........
0000B090  08 00 4A 37 84 58 C4 29 B0 39 01 B0 00 00 F9 A9  ..J7„XÄ)°9.°..ù©
0000B0A0  02 00 20 00 00 00 00 00 00 00 00 00 00 00 ED 81  .. ...........í.
0000B0B0  00 00 00 00 34 61 64 39 65 64 64 65 38 31 62 35  ....4ad9edde81b5
0000B0C0  35 32 36 64 63 64 39 35 37 34 37 61 39 36 61 39  526dcd95747a96a9
0000B0D0  30 35 38 33 50 4B 05 06 00 00 00 00 01 00 01 00  0583PK..........
0000B0E0  4E 00 00 00 86 B0 00 00 00 00                    N...†°....
```

Its not surprising, there is one file in the directory, exactly what is expected. If we check out the file entry we have we find the following informations:

```bash
offset  bytes
 0      4       signature                   0x02014b50
 4      2       version made by             14.2
 6      2       version needed to extract   14.0
 8      2       general purpose bit flag    0
10      2       compression method          8 (deflate)
12      2       file last modification time 14154
14      2       file last modification date 22660
16      4       crc32 of uncompressed data  0x39B029C4
20      4       compressed size             45057
24      4       uncomressed size            174585
28      2       file name length            32
30      2       extra field length          0
32      2       file comment length         0
34      2       disk number of file start   0
36      2       internal file attributes    0
38      4       external file attributes    15532032
42      4       relative offset of local
                file header                 0
46      n       file name                   4ad9edde81b5526dcd95747a96a90583
```

Interesting, the local file header is right at the beginning of the file, thats no surprise, since this is the first file in the list. Also the file is `45057` bytes compressed. 

In the local file header many of the informations we saw above are stored as duplicate. Since some fields vary in size, the local file header also can vary in size. But we can calculate its 30 bytes plus the file name (32 bytes) in this case, summing up to a total of 62 bytes. Then come the compressed data (45057 bytes) and we are at offset 0xb03f in our file where we expect our central directory to start. But we already know the central directory starts at offset 0xb086. What magical data lies in-between?

```bash
Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

0000B030                                               14                 .
0000B040  00 00 00 08 00 42 38 84 58 83 9A AE 29 0D 00 00  .....B8„Xƒš®)...
0000B050  00 15 00 00 00 20 00 00 00 33 36 64 66 38 66 33  ..... ...36df8f3
0000B060  61 39 39 30 33 35 36 66 38 62 39 37 38 31 35 61  a990356f8b97815a
0000B070  61 39 30 38 33 62 38 34 39 F3 33 08 08 AE AE 32  a9083b849ó3..®®2
0000B080  2C 88 47 C2 B5 00                                ,ˆGÂµ.
```

Wow, this just looks like another file? But since the file is not tracked in the central directory, no zip tool in the world will export it. Also the local file header is partially stomped, so its not recognized by tools like binwalk. 

Lets see what we can reconstruct.

```bash
offset  bytes
 0      4       signature                   missing
 4      2       version made by             missing
 6      2       version needed to extract   14.0
 8      2       general purpose bit flag    0
10      2       compression method          8 (deflate)
12      2       file last modification time 14402
14      2       file last modification date 22660
16      4       crc32 of uncompressed data  0x29AE9A83
20      4       compressed size             13
24      4       uncomressed size            21
28      2       file name length            32
30      2       extra field length          0
...... missing data .....
46      n       file name                   36df8f3a990356f8b97815aa9083b849
```

Ok, the local file header is really only partially there, but the good thing is, the compressed data is fully present. So we have a few options now, we can add a new entry to the central directory or we replace the previous entry to point to the file data. In any case we need to fix the local file header. Thats all possible with an hex editor:

```bash
Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

00000000  50 4B 03 04 01 14 00 00 08 00 42 38 84 58 83 9A  PK........B8„Xƒš
00000010  AE 29 0D 00 00 00 15 00 00 00 20 00 00 00 33 36  ®)........ ...36
00000020  64 66 38 66 33 61 39 39 30 33 35 36 66 38 62 39  df8f3a990356f8b9
00000030  37 38 31 35 61 61 39 30 38 33 62 38 34 39 F3 33  7815aa9083b849ó3
00000040  08 08 AE AE 32 2C 88 47 C2 B5 00 50 4B 01 02 14  ..®®2,ˆGÂµ.PK...
00000050  03 14 00 00 00 08 00 4A 37 84 58 83 9A AE 29 0D  .......J7„Xƒš®).
00000060  00 00 00 15 00 00 00 20 00 00 00 00 00 00 00 00  ....... ........
00000070  00 00 00 ED 81 00 00 00 00 33 36 64 66 38 66 33  ...í.....36df8f3
00000080  61 39 39 30 33 35 36 66 38 62 39 37 38 31 35 61  a990356f8b97815a
00000090  61 39 30 38 33 62 38 34 39 50 4B 05 06 00 00 00  a9083b849PK.....
000000A0  00 01 00 01 00 4E 00 00 00 4B 00 00 00 00 00     .....N...K.....
```

I removed the first file alltogether and replaced the file content plus fixed the offsets in the central directory and here we have a zip containing the lost file. Lets extract it.

```bash
$ unzip archive.zip
Archive:  archive.zip
  inflating: 36df8f3a990356f8b97815aa9083b849

$ cat 36df8f3a990356f8b97815aa9083b849
N0PS{z1p_z1p_z1p_z1p}
```

Another option would be to just extract the raw deflate data and inflate it again.

```bash
$ dd if=archive.zip bs=1 of=flag skip=45177 count=13
$ python -c "import zlib;print(zlib.decompress(open('flag','rb').read(),-zlib.MAX_WBITS))"
N0PS{z1p_z1p_z1p_z1p}
```

Flag `N0PS{z1p_z1p_z1p_z1p}`