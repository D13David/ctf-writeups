# Cyber Apocalypse 2024

## PackedAway

> To escape the arena's latest trap, you'll need to get into a secure vault - and quick! There's a password prompt waiting for you in front of the door however - can you unpack the password quick and get to safety?
> 
> Author: clubby789
> 
> [`rev_packedaway.zip`](rev_packedaway.zip)

Tags: _rev_

## Solution
For this challenge we get a binary called `packed`. A often used executable packer is [`UPX`](https://upx.github.io/). To confirm if this is the case here we can search for strings within the binary.

```bash
$ strings packed | grep UPX
UPX!
$Info: This file is packed with the UPX executable packer http://upx.sf.net $
$Id: UPX 4.22 Copyright (C) 1996-2024 the UPX Team. All Rights Reserved. $
UPX!u
UPX!
UPX!
```

Looks like a match. In this case we can easily unpack the original binary.

```bash
$ upx-4.2.2-amd64_linux/upx -d packed -o unpacked
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2024
UPX 4.2.2       Markus Oberhumer, Laszlo Molnar & John Reiser    Jan 3rd 2024

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
     22867 <-      8848   38.69%   linux/amd64   unpacked

Unpacked 1 file.
```

Calling strings on the unpacked binary gives us the flag.

Flag `HTB{unp4ck3d_th3_s3cr3t_0f_th3_p455w0rd}`