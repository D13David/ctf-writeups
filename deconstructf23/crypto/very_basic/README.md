# DeconstruCT.F 2023

## Very Basic

> Sometimes, we need to oscillate To and fro? things become tough when interwoven together.
>
>  Author: N/A
>
> [`Key.txt`](Key.txt)

Tags: _crypto_

## Solution
For this challenge a file with a encrypted value is given. The file is named `Key`, but the value is probably not a key but the flag... Well, going over to CyberChef and trying some base encodings (the title is very *basic*, might be a hint). But with no good result. After the ctf ran for a while and this challenge got no solves another hint was given.

```
Interwoven cipher? Omg I knew it.
```

A google search for `interwoven cipher` led to a huge amount of results containing `Vignère cipher`, for instance [`here`](https://cryptii.com/pipes/vigenere-cipher), giving the information that:

> Method of encrypting alphabetic text by using a series of interwoven Caesar ciphers based on the letters of a keyword

So heading over to CyberChef again and applying `Vignère cipher`, but with what key? Guessing the name of the file could also be an hint I entered `Key` as key. The result still was encrypted. Then I used the `Magic` operator and let CyberChef take the lead. After a couple of tries the following sequence gave the hint:

```
Vigenère_Decode('Key')
From_Base32('A-Z2-7=',false)
From_Base32('A-Z2-7=',false)
From_Base64('A-Za-z0-9+/=',true,false)
From_Base32('A-Z2-7=',false)
From_Base64('A-Za-z0-9+\\-=',true,false)
From_Base32('A-Z2-7=',false)
From_Base64('A-Za-z0-9+/=',true,false)
From_Base32('A-Z2-7=',false)
From_Base32('A-Z2-7=',false)
From_Base64('A-Za-z0-9_.',true,false)

```

Flag `DSC{V17_P0L1CY}`