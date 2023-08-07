# DeconstruCT.F 2023

## sweet-nothing

> What can be sweeter than doing nothing? The flag is right in front of you.
>
>  Author: N/A
>

Tags: _web_

## Solution
This challenge gave a static website with italy flag colors as background and a lot of images just screaming `italy`. The additional hint mentioned `Watch you head with this challenge` so most likely pointing to some HTTP header manipulation.

Since it's all italy branded I changed the `Accept-Language` to `it-IT` and got another response after refresh pointing out `the secret query is spaghetti`. Taking this literally I added `?query=spaghetti` and got the flag.

```bash
curl -H "Accept-Language: it-IT" https://ch35770130751.ch.eng.run/?secret=spaghetti
```

Flag `dsc{1a_d01c3_vit4}`