# DownUnderCTF 2023

## faraday

> We've been trying to follow our target Faraday but we don't know where he is.
> 
> All we know is that he's somewhere in Victoria and his phone number is +61491578888.
> 
> Luckily, we have early access to the GSMA's new location API. Let's see what we can do with this.
> 
> The flag is the name of the Victorian town our target is in, in all lowercase with no spaces, surrounded by `DUCTF{}`. For example, if Faraday was in Swan Hill, the solution would be `DUCTF{swanhill}`.
>
>  Author: hashkitten
>

Tags: _osint_

## Solution
For this challenge we don't get any input except a link to the `GSMA's location API`, the phone number and the hint that we need to search in [`Victoria`](https://en.wikipedia.org/wiki/Victoria_(state)).

The best bet is to take the largest radius and sample random positions until we get a hit. Then decrease the radius until we loose the hit and move the sample position slightly around until we again get a hit. By doing this we can increasingly move towards the actial location.

This can be fully automated, but I just wrote a small script to quickly try different locations manually. This worked as well and took not too much time.
```python
import requests
import sys

lat = float(sys.argv[1][:-1])
long = float(sys.argv[2])
rad = int(sys.argv[3])

data = {
  "device": {
    "phoneNumber": "+61491578888"
  },
  "area": {
    "areaType": "Circle",
    "center": {
      "latitude": lat,
      "longitude": long
    },
    "radius": rad
  },
  "maxAge": 120
}
header = {}

r = requests.post('https://osint-faraday-9e36cbd6acad.2023.ductf.dev/verify', json=data)
print(r.text)
```

The closest hit I found was at which is somewhere near [`Milawa`](https://goo.gl/maps/BLt1GjUQsNvtmwE49).
```bash
$ python foo.py -36.463259, 146.428708 2000
{"lastLocationTime":"Fri Sep  1 18:39:57 2023","verificationResult":"TRUE"}
```

Flag `DUCTF{milawa}`