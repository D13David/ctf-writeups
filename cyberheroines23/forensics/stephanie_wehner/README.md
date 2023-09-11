# CyberHeroines 2023

## Stephanie Wehner

> [Stephanie Dorothea Christine Wehner](https://en.wikipedia.org/wiki/Stephanie_Wehner) (born 8 May 1977 in Würzburg) is a German physicist and computer scientist. She is the Roadmap Leader of the Quantum Internet and Networked Computing initiative at QuTech, Delft University of Technology.She is also known for introducing the noisy-storage model in quantum cryptography. Wehner's research focuses mainly on quantum cryptography and quantum communications. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Stephanie_Wehner)
> 
> Chal: We had the flag in notepad but it crashed. Please return the flag to [this Quantum Cryptographer](https://www.youtube.com/watch?v=XzPi29O6DAc)
>
>  Author: [Rusheel](https://github.com/Rusheelraj)
>

Tags: _forensics_

## Solution
For this challenge a `memory dump` is given. To analyze this we can use [Volatility](https://github.com/volatilityfoundation/volatility). First thing is to find more informations about the dump.

```bash
$ vol.py -f dump.vmem imageinfo
Volatility Foundation Volatility Framework 2.6.1
INFO    : volatility.debug    : Determining profile based on KDBG search...
          Suggested Profile(s) : Win8SP0x64, Win81U1x64, Win2012R2x64_18340, Win2012R2x64, Win2012x64, Win8SP1x64_18340, Win8SP1x64
                     AS Layer1 : SkipDuplicatesAMD64PagedMemory (Kernel AS)
                     AS Layer2 : FileAddressSpace (/home/ctf/dump.vmem)
                      PAE type : No PAE
                           DTB : 0x1a7000L
                          KDBG : 0xf8037feaba30L
          Number of Processors : 1
     Image Type (Service Pack) : 0
                KPCR for CPU 0 : 0xfffff8037ff06000L
             KUSER_SHARED_DATA : 0xfffff78000000000L
           Image date and time : 2023-08-03 21:21:54 UTC+0000
     Image local date and time : 2023-08-03 17:21:54 -0400
```

Now we know the profile `Win8SP0x64` we can start some analysis. The challenge description mentioned the flag was in `notepad` so we can try to dump the process memory of `notepad`. For this we need the `pid`.

```bash
$ vol.py -f dump.vmem --profile=Win8SP0x64 pslist | grep notepad
Volatility Foundation Volatility Framework 2.6.1
0xffffe000021c3900 notepad.exe            2452   1180      2        0      1      0 2023-08-03 21:20:36 UTC+0000
```

Next we can dump the process memory.

```bash
$ vol.py -f dump.vmem --profile=Win8SP0x64 memdump --dump-dir=./ -p 2452
Volatility Foundation Volatility Framework 2.6.1
************************************************************************
Writing notepad.exe [  2452] to 2452.dmp
```

Now we can check what strings are within the process dump. Since windows is using `utf-16` strings we have to use `-e l` when calling `strings`. Amongst a whole lot of strings we find this interesting piece.

```bash
Welcome to CyberHeroines CTF !
No, No, chctf{this_is_not_the_flag} - not a leet format
Try harder !!!
Github: https://github.com/FITCF
```

Only a fake flag was in notepad but there is a github user we can check out. The user has one repository called `Secret`.

```bash
$ git clone https://github.com/FITCF/Secret
Cloning into 'Secret'...
remote: Enumerating objects: 6, done.
remote: Counting objects: 100% (6/6), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 6 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (6/6), done.

$ cat Secret/A_Cyber_Heroine.txt
Well, there's nothing here!
```

Nothing here.. But maybe in the history?

```bash
$ git log
commit c30c8b6a9d45548b79d0e90d128ca56baa61a59f (HEAD -> main, origin/main, origin/HEAD)
Author: FIT Forensics <124709866+FITCF@users.noreply.github.com>
Date:   Thu Aug 3 17:12:22 2023 -0400

    Update A_Cyber_Heroine.txt

commit 0be8a0fef95a713afa13e2e2b837685deec5e6ce
Author: FIT Forensics <124709866+FITCF@users.noreply.github.com>
Date:   Thu Aug 3 17:11:39 2023 -0400

    Create A_Cyber_Heroine.txt

$ git checkout 0be8a0fef95a713afa13e2e2b837685deec5e6ce
...

$ cat A_Cyber_Heroine.txt
Well, the flag is:
chctf{2023!@mu5f@!5y_1009}
```

Flag `chctf{2023!@mu5f@!5y_1009}`