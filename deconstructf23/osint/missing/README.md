# DeconstruCT.F 2023

## Missing

> Jason todd went missing and all alfred was able to recover from his pc was this file
> Help Alfred find Jason
>
>  Author: Rakhul
>
> [`jason.rar`](jason.rar)

Tags: _osint_

## Solution
The challenge gives a password protected `rar` file. The additional hint says `bruteforce is allowed`, so we just crack it with john.

```bash
$ rar2john x.rar > foo

$ john --wordlist=/usr/share/wordlists/rockyou.txt foo
```

This gives the password `1983` and we can extract the archive. Two folders are extracted both containing a git repository. First and obviously we look at `nothing_here_to_look_at`, there are 4 commits.

```bash
$ git log
commit 65e36b3f6fc7baa97fdb17ae17d4d0ab2ac9ff71 (HEAD -> main, origin/main, origin/HEAD)
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Wed Jun 1 17:33:30 2022 +0530

    Create encoded.txt

commit c707cc578d25efe99348ed9e267156a8203224ae
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Wed Jun 1 17:32:13 2022 +0530

    Create secret.txt

commit 38daa614da04a03b6c02149504bda43d56dcbd8a
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Sat May 28 11:41:55 2022 +0530

    Update empty.txt

commit f50086b592f94cc8d05f9b1dde2eeb10d6c4713c
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Fri May 27 11:52:07 2022 +0530

    something for u

$ git show f50086b592f94cc8d05f9b1dde2eeb10d6c4713c
commit f50086b592f94cc8d05f9b1dde2eeb10d6c4713c
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Fri May 27 11:52:07 2022 +0530

    something for u

diff --git a/empty.txt b/empty.txt
new file mode 100644
index 0000000..bdd4d2c
--- /dev/null
+++ b/empty.txt
@@ -0,0 +1,26 @@
+this link might be interesting
+
+
+
+///
+
+/
+/
+/
+/
+/
+/
+
+
+
+aHR0cHM6Ly93d3cuaW5zdGFncmFtLmNvbS90b2RkX2phc29uX3NlY3VyZS8=
+/
+/
+/
+/
+/
+/
+////
+
+/
+/
```

So, this looks interesting.

```bash
$ echo -n "aHR0cHM6Ly93d3cuaW5zdGFncmFtLmNvbS90b2RkX2phc29uX3NlY3VyZS8=" | base64 -d
https://www.instagram.com/todd_jason_secure/
```

A instagram profile of `todd jason`. There are two posts. In the first one `todd` wrote a couple of comments.

```
Alfred.....
We know the game and we're gonna play it
Inside, we both know what's been going on (going on)
Your heart's been aching, but you're too shy to say it
We've known each other for so long
Find my twitter handle to find the rest :((
:P
wadjkh2
Never gonna tell a lie and hurt you
Never gonna say goodbye
Never gonna make you cry
Never gonna run around and desert you
Never gonna let you down
Never gonna give you up
```

There's the hint to look for the twitter handle, so todd also uses `twitter`. In the second post we find one half of the flag.

```
.;'...[;.///./// have a part of the flagg
''//'/;''';'$#$%^#@
dsc{h4vINg_FuN_w1
#@#%%^@@//=-.,.....@#$@#
```

Another encoded string can be found in  commit `65e36b3f6fc7baa97fdb17ae17d4d0ab2ac9ff71`, but it leads to nothing.

```bash
$ echo "V2hhdCB5b3UgbG9va2luZyBmb3IgYWludCBoZXJlIDpQClNlYXJjaCBoYXJkZXIgZm9yIHdoYXQgeW91IHNlZWsg" | base64 -d
What you looking for aint here :P
Search harder for what you seek
```

So moving to the other repository `cryptic-tod-secure`, again 4 commits.

```bash
$ git log
commit 1267d694e9bfea67fd38f6e6a7d75257241c9b18 (HEAD -> main, origin/main, origin/HEAD)
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Sat May 28 11:40:49 2022 +0530

    Update README.md

commit 4043119033a275523fce9d77999cb12e5e5854a4
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Sat May 28 11:05:54 2022 +0530

    Update README.md

commit 9c55b636f29250f8d28129da4ad08d53b58d67c4
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Fri May 27 11:57:22 2022 +0530

    Update README.md

commit 36412a5d8b9f06e12423ddcad34eef8bde3602b1
Author: cryptic-tod-secure <106369190+cryptic-tod-secure@users.noreply.github.com>
Date:   Fri May 27 11:56:53 2022 +0530

    Initial commit
```

It's a simple portfolio page of `todd`. In `4043119033a275523fce9d77999cb12e5e5854a4` there is another hint though:

```
u can find what you want on my github pages site :P
```

In fact, the `github pages` where mentioned in the other repository as well.

```
find my github pages site that i accidentaly deleted to find what u want :P
```

So this must be something important, but the github pages where deleted. So we can try if `wayback machine` still has a snapshot. And yes.. there are two [`snapshots`](https://web.archive.org/web/20220515000000*/https://cryptic-tod-secure.github.io/).

I looked quite a bit on the `github pages` but found nothing. The only thing changed between both snapshots was another "hint".

```
:P
looking at my socials might do u good especially my twitter handle XD
```

Well.. we knew that before. So heading over to twitter, trying a few combination of todds known user handles:

```
cryptic-tod-secure
todd_jason_secure
```

But nothing. Then I just searched twitter for "todd jason secure" and immediately found one single [`match`](https://twitter.com/toddjasonsecure).

The first message turned out a false flag
```bash
$ echo "ZHNje24wX0YhQEdfSGVSZV86cF9tQDdFfQ==" | base64 -d
dsc{n0_F!@G_HeRe_:p_m@7E}
```

But the second message gave the second part of the flag.

```bash
$ echo "G5UF6TZVJFHFIX2AJZSF63JUOA2X2===" | base32 -d
7h_O5INT_@Nd_m4p5}
```

Flag `dsc{h4vINg_FuN_w17h_O5INT_@Nd_m4p5}`