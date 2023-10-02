# BuckeyeCTF 2023

## Skribl

> The modern paste service for the New World.
>
>  Author: rene
>
> [`dist.zip`](dist.zip)

Tags: _rev_

## Solution
This challenge is provided with a zip archive. After unzipping we find the source for a small web application. The same container is also hosted on the ctf infrastructure. To inspect a bit further we open the provided link and can see that users can submit a `message` and a `name`. After pressing submit the submitted message is shown on another page. 

For each message a identifier is generated. Entering the same message/name combination still gets a different identifier, so there seems to be some randomness in it and/or the message/name pair is not part of the identifier. Lets inspect the source code to see whats going on.

```python
@app.route('/', methods=['GET', 'POST'])
def index():
    form = SkriblForm()
    message = ""
    if form.validate_on_submit():
        message = form.skribl.data
        author = form.author.data

        key = create_skribl(skribls, message, author)
        return redirect(url_for('view', key=key))

    return render_template('index.html', form=form, error_msg=request.args.get("error_msg", ''))
```

The code calls `create_skribl` and the `key` is retrieved, then the page forwards to `view` the message by calling the second route.

```python
@app.route('/view/<key>', methods=['GET'])
def view(key):
    print(f"Viewing with key {key}")
    if key in skribls:
        message, author = skribls[key]
        return render_template("view.html", message=message, author=author, key=key)
    else:
        return redirect(url_for('index', error_msg=f"Skribl not found: {key}"))
```

So a array of scribbles is tracked and we need the correct key for lookup. The problem is the function `create_skribl` is within another module and we don't have the source code for this. 

Moving on with the inspection wie find `__pycache__` and within some compiled python bytecode for the modules `skribl` and `backend`. Perfect, someone "forgot" to remove the intermediate build result and we can just decompile the bytecode. 

```bash
$ pycdc backend.cpython-313.pyc
Bad MAGIC!
Could not load file backend.cpython-313.pyc
```

