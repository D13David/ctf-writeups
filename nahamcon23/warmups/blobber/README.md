# NahamCon 2023

## Blobber

> This file is really... weird...
>
>  Author: @JohnHammond#6971
>
> [`blobber`](blobber)

Tags: _warmups_

## Solution
Inspecting the file with `file`

```bash
$ file blobber
blobber: SQLite 3.x database, last written using SQLite version 3037002, file counter 4, database pages 10, cookie 0x1, schema 4, UTF-8, version-valid-for 4
```

So it's a sqlite database. With `sqlitebrowser` the file can be inspected. The table `blobber` looks like a lot of garbage but there are data fields where one contains a bzip blob. Extracting the blob and decompressing the blob with:

```bash
$ sqlite3 blobber "select hex(data) from blobber" | xxd -r -p > foo.bz2
$ bzip2 -d foo.bz2
```

The uncompressed file is a png (inspect with `file` or `hexedit`) containing the flag.

Flag `flag{b93a6292f3491c8e2f6cdb3addb5f588}`