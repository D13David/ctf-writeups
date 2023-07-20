# AmateursCTF 2023

## uwuctf

> 
this rust uwuifier is so fast i'm sure it's going to scale to the moon as long as i can dupe my nodes. uwuifier as a service pro subscription when?
>
> update: the zip is nearly the same as the server except we removed the challenge.yml and flag.txt
>
>  Author: smashmaster
>
> [`uwuaas.zip`](uwuaas.zip)

Tags: _web_

## Solution
For this challenge a webservice with source code is given. When opening the `url` the service prints a simple line *uwufier as a service. uwu many documents at a time. [`see the coow diwectowy`](https://uwuasaservice.amt.rs/dir)*. 

The actual `uwufier` is given as binary but the webservice code is available.

```javascript
import {config} from "dotenv";
config();

import fs from "fs";
import path from "path";

import {quote} from "shell-quote";
import {exec} from "child_process";

const textsDir = path.join(process.cwd(), "public", "texts");
const uwuifierPath = path.join(process.cwd(),"uwuify");

import express from "express";
const app = express();

import morgan from "morgan";
app.set('trust proxy', ['loopback', 'linklocal', 'uniquelocal']);
app.use(morgan("combined"));

app.get("/", (req, res) => {
  res.sendFile("public/index.html", {
    root: process.cwd() // bug fix
  });
});


app.get("/uwuify", (req, res) => {
  res.type("txt");
  if(req.query.src){
    if(req.query.src.includes("..") || req.query.src.includes("./") || req.query.src.startsWith("/") || req.query.src.startsWith("-")){
      res.send("no hacking >:(");
      res.end();
      return;
    }
    let cmd = "cat " + quote([req.query.src]) + " | " + uwuifierPath;
    exec(cmd, {
      cwd: textsDir
    }, (err, stdout, stderr) => {
      res.send(stdout + stderr);
      res.end();
    });
  }else{
    res.send("no src provided");
  }
});

app.get("/dir", async (req, res) => {
    res.type("txt");
    let output = "texts avali to uwuify: ";
    let files = await fs.promises.readdir(textsDir);
    for(let file of files){
        output += "\r\n" + file;
    }
    output += "\r\n\r\nUse /uwuify?src=<text file name> to uwuify a text file!";
    res.send(output);
});

app.listen(process.env.PORT || 3000, () => {
  console.log("Server Up!");
});
```

The root and `/dir` endpoint we already found. The last endpoint is `/uwuify` which requires a path to a file as `src` parameter. The file is then `uwuified` and printed to the user.

There is some basic filtering which disallows using `..`, `./` or starting the path with `/` or `-` but since the `src` is parsed to `cat` we can access the current home directory by giving `~`.

```Dockerfile
FROM node:16
COPY ./* /home/node/app/
COPY ./public/* /home/node/app/public/
COPY ./public/texts/* /home/node/app/public/texts/
WORKDIR /home/node/app
RUN npm install
ENV PORT=8082
RUN chown -R node:node /home/node/app
USER node
CMD ["bash", "launch.sh"]
EXPOSE 8082
```

From the Dockerfile we can see that the home directory is located at `/home/node` but the application content is in `/home/node/app`.

Calling `https://uwuasaservice.amt.rs/uwuify?src=~/app/flag.txt` leads the uwuified flag `amateuwsctf{so_wmao_this_fwag_is_gonna_be_a_wot_wongew_than_most_fwag_othew_fwags_good_wuck_have_fun_decoding_it_end_of_fwag}`. After `deuwuifying` the flag can be submitted.

Flag `amateursCTF{so_lmao_this_flag_is_gonna_be_a_lot_longer_than_most_flag_other_flags_good_luck_have_fun_decoding_it_end_of_flag}`