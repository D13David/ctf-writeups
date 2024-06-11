# BCACTF 5.0

## flagserver

> It looks like Ircus have been using a fully exposed application to access their flags! Look at this traffic I captured. I can't seem to get it to work, though... can you help me get the flag for this very challenge?
> 
> NOTE: During normal operation, directly connecting to flagserver using nc should give some nonprintable characters like ��. If instead you receive nothing, please let us know.
> 
> Author: Marvin
> 
> [`flagserver.pcapng`](flagserver.pcapng)

Tags: _forensics_

## Solution
For this challenge we get a network traffic capture. Its very short, only a few packets send over a `TCP` connection.

```bash
$ tshark -r flagserver.pcapng
    1 0.000000000    10.0.2.15 → 192.168.1.178 TCP 74 35668 → 54323 [SYN] Seq=0 Win=32120 Len=0 MSS=1460 SACK_PERM TSval=2632428447 TSecr=0 WS=128
    2 0.000544491 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
    3 0.000585578    10.0.2.15 → 192.168.1.178 TCP 54 35668 → 54323 [ACK] Seq=1 Ack=1 Win=32120 Len=0
    4 0.001072772 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [PSH, ACK] Seq=1 Ack=1 Win=65535 Len=4
    5 0.001089273    10.0.2.15 → 192.168.1.178 TCP 54 35668 → 54323 [ACK] Seq=1 Ack=5 Win=32116 Len=0
    6 0.003468506    10.0.2.15 → 192.168.1.178 TCP 58 35668 → 54323 [PSH, ACK] Seq=1 Ack=5 Win=32116 Len=4
    7 0.003816509 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [ACK] Seq=5 Ack=5 Win=65535 Len=0
    8 2.395024535    10.0.2.15 → 192.168.1.178 TCP 128 35668 → 54323 [PSH, ACK] Seq=5 Ack=5 Win=32116 Len=74
    9 2.395424746 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [ACK] Seq=5 Ack=79 Win=65535 Len=0
   10 2.395475982    10.0.2.15 → 192.168.1.178 TCP 87 35668 → 54323 [PSH, ACK] Seq=79 Ack=5 Win=32116 Len=33
   11 2.395690354 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [ACK] Seq=5 Ack=112 Win=65535 Len=0
   12 2.399239321    10.0.2.15 → 192.168.1.178 TCP 68 35668 → 54323 [PSH, ACK] Seq=112 Ack=5 Win=32116 Len=14
   13 2.399599687 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [ACK] Seq=5 Ack=126 Win=65535 Len=0
   14 2.400394868 192.168.1.178 → 10.0.2.15    TCP 124 54323 → 35668 [PSH, ACK] Seq=5 Ack=126 Win=65535 Len=70
   15 2.400551362 192.168.1.178 → 10.0.2.15    TCP 109 54323 → 35668 [PSH, ACK] Seq=75 Ack=126 Win=65535 Len=55
   16 2.400551502 192.168.1.178 → 10.0.2.15    TCP 60 54323 → 35668 [FIN, ACK] Seq=130 Ack=126 Win=65535 Len=0
   17 2.444767501    10.0.2.15 → 192.168.1.178 TCP 54 35668 → 54323 [ACK] Seq=126 Ack=131 Win=31990 Len=0
```

So lets inspect what data is send.

