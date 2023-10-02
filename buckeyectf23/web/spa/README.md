# BuckeyeCTF 2023

## Spa

> Enjoy a relaxing visit to our spa.
>
>  Author: mbund
>

Tags: _web_

## Solution
If we inspect the source code of the provided website we can find the following in `/assets/index-65f76711.js`:

```js
const ag = "YmN0Zns3aDNfdWw3MW00NzNfNXA0XzE1XzRfcjM0YzdfNXA0fQo=";
function cg() {
    const e = ch({
        queryKey: ["admin"],
        queryFn: ()=>fetch("/api/isAdmin").then(t=>t.json())
    });
    return e.data === void 0 || !e.data.isAdmin ? $.jsx($.Fragment, {
        children: "Unauthorized"
    }) : $.jsx($.Fragment, {
        children: $.jsxs("div", {
            id: "ocean",
            className: "full vignette",
            children: [$.jsx(fh, {}), $.jsxs("div", {
                className: "content",
                children: [$.jsx("h1", {
                    children: "Admin page"
                }), $.jsx("p", {
                    children: atob(ag)
                })]
            })]
        })
    })
}
```

The website queries the backend for admin status. The status is not given but the flag, which is displayed on the `Admin page` is hardcoded into the javascript and we can retrieve it by just decoding from base64.

```js
> atob("YmN0Zns3aDNfdWw3MW00NzNfNXA0XzE1XzRfcjM0YzdfNXA0fQo=")
<'bctf{7h3_ul71m473_5p4_15_4_r34c7_5p4}\n'
```

Flag `bctf{7h3_ul71m473_5p4_15_4_r34c7_5p4}`