Pycdc tells us `no`. This is not surprising since the python bytecode was compiled with python version `3.13` which is currently only available as development build. What we can do is to update `decompyle++` to support the [`updated opcodes`](https://github.com/python/cpython/blob/main/Include/opcode_ids.h) so we can at least use the disassemble functionality (without installing python 3.13 which we could do as well). After adding support `pycdas` gives us the [following disassembly](`backend_dasm.txt`). Interesting are the parts for `create_skribl` and `init_backend`.

```python
0       RESUME
2       LOAD_GLOBAL                   0: random
12      LOAD_ATTR                     2: seed
32      PUSH_NULL
34      LOAD_GLOBAL                   4: math
44      LOAD_ATTR                     6: floor
64      PUSH_NULL
66      LOAD_GLOBAL                   8: time
76      LOAD_ATTR                     8: time
96      PUSH_NULL
98      CALL                          0
106     CALL                          1
114     CALL                          1
122     POP_TOP
124     LOAD_GLOBAL                   11: NULL + create_skribl
134     LOAD_FAST                     0: skribls
136     LOAD_GLOBAL                   12: os
146     LOAD_ATTR                     14: environ
166     LOAD_CONST                    1: 'FLAG'
168     BINARY_SUBSCR
172     LOAD_CONST                    2: 'rene'
174     CALL                          3
182     POP_TOP
184     RETURN_CONST                  0
```

The function `init_backend` translates roughly to this:

```python
import random
import math
import time
import os
random.seed(math.floor(time.time()))
create_skribl("rene", os.environ["FLAG"])
```

This is nice, we have two things to note here. First the random number generate is initialized with the current time (in second precision), second a scribble for user `rene` is created and the message is the flag. This means, we have to generate the matching key for exactly this scribble. Lets inspect how keys are generated.

```python
0       RESUME
2       LOAD_GLOBAL                   1: NULL + print
12      LOAD_CONST                    1: 'Creating skribl '
14      LOAD_FAST                     1: message
16      FORMAT_SIMPLE                 0
18      BUILD_STRING                  2
20      CALL                          1
28      POP_TOP
30      LOAD_GLOBAL                   2: string
40      LOAD_ATTR                     4: ascii_lowercase
60      LOAD_GLOBAL                   2: string
70      LOAD_ATTR                     6: ascii_uppercase
90      BINARY_OP                     0 (+)
94      LOAD_GLOBAL                   2: string
104     LOAD_ATTR                     8: digits
124     BINARY_OP                     0 (+)
128     STORE_FAST                    3: alphabet
130     LOAD_GLOBAL                   11: NULL + range
140     LOAD_CONST                    2: 40
142     CALL                          1
150     GET_ITER
152     LOAD_FAST_AND_CLEAR
154     SWAP                          2
156     BUILD_LIST
158     SWAP                          2
160     FOR_ITER                      25 (to 212)
164     STORE_FAST                    4: i
166     LOAD_GLOBAL                   12: random
176     LOAD_ATTR                     14: choice
196     PUSH_NULL
198     LOAD_FAST                     3: alphabet
200     CALL                          1
208     LIST_APPEND                   2
210     JUMP_BACKWARD                 27
214     END_FOR
216     STORE_FAST                    5: key_list
218     STORE_FAST                    4: i
220     LOAD_CONST                    3: ''
222     LOAD_ATTR                     17: NULL + join
242     LOAD_FAST                     5: key_list
244     CALL                          1
252     STORE_FAST                    6: key
254     LOAD_FAST_LOAD_FAST
256     BUILD_TUPLE                   2
258     LOAD_FAST_LOAD_FAST
260     STORE_SUBSCR
264     LOAD_FAST                     6: key
266     RETURN_VALUE
268     SWAP                          2
270     POP_TOP
272     SWAP                          2
274     STORE_FAST                    4: i
276     RERAISE                       0
```

This is a bit lenghty so we look at it piece by piece:

```python
0       RESUME
2       LOAD_GLOBAL                   1: NULL + print
12      LOAD_CONST                    1: 'Creating skribl '
14      LOAD_FAST                     1: message
16      FORMAT_SIMPLE                 0
18      BUILD_STRING                  2
20      CALL                          1
28      POP_TOP
```

This first part translates to

```python
print("Creating skribl " + message)
```

```python
30      LOAD_GLOBAL                   2: string
40      LOAD_ATTR                     4: ascii_lowercase
60      LOAD_GLOBAL                   2: string
70      LOAD_ATTR                     6: ascii_uppercase
90      BINARY_OP                     0 (+)
94      LOAD_GLOBAL                   2: string
104     LOAD_ATTR                     8: digits
124     BINARY_OP                     0 (+)
128     STORE_FAST                    3: alphabet
```

The next part initializes a variable called `alphabet`:

```python
alphabet = string.ascii_lowercase + string.ascii_uppercase + string.digits
```

```python
130     LOAD_GLOBAL                   11: NULL + range
140     LOAD_CONST                    2: 40
142     CALL                          1
150     GET_ITER
152     LOAD_FAST_AND_CLEAR
154     SWAP                          2
156     BUILD_LIST
158     SWAP                          2
160     FOR_ITER                      25 (to 212)
164     STORE_FAST                    4: i
166     LOAD_GLOBAL                   12: random
176     LOAD_ATTR                     14: choice
196     PUSH_NULL
198     LOAD_FAST                     3: alphabet
200     CALL                          1
208     LIST_APPEND                   2
210     JUMP_BACKWARD                 27
214     END_FOR
216     STORE_FAST                    5: key_list
218     STORE_FAST                    4: i
```

The next part creates a array of 40 characters and each character is randomly choosen from the `alphabet`.

```python
key_list = [random.choice(alphabet) for i in range(40)]
```

```python
220     LOAD_CONST                    3: ''
222     LOAD_ATTR                     17: NULL + join
242     LOAD_FAST                     5: key_list
244     CALL                          1
252     STORE_FAST                    6: key
254     LOAD_FAST_LOAD_FAST
256     BUILD_TUPLE                   2
258     LOAD_FAST_LOAD_FAST
260     STORE_SUBSCR
264     LOAD_FAST                     6: key
266     RETURN_VALUE
268     SWAP                          2
270     POP_TOP
272     SWAP                          2
274     STORE_FAST                    4: i
276     RERAISE                       0
```

Then the list items are joined to the key string and the message/author pair is written as tuble to the skribls dictionary.

```pyton
key = ''.join(key_list)
skribls[key] = (message, author)
```

Now it also gets clear why the random seed is important. We can in fact generate the correct key if we know what time the flag scribbl was created. And thankfully the web application leaks this info.

```bash
Skribl has be up for 6 hours
```

And even better we get the correct number of uptime seconds from source:

```js
<script>
    stime = moment.duration(20424, 'seconds');
    stime_text = document.getElementById("stime");

    stime_text.outerHTML = stime.humanize()
</script>
```

With this we can create our own key by calculating the timestamp, setting the timestamp as seed and generating the key as reversed above. To cope with small errors we add and give some seconds to our timestamp, but eventually the key is correct and we get the flag.

```python
import string
import random
import requests
import math
from datetime import datetime, timedelta

uptime = 20424 # number of seconds as leaked by the web application

def generate_key():
    alphabet = string.ascii_lowercase + string.ascii_uppercase + string.digits
    return ''.join([random.choice(alphabet) for i in range(40)])

ts = math.floor((datetime.now() - timedelta(seconds=uptime)).timestamp())
for i in range(-4,20):
    print(ts-i)
    random.seed(ts-i)
    key = generate_key()
    resp = requests.get(f"https://skribl.chall.pwnoh.io/view/{key}")
    if "Here is the message for" in resp.text:
        print(resp.text)
```

Flag `bctf{wHy_d0_w3_Ne3d_s0_m@ny_N0T3$_aNyW@y}`