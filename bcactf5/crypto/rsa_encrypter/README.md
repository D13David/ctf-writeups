# BCACTF 5.0

## RSAEncrypter

> I made an rsa encrypter to send my messages but it seems to be inconsistent...
> 
> Author: Zevi
> 
> [`rsa_encrypter.py`](rsa_encrypter.py)

Tags: _crypto_

## Solution
For this challenge we get a short python script. The server can be reached via netcat.

```bash
Return format: (ciphertext, modulus)
(138721135236398000743477256720314744033797120866782581741537144551123315770740887450256340913438087242044882346987807061379319293176666978221911422551635829686689141525762200755678673361025621995823072492630580151353410444002904446929815269913458353141279876070626278237350845309040125434239327934451405101541, 163293324572471974860763491665753119042166575797886383956280750769219841819130142082847962462713761475693354738066585154830857456017476821929705232644143123503824733153001952310685896819213184591935227753703520391548761583192593219722906421971627270670819298365922516069245921529899515253966950919063436044767)
Did you recieve the message? (y/n)
```

We can hit `n` if we want to get another message or `y` if we want to shutdown the program. The code basically does send us the flag `RSA` encrypted, and calculates for every iteration a new modulo. The exponent `e` is small with `3`, that smells like a good target.

```python
def encode():
    n = getPrime(512)*getPrime(512)
    ciphertext = pow(bytes_to_long(message), 3, n)
    return (ciphertext, n)

print("Return format: (ciphertext, modulus)")
print(encode())
sent = input("Did you recieve the message? (y/n) ")
while sent=='n':
    print(encode())
    sent = input("How about now? (y/n) ")
print("Message acknowledged.")
```

With a small `e` like this a [`small e attack`](https://ir0nstone.gitbook.io/crypto/rsa/public-exponent-attacks/small-e) could be an option, but doesn't work in this case. Another option is [`Multi-party RSA with small e`](https://ir0nstone.gitbook.io/crypto/rsa/public-exponent-attacks/multi-party-rsa-with-small-e) that assumes the same message was encrypted and send to different parties with the same exponent. In this case the [`Chinese Remainder Theorem`](https://en.wikipedia.org/wiki/Chinese_remainder_theorem) can be used to retrieve the original message. This matches our conditions, since we can request the encrypted message multiple times.

Lets assume we have three encryted messages `c1 = m^e mod n1`, `c2 = m^e mod n2` and `c3 = m^e mod n3`. With the `CRT` we can solve this congruence `m^e mod n1*n2*n3`, once this is done the message can be retrieved by taking the `eth root` of the result.

```python
import libnum
from Crypto.Util.number import long_to_bytes

c1, n1 = (12871585032533739437191837955496255684425067530637608272663440243182294689850656596890093247135660189544437076153836340452319605263671148514835959669406594457400791049649676473389434455381150668579750859165895562916482454954939578330326278806930479479848742819105359470013010977932647661694961824514119378505, 81470204285080990649965496894880177637413971143139914903358689628334607374832957648939588064116507754249849459081907041810237099118868704801315192127741115353020936604859156228631460192077258768772319438782340055824142757856652351193329332849019276117905296293123853215913291827055462415723530849235670283451)
c2, n2 = (93557011972751139795394717158248343266363469645457091888037952658439865629091183898788892615699037919030906325851033532044532211413932914635135023735600812496768126964432959053399025003226733533759429969162009801639209929709944690979666141701233655835254764653484205863649770899431291581647511087760057296718, 161861087411760439445859209706537325944235123221536332362459723077406649444348367158013067110390789771685732497868134250480568984019992832959434779844211300153120975641968727118937236151800864107451916243621942112015549481387595908144687298501395812078099325442616315183549933117454703780313402385276358093483)
c3, n3 = (28789102249180553407387355784729441165762941517961505946084465521385661743500397467863681694132139180276056362067795304841604460915340303183440524740242586583310945427374495017839016447422081752325726150524445526444815671689204040100389096188402626438280516207526642668595675978918803977192712176580579536343, 52779768500564689634878365390450464769387557534239387402924902682213328805153640134420218158903396700894603662175056766121173363481945197269382950008648859919060036413939174214787930561353881710533774524552398192394307010822527009557801917766246794263953455653511003348402005061808299661148385774070508793451)

N = [n1, n2, n3]
C = [c1, c2, c3]

res = libnum.solve_crt(C, N)
val = libnum.nroot(res, 3)
print(long_to_bytes(val))
```

Flag `bcactf{those_were_some_rather_large_numbersosvhb9wrp8ghed}`