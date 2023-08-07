# DeconstruCT.F 2023

## Hash Roll

> Augustine's friend took a important file of augustine and stashed it.
He was able to grab all the files from his friend's machine but he is worried that the files are encrypted.
Help him get the file back
>
>  Author: Rakhul
>
> [`encrypted1.zip`](encrypted1.zip) [`nothing.pdf`](nothing.pdf)

Tags: _forensics_

## Solution
Two files are coming with this challenge. The `zip` cannot be extracted out of the box as it's password secured. Inspecting the `pdf` a very small and slightly grey text tells us that `29ebf2f279da44f69a35206885cd2dbc might be something you need`. This looks like a md5 hash. Putting the hash to crackstation gives us `diosesamor`. Using this as password the content of `encrypted1.zip` can be extracted:

![](flag.jpg)

Flag `dsc{N3v3r_9OnNA_gIv3_y0u_up}`