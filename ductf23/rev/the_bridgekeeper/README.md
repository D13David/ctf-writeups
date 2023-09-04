# DownUnderCTF 2023

## the bridgekeepers 3rd question

> What is your name? What is your quest? What is your favourite colour?
>
>  Author: hashkitten
>

Tags: _rev_

## Solution
We are provided with a small web application. After opening the link we can click `click here to cross`. Afterwards the bridgekeeper will ask three questions: `What is your name?`, `What is your quest?` and `What is your favourite colour?`. After entering some random values we get the answer `you have been cast into the gorge`... That didnt work.

Opening the page source we see the following script
```html
<script id="challenge" src="text/javascript">
    function cross() {
      prompt("What is your name?");
      prompt("What is your quest?");
      answer = prompt("What is your favourite colour?");
      if (answer == "blue") {
        document.getElementById('word').innerText = "flag is DUCTF{" + answer + "}";
        cross = escape;
      }
      else {
        document.getElementById('word').innerText = "you have been cast into the gorge";
        cross = unescape;
      }
    }
  </script>
```

Thats easy, the name and quest are not relevant but the favourite colour needs to be `blue`. Lets try this: `you have been cast into the gorge`... Something is fishy here. After opening the development tools and going to `Sources` tab we find another script.

```js
prompt = function (fun, x) {
  let answer = fun(x);
  
  if (!/^[a-z]{13}$/.exec(answer)) return "";

  let a = [], b = [], c = [], d = [], e = [], f = [], g = [], h = [], i = [], j = [], k = [], l = [], m = [];
  let n = "blue";
  a.push(a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, b, a, a, a, a, a, a, a, a);
  b.push(b, b, b, b, c, b, a, a, b, b, a, b, a, b, a, a, b, a, b, a, a, b, a, b, a, b);
  c.push(a, d, b, c, a, a, a, c, b, b, b, a, b, c, a, b, b, a, c, c, b, a, b, a, c, c);
  d.push(c, d, c, c, e, d, d, c, c, c, c, b, c, c, d, c, b, d, a, d, c, c, c, a, d, c);
  e.push(a, e, f, c, d, e, a, e, c, d, c, c, c, d, a, e, b, b, a, d, c, e, b, b, a, a);
  f.push(f, d, g, e, d, e, d, c, b, f, f, f, a, f, e, f, f, d, a, b, b, b, f, f, a, f);
  g.push(h, a, c, c, g, c, b, a, g, e, e, c, g, e, g, g, b, d, b, b, c, c, d, e, b, f);
  h.push(c, d, a, e, c, b, f, c, a, e, a, b, a, g, e, i, g, e, g, h, d, b, a, e, c, b);
  i.push(h, a, d, b, d, c, d, b, f, a, b, b, i, d, g, a, a, a, h, i, j, c, e, f, d, d);
  j.push(b, f, c, f, i, c, b, b, c, j, i, e, e, j, g, j, c, k, c, i, h, g, g, g, a, d);
  k.push(i, k, c, h, h, j, c, e, a, f, f, h, e, g, c, l, c, a, e, f, d, c, f, f, a, h);
  l.push(j, k, j, a, a, i, i, c, d, c, a, m, a, g, f, j, j, k, d, g, l, f, i, b, f, l);
  m.push(c, c, e, g, n, a, g, k, m, a, h, h, l, d, d, g, b, h, d, h, e, l, k, h, k, f);

  walk = a;

  for (let c of answer) {
    walk = walk[c.charCodeAt() - 97];
  }

  if (walk != "blue") return "";

  return {toString: () => _ = window._ ? answer : "blue"};

}.bind(null, prompt);

eval(document.getElementById('challenge').innerText);
```

So the `prompt` is customized in some way. The code creates a 13x26 matrix of values. The items are references to other matrix rows except one, `m[4]` references the value `blue`.

The flow is as follows. The initial row is `a`, then for each character in the answer the next referenced column is chosen that is located at the index of the lower case character within the current row. Since we know we want to end with the value `blue` which is located in `m[4]` we can work our way backwards through the matrix.

```
        00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
a       a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, b, a, a, a, a, a, a, a, a
b       b, b, b, b, c, b, a, a, b, b, a, b, a, b, a, a, b, a, b, a, a, b, a, b, a, b
c       a, d, b, c, a, a, a, c, b, b, b, a, b, c, a, b, b, a, c, c, b, a, b, a, c, c
d       c, d, c, c, e, d, d, c, c, c, c, b, c, c, d, c, b, d, a, d, c, c, c, a, d, c
e       a, e, f, c, d, e, a, e, c, d, c, c, c, d, a, e, b, b, a, d, c, e, b, b, a, a
f       f, d, g, e, d, e, d, c, b, f, f, f, a, f, e, f, f, d, a, b, b, b, f, f, a, f
g       h, a, c, c, g, c, b, a, g, e, e, c, g, e, g, g, b, d, b, b, c, c, d, e, b, f
h       c, d, a, e, c, b, f, c, a, e, a, b, a, g, e, i, g, e, g, h, d, b, a, e, c, b
i       h, a, d, b, d, c, d, b, f, a, b, b, i, d, g, a, a, a, h, i, j, c, e, f, d, d
j       b, f, c, f, i, c, b, b, c, j, i, e, e, j, g, j, c, k, c, i, h, g, g, g, a, d
k       i, k, c, h, h, j, c, e, a, f, f, h, e, g, c, l, c, a, e, f, d, c, f, f, a, h
l       j, k, j, a, a, i, i, c, d, c, a, m, a, g, f, j, j, k, d, g, l, f, i, b, f, l
m       c, c, e, g, n, a, g, k, m, a, h, h, l, d, d, g, b, h, d, h, e, l, k, h, k, f

a[17] -> b[4] -> c[1] -> d[4] -> e[2] -> f[2] -> g[0] -> h[15] -> i[20] -> j[17] -> k[15] -> l[11] -> m[4]
```

Giving us the indices `17, 4, 1, 4, 2, 2, 0, 15, 20, 17, 15, 11, 4` which correspond to `rebeccapurple` which lets us pass the gatekeeper and gives the flag `flag is DUCTF{rebeccapurple}`.

Flag `DUCTF{rebeccapurple}`