# Cyber Apocalypse 2024

## An unusual sighting

> As the preparations come to an end, and The Fray draws near each day, our newly established team has started work on refactoring the new CMS application for the competition. However, after some time we noticed that a lot of our work mysteriously has been disappearing! We managed to extract the SSH Logs and the Bash History from our dev server in question. The faction that manages to uncover the perpetrator will have a massive bonus come competition!
> 
> Author: c4n0pus
> 
> [`forensics_an_unusual_sighting.zip`](forensics_an_unusual_sighting.zip)

Tags: _forensics_

## Solution
For this challenge, we get a `bash_history.txt` as well as a `sshd.log` we have to analyze. To get the flag some questions need to be answered. The answers are all found inside the two files.

```bash
+---------------------+---------------------------------------------------------------------------------------------------------------------+
|        Title        |                                                     Description                                                     |
+---------------------+---------------------------------------------------------------------------------------------------------------------+
| An unusual sighting |                        As the preparations come to an end, and The Fray draws near each day,                        |
|                     |             our newly established team has started work on refactoring the new CMS application for the competition. |
|                     |                  However, after some time we noticed that a lot of our work mysteriously has been disappearing!     |
|                     |                     We managed to extract the SSH Logs and the Bash History from our dev server in question.        |
|                     |               The faction that manages to uncover the perpetrator will have a massive bonus come the competition!   |
|                     |                                                                                                                     |
|                     |                                            Note: Operating Hours of Korp: 0900 - 1900                               |
+---------------------+---------------------------------------------------------------------------------------------------------------------+


Note 2: All timestamps are in the format they appear in the logs

What is the IP Address and Port of the SSH Server (IP:PORT)
> 100.107.36.130:2221
[+] Correct!

What time is the first successful Login
> 2024-02-13 11:29:50
[+] Correct!

What is the time of the unusual Login
> 2024-02-19 04:00:14
[+] Correct!

What is the Fingerprint of the attacker's public key
> SHA256:OPkBSs6okUKraq8pYo4XwwBg55QSo210F09FCe1-yj4
[-] Wrong Answer.
What is the Fingerprint of the attacker's public key

> OPkBSs6okUKraq8pYo4XwwBg55QSo210F09FCe1-yj4
[+] Correct!

What is the first command the attacker executed after logging in
> useradd -mG sudo softdev
[-] Wrong Answer.
What is the first command the attacker executed after logging in

> whoami
[+] Correct!

What is the final command the attacker executed before logging out
> ./setup
[+] Correct!

[+] Here is the flag: HTB{B3sT_0f_luck_1n_th3_Fr4y!!}
```

Flag `HTB{B3sT_0f_luck_1n_th3_Fr4y!!}`