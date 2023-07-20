# AmateursCTF 2023

## Painfully Deep Flag

> This one is a bit deep in the stack.
>
>  Author: smashmaster
>
> [`flag.pdf`](flag.pdf)

Tags: _forensics_

## Solution
For this challenge a `pdf` is given. Opening the file doesn't lead to good results. Also some typical things like `strings` or `binwalk` don't give anything useful. Next we can try to inspect the XObjects stored inside the pdf. For this [`pdfreader`](https://pdfreader.readthedocs.io/) is very helpful.

```python
from pdfreader import PDFDocument

doc = PDFDocument(open("flag.pdf", "rb"))

page = next(doc.pages())
index = 0
for _, obj in page.Resources.XObject.items():
    print(obj.Subtype)
    if obj.Subtype == "Image":
        img = obj.to_Pillow()
        img.save("image" + str(index) + ".png")
        index += 1
```

We can see there are two `Image` and one `Form` objects on the first page. The image objects could be interesting. For this reason we extract them and sure enough, the flag is stored in one of them.

![](image0.png)

Flag `amateursCTF{0ut_0f_b0unds}`