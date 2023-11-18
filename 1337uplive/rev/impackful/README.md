# 1337UP LIVE CTF 2023

## imPACKful

> This program seems to be compressed but still can be executed, I wonder what could cause that..
> 
> Author: Mohamed Adil
> 
> Password is "infected"
> 
> [`imPACKful.zip`](imPACKful.zip)

Tags: _rev_

## Solution
We get again a zip which contains an executable. After inspecting it with `Ghidra` we see a whole lot of `UPX` sections which hints that the binary was packed with [`UPX`](https://upx.github.io/). We can use the same tool to unpack the binary. On the unpacked binary we use `strings` and get the flag.

Flag `INTIGRITI{N3v3R}`