# SunshineCTF 2023

## Dill

> Originally this was going to be about pickles, but .pyc sounds close enough to "pickles" so I decided to make it about that instead.
> 
>  Author: N/A
>
> [`dill.cpython-38.pyc`](dill.cpython-38.pyc)

Tags: _rev_

## Solution
For this challenge we get some compiled bytecode. We easily can decompile this by using [`pycdc`](https://github.com/zrax/pycdc).

```python
class Dill:
    prefix = 'sun{'
    suffix = '}'
    o = [
        5,
        1,
        3,
        4,
        7,
        2,
        6,
        0]

    def __init__(self = None):
        self.encrypted = 'bGVnbGxpaGVwaWNrdD8Ka2V0ZXRpZGls'


    def validate(self = None, value = None):
        if not value.startswith(Dill.prefix) or value.endswith(Dill.suffix):
            return False
        value = None[len(Dill.prefix):-len(Dill.suffix)]
        if len(value) != 32:
            return False
        c = (lambda .0 = None: [ value[i:i + 4] for i in .0 ])(range(0, len(value), 4))
        value = None((lambda .0 = None: [ c[i] for i in .0 ])(Dill.o))
        if value != self.encrypted:
            return False
```

The `validate` function takes some input, encrypts it and checks if the encrypted value is the same as what is in `self.encrypted`. We have to find a value that matches then. The first condition (which the decompiler failed to understand) is that the input is pre- and suffixed with `sun{` respectively `}`. Then a `32` byte long value is expected that is seperated in 4 character chunks and reordered with help of the indirection table `o`.

This is easy to reverse, we take the `encrypted` version, split in 4 character chunks and inverse the ordering. If we do so, we get `ZGlsbGxpa2V0aGVwaWNrbGVnZXRpdD8K`. This is base64 encoded and decodes to `dilllikethepicklegetit?`. Submitting this as flag is not accepted, but submitting the base64 encoded version is.

Flag `sun{ZGlsbGxpa2V0aGVwaWNrbGVnZXRpdD8K}`