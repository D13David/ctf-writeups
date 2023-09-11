# CyberHeroines 2023

## Elizabeth Feinler

> [Elizabeth Jocelyn "Jake" Feinler](https://en.wikipedia.org/wiki/Elizabeth_J._Feinler) (born March 2, 1931) is an American information scientist. From 1972 until 1989 she was director of the Network Information Systems Center at the Stanford Research Institute (SRI International). Her group operated the Network Information Center (NIC) for the ARPANET as it evolved into the Defense Data Network (DDN) and the Internet. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Elizabeth_J._Feinler)
> 
> Chal: We found this PCAP but we did not know what to name it. Return the flag to this [Internet Hall of Famer](https://www.youtube.com/watch?v=idb-7Z3qk_o)
>
>  Author: [Rusheel](https://github.com/Rusheelraj)
>
> [`NoName.pcap`](NoName.pcap)

Tags: _forensics_

## Solution
The `pcap` capture delivered for this challenge is very small and contains a list of domain queries:

```bash
$ tshark -r NoName.pcap
    1   0.000000 192.168.1.27 → 192.168.1.1  DNS 66 Standard query 0x0000 A 143.google.WiCys.com
    2   0.000314 192.168.1.27 → 192.168.1.1  DNS 63 Standard query 0x0001 A 150.fit.WiCys.edu
    3   0.000582 192.168.1.27 → 192.168.1.1  DNS 63 Standard query 0x0002 A 143.fit.WiCys.edu
    4   0.000771 192.168.1.27 → 192.168.1.1  DNS 66 Standard query 0x0003 A 164.netflix.WiCys.in
    5   0.000947 192.168.1.27 → 192.168.1.1  DNS 66 Standard query 0x0004 A 146.google.WiCys.com
    6   0.001260 192.168.1.27 → 192.168.1.1  DNS 63 Standard query 0x0005 A 
    ...
```

The interesting part seems to be the `subdomains` which are numbers. After some trial and error the numbers turned out to be [`octal numbers`](https://en.wikipedia.org/wiki/Octal). Converting them gives the flag:

```python
numbers = [0o143, 0o150, 0o143, 0o164, 0o146, 0o173, 0o143, 0o162, 0o63, 0o141, 0o164, 0o60, 0o162, 0o137, 0o60, 0o146, 0o137, 0o144, 0o60, 0o155, 0o141, 0o151, 0o156, 0o137, 0o156, 0o64, 0o155, 0o63, 0o137, 0o163, 0o171, 0o163, 0o164, 0o63, 0o155, 0o175]
print("".join(chr(x) for x in numbers))
```

Flag `chctf{cr3at0r_0f_d0main_n4m3_syst3m}`