# Cyber Apocalypse 2023

## Alien Cradle

> In an attempt for the aliens to find more information about the relic, they launched an attack targeting Pandora's close friends and partners that may know any secret information about it. During a recent incident believed to be operated by them, Pandora located a weird PowerShell script from the event logs, otherwise called PowerShell cradle. These scripts are usually used to download and execute the next stage of the attack. However, it seems obfuscated, and Pandora cannot understand it. Can you help her deobfuscate it?
>
>  Author: N/A
>
> [`forensics_alien_cradle.zip`](forensics_alien_cradle.zip)

Tags: _forensics_

## Solution
A obfuscated PowerShell script is provided. When inspecting the script the flag is be visible already:

```
;$s = New-Object IO.MemoryStream(,[Convert]::FromBase64String($d));$f = 'H' + 'T' + 'B' + '{p0w3rs' + 'h3ll' + '_Cr4d' + 'l3s_c4n_g3t' + '_th' + '3_j0b_d' + '0n3}'
```

Stiching the parts together leads the flag `HTB{p0w3rsh3ll_Cr4dl3s_c4n_g3t_th3_j0b_d0n3}`.