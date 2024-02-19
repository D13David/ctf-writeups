# LACTF 2023

## flaglang

> Do you speak the language of the flags?
> 
> Author: r2uwu2
> 
> [`flaglang.zip`](flaglang.zip)

Tags: _web_

## Solution
For this challenge we get a simple web-app with source. With the app we can view country flags and see what `Hello World` says in the chosen country language. Inspecting the source we find a list of country definitions in `countries.yaml`. The interesting part is, that there is a country called `Flagistan` that has the flag in it's message. To view the countries an endpoint exists called `/view`.

```yaml
Flagistan:
  iso: FL
  msg: "<REDACTED>"
  password: "<REDACTED>"
  deny:
    ["AF","AX","AL","DZ","AS","AD","AO","AI","AQ","AG","AR","AM","AW","AU","AT","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT"
    ...
```

```javascript
app.get('/view', (req, res) => {
  if (!req.query.country) {
    res.status(400).json({ err: 'please give a country' });
    return;
  }
  if (!countries.has(req.query.country)) {
    res.status(400).json({ err: 'please give a valid country' });
    return;
  }
  const country = countryData[req.query.country];
  const userISO = req.signedCookies.iso;
  if (country.deny.includes(userISO)) {
    res.status(400).json({ err: `${req.query.country} has an embargo on your country` });
    return;
  }
  res.status(200).json({ msg: country.msg, iso: country.iso });
});
```

The interesting bit is that a country can have a `deny list` of other countries being able to see the flag and message. This information is stored in a (signed) cookie. Since we don't know the password we can just delete the cookie and request the country flag again, giving us the flag.

Flag `lactf{n0rw3g7an_y4m7_f4ns_7n_sh4mbl3s}`