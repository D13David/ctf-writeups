# Cyber Apocalypse 2023

## Persistence

> Thousands of years ago, sending a GET request to /flag would grant immense power and wisdom. Now it's broken and usually returns random data, but keep trying, and you might get lucky... Legends say it works once every 1000 tries.
>
>  Author: N/A
>

Tags: _misc_

## Solution
For this challenge it's all in the description. We need to frequently request the `/flag` endpoint until we are presented with the flag. For this we need a [`script`](solution.py).
```python
import requests

for i in range(0,20000):
    x = requests.get('http://139.59.178.162:30885/flag')
    result = x.content.decode()
    if result.startswith('HTB'):
        print(result)
```

And sure enough, after some time we get the flag `HTB{y0u_h4v3_p0w3rfuL_sCr1pt1ng_ab1lit13S!}`.