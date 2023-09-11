# CyberHeroines 2023

## Barbara Liskov

> [Barbara Liskov](https://en.wikipedia.org/wiki/Barbara_Liskov) (born November 7, 1939 as Barbara Jane Huberman) is an American computer scientist who has made pioneering contributions to programming languages and distributed computing. Her notable work includes the development of the Liskov substitution principle which describes the fundamental nature of data abstraction, and is used in type theory (see subtyping) and in object-oriented programming (see inheritance). Her work was recognized with the 2008 Turing Award, the highest distinction in computer science. - [Wikipedia Entry](https://en.wikipedia.org/wiki/Barbara_Liskov)
> 
> Chal: Return the flag back to the [2008 Turing Award Winner](https://www.youtube.com/watch?v=_jTc1BTFdIo)
>
>  Author: [Josh](https://github.com/JoshuaHartz)
>
> [`BarbaraLiskov.pyc`](BarbaraLiskov.pyc)

Tags: _forensics_

## Solution
We get some compiled python bytecode for this challenge. We can decompile this code, sadly pycdc struggles with some opcodes. But luckily enough, the important part is visible:

```bash
$ pycdc BarbaraLiskov.pyc
# Source Generated with Decompyle++
# File: BarbaraLiskov.pyc (Python 3.11)

Unsupported opcode: POP_JUMP_FORWARD_IF_FALSE
import base64

def secret_code():
    obfuscated_string = '492d576f6e2d412d547572696e672d4177617264'
    return bytes.fromhex(obfuscated_string).decode('utf-8')


def validate_input(user_input):
Error decompyling BarbaraLiskov.pyc: vector::_M_range_check: __n (which is 1) >= this->size() (which is 1)
```

When converting the secret code to ascii it gives us:

```python
bytes.fromhex("492d576f6e2d412d547572696e672d4177617264")
b'I-Won-A-Turing-Award'
```

With this we can run the script and retrieve the flag:

```bash
$ python BarbaraLiskov.pyc
Enter the digital code >>> I-Won-A-Turing-Award
chctf{u_n3v3r_n33d_0pt1m4l_p3rf0rm4nc3,_u_n33d_g00d-3n0ugh_p3rf0rm4nc3}
```

Flag `chctf{u_n3v3r_n33d_0pt1m4l_p3rf0rm4nc3,_u_n33d_g00d-3n0ugh_p3rf0rm4nc3}`