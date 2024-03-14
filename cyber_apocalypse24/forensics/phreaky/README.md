# Cyber Apocalypse 2024

## Phreaky

> In the shadowed realm where the Phreaks hold sway,
> A mole lurks within, leading them astray.
> Sending keys to the Talents, so sly and so slick,
> A network packet capture must reveal the trick.
> Through data and bytes, the sleuth seeks the sign,
> Decrypting messages, crossing the line.
> The traitor unveiled, with nowhere to hide,
> Betrayal confirmed, they'd no longer abide.
> 
> Author: sebh24
> 
> [`forensics_phreaky.zip`](forensics_phreaky.zip)

Tags: _forensics_

## Solution
Once again, we get a `pcap`. Opening the file with [`NetworkMiner`](https://www.netresec.com/?page=NetworkMiner) reveals a whole lot of files we can inspect. Especially interesting are some files that are called `SecureFile.zip, SecureFile[1].zip...` and for every zip archive is a `eml` pendant. 

In every `eml` is a password given: `Attached is a part of the file. Password: S3W8yzixNoL8`, so we extract every `SecureFile.zip` with the according password an get 

```bash
phreaks_plan.pdf.part1
phreaks_plan.pdf.part10
phreaks_plan.pdf.part11
phreaks_plan.pdf.part12
phreaks_plan.pdf.part13
phreaks_plan.pdf.part14
phreaks_plan.pdf.part15
phreaks_plan.pdf.part2
phreaks_plan.pdf.part3
phreaks_plan.pdf.part4
phreaks_plan.pdf.part5
phreaks_plan.pdf.part6
phreaks_plan.pdf.part7
phreaks_plan.pdf.part8
phreaks_plan.pdf.part9
```

The parts can be stiched together with the following script:

```bash
out = open("output.pdf", "wb")
for i in range(1, 15):
    part = open(f"phreaks_plan.pdf.part{i}", "rb").read()
    out.write(part)
```

This gives us a pdf, but it seams that the pdf is empty. So, we check with `binwalk` if something else can be found within the file. And indeed, two zlib compressed blobs are extracted and one contains the flag.

Flag `HTB{Th3Phr3aksReadyT0Att4ck}`