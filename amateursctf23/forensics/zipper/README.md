# AmateursCTF 2023

## zipper

> Stare into the zip and the zip stares back.
>
>  Author: flocto
>
> [`flag.zip`](mflag.zip)

Tags: _forensics_

## Solution
For this challenge a `zip` archive is given. First thing is to unzip the archive. 

```bash
$ unzip flag.zip
Archive:  flag.zip
So many flags... So many choices...
Part 1: amateursCTF{z1PP3d_
   creating: flag/
  inflating: flag/flag201.txt
  inflating: flag/flag0.txt
  inflating: flag/flag1.txt
  inflating: flag/flag2.txt
  ...
  replace flag/flag201.txt? [y]es, [n]o, [A]ll, [N]one, [r]ename:
```

There are some collisions where the zip has duplicate filenames stored. To get all the information we rename the files while extracting them. Most of them have `red herring XD` as content, but one contains a part of the flags `Part 4: _Zips}`. Another part is stored in the zip file comment and reveiled right at the start when calling `unzip`: `amateursCTF{z1PP3d_`.

So part 1 and part 4 we have, but in the middle part 2 and 3 are missing. One idea is to use `strings` on the zip.

```bash
─$ strings flag.zip  | grep Part
flag/Part 3: laY3r_0fPK
Part 1: amateursCTF{z1PP3d_
```

And sure enough, there is part 3 `Part 3: laY3r_0f`. `PK` is in fact not part of the flag but the start of the next `file entry`. Now, only one part missing. One things that turned out to be a red herring as well are the 1024 textfiles with pseudo encoded content. In the end I decided to parse the whole zip file by hand and dump all the informations to see if enything was missing. The full script can be found [`here`](zipper.py), but it basically simply walks the whole zip format and dumps information.

```python
# parse file entries
while True:
    sig = struct.unpack('i', f.read(4))[0]
    if sig != 0x04034b50:
        break
    f.read(2) # ver
    f.read(2) # flags
    comp = struct.unpack('H', f.read(2))[0] # compression
    f.read(2) # last mod time
    f.read(2) # last mod date
    f.read(4) # crc32
    size_comp = struct.unpack('i', f.read(4))[0] # compressed size
    size_uncomp = struct.unpack('i', f.read(4))[0] # uncompressed size
    name_len = struct.unpack('H', f.read(2))[0] # filename length
    extra_len = struct.unpack('H', f.read(2))[0] # extra field len
    name = f.read(name_len)
    f.read(extra_len)
    data = f.read(size_comp)
    print(name, end=": ")
    if comp == 8:
        data = inflate(data)
        print(data)
```

And as it turnes out, part 2 was also compressed data for one of the file entries. The entry in question though was a `folder` not a `file` and therefore no content was decompressed to it when calling `uncompress`. 

```bash
$ python zipper.py
b'flag/': b'flag/flag201.txt': b'Part 4: _Zips}'
b'flag/': b'Part 2: in5id3_4_'
b'flag/flag0.txt': b'5BOWFiPrCBVKd3uXLSl3ut6yFnWwC5a7AXtC4Dj5oPfslTV'
b'flag/flag1.txt': b'hKcrvN00r66trDSrD3IZZ8RJX2V2YkwdFbtr2ztcHURN'
b'flag/flag2.txt': b'Zg4cSypU6vIxUwIMjIxlHP0CVv0jeOBRqPY'
b'flag/flag3.txt': b'5quwNP2TbL95JHWv0usFo4J27'
b'flag/flag4.txt': b'UZqXvNqNmtnOEN0L'
...
b'flag/' Comment: b''
b'flag/flag201.txt' Comment: b''
b'flag/' Comment: b'Part 3: laY3r_0f'
b'flag/flag0.txt' Comment: b''
b'flag/flag1.txt' Comment: b''
b'flag/flag2.txt' Comment: b''
b'flag/flag3.txt' Comment: b''
...
Comment: b'So many flags... So many choices...\nPart 1: amateursCTF{z1PP3d_'
```

Here we have it, all the parts. First two as content of file entries, part 3 as comment for a entry within the `central directory record` and the first part as comment inside the `end of central directory record`.

Flag `amateursCTF{z1PP3d_in5id3_4_laY3r_0f_Zips}`