# AmateursCTF 2023

## Gitint 7d

> One of the repos in the les-amateurs organization is kind of suspicious. Can you find all the real flags in that repository and report back? There are 3 flags total, one of which is worth 0 points. For this challenge, submit the flag with the sha256 hash 7de880d63a3f2494b75286906dba179ee59cc738ea5e275094f94c5457396f48
>
> NOTE:
> You may get iplocked out of the pastebin if you guess the password too many times, so please don't guess. The password is obvious when you see it.
>
>  Author: hellopir2
>

Tags: _osint_

## Solution
This is the continuation of [`Gitint 5e`](../gitint_5e/README.md). We inspect the [`github repository`](https://github.com/les-amateurs/more-CTFd-mods) further. There is one closed [`issue`](https://github.com/les-amateurs/more-CTFd-mods/issues/1).

> Missing dependencies. Where them?
>
> Here: [`link`](https://pastebin.com/VeTDwT09)
> I don't know the password though

The link is going to a password secured `paste`. There also one closed [`pull request`](https://github.com/les-amateurs/more-CTFd-mods/pull/2).

> What's the password, is it like password or something?
>
> Yeah that's the password.

But wait... there is no password. After a while I noticed that the first comment was edited.

> What's the password, is it like password123456 or something?

So there is the password. Unlocking the `paste` in `pastebin` gives the flag:

```python
def flag():
  return "amateursCTF{programs have issues, as do weak passwords}"
```

Flag `amateursCTF{programs have issues, as do weak passwords}`