```bash
$ tshark -r flagserver.pcapng -T fields -e data | while read -r line; do echo "$line" | xxd -r -p | hexdump -C; done
00000000  ac ed 00 05                                       |....|
00000004
00000000  ac ed 00 05                                       |....|
00000004
00000000  73 72 00 1e 66 6c 61 67  73 65 72 76 65 72 2e 4d  |sr..flagserver.M|
00000010  65 73 73 61 67 65 43 74  6f 53 5f 52 65 71 75 65  |essageCtoS_Reque|
00000020  73 74 bd 16 41 55 d7 60  d5 a3 02 00 01 4c 00 05  |st..AU.`.....L..|
00000030  63 68 61 6c 6c 74 00 12  4c 6a 61 76 61 2f 6c 61  |challt..Ljava/la|
00000040  6e 67 2f 53 74 72 69 6e  67 3b                    |ng/String;|
0000004a
00000000  78 72 00 12 66 6c 61 67  73 65 72 76 65 72 2e 4d  |xr..flagserver.M|
00000010  65 73 73 61 67 65 90 d2  1c c7 18 e8 9c 16 02 00  |essage..........|
00000020  00                                                |.|
00000021
00000000  78 70 74 00 09 66 61 6b  65 63 68 61 6c 6c        |xpt..fakechall|
0000000e
00000000  73 72 00 1b 66 6c 61 67  73 65 72 76 65 72 2e 4d  |sr..flagserver.M|
00000010  65 73 73 61 67 65 53 74  6f 43 5f 46 6c 61 67 ec  |essageStoC_Flag.|
00000020  49 c1 40 5d 2f e2 0b 02  00 01 4c 00 04 66 6c 61  |I.@]/.....L..fla|
00000030  67 74 00 12 4c 6a 61 76  61 2f 6c 61 6e 67 2f 53  |gt..Ljava/lang/S|
00000040  74 72 69 6e 67 3b                                 |tring;|
00000046
00000000  78 72 00 12 66 6c 61 67  73 65 72 76 65 72 2e 4d  |xr..flagserver.M|
00000010  65 73 73 61 67 65 90 d2  1c c7 18 e8 9c 16 02 00  |essage..........|
00000020  00 78 70 74 00 11 62 63  61 63 74 66 7b 66 61 6b  |.xpt..bcactf{fak|
00000030  65 5f 66 6c 61 67 7d                              |e_flag}|
00000037
```

Looks like the client sent commands to the server requesting the server to send the `fakechall` flag. Interesting, the strings á la `java/lang/String` suggest java serialized data. But we don't need to reverse this or reproduce this. What we do is to grab the traffic as we have it here and send it to the server to see if we get the same feedback. And in fact, it workes like a charm.

Now we don't want the fakeflag. But we can assume a few things. The first bytes look like some sort of `command` the server reacts to and the rest could be parameters. For instance, `xpt..fakechall` sends the name of the flag that is requested. The two bytes before the parameter are `00 09` which is the length of the strings. What we can do is to just send `xpt flagserver` and hope the flag will be returned. For this we write a small script.

```python
from pwn import *

p = remote("challs.bcactf.com", 30134)

context.log_level = "DEBUG"

def send(cmd, param, payload=None):
    data = bytearray(cmd.encode())
    data.extend(len(param).to_bytes(2))
    data.extend(param.encode())
    if payload != None:
        data.extend(payload)
    p.send(data)

data = p.recv()
p.send(data)
p.send(b"sr\x00\x1eflagserver.MessageCtoS_Request\xbd\x16AU\xd7`\xd5\xa3\x02\x00\x01L\x00\x05challt\x00\x12Ljava/lang/String;")
p.send(b"xr\x00\x12flagserver.Message\x90\xd2\x1c\xc7\x18\xe8\x9c\x16\x02\x00\x00")
#p.send(b"xpt\x00\x09fakechall")
send("xpt", "flagserver")
```

And yes, we get the flag.

```bash
$ python foo.py
[+] Opening connection to challs.bcactf.com on port 30134: Done
[+] Receiving all data: Done (165B)
[*] Closed connection to challs.bcactf.com port 30134
b'sr\x00\x1bflagserver.MessageStoC_Flag\xecI\xc1@]/\xe2\x0b\x02\x00\x01L\x00\x04flagt\x00\x12Ljava/lang/String;xr\x00\x12flagserver.Message\x90\xd2\x1c\xc7\x18\xe8\x9c\x16\x02\x00\x00xpt\x009bcactf{thankS_5OCK3ts_and_tHreADInG_clA5s_2f6fb44c998fd8}'
```

Flag `bcactf{thankS_5OCK3ts_and_tHreADInG_clA5s_2f6fb44c998fd8}`