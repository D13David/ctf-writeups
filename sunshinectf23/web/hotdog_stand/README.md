# SunshineCTF 2023

## Hotdog Stand

> In the not-so-distant future, robots have taken over the fast-food industry. Infiltrate the robot hotdog stand to find out whatjobs still remain.
> 
>  Author: N/A

Tags: _web_

## Solution
We again get a small web application. At the main page we find a login form where robots can enter their `Robot ID` and `Access Code`. Since robots are the main theme of this ctf, we check `/robots.txt`.

```
User-agent: * Disallow: /configs/ Disallow: /backups/ Disallow: /hotdog-database/
```

The route `hotdog-database` allows us to download the sqlite database for further inspection.

```bash
$ sqlite3 robot_data.db
SQLite version 3.40.1 2022-12-28 14:03:47
Enter ".help" for usage hints.
sqlite> .tables
credentials       customer_reviews  menu_items        robot_logs
sqlite> select * from credentials;
1|hotdogstand|slicedpicklesandonions|admin
```

Using `hotdogstand:slicedpicklesandonions` as login credentials gives us the flag.

Flag `sun{5l1c3d_p1cKl35_4nd_0N10N2}`