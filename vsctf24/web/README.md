# vsCTF 2024

## spinner

> angstromctf's spinner was too easy... and not annoying enough
>
>  Author: jayden
>
> [`spinner.zip`](spinner.zip)

Tags: _web_

## Solution
For this challenge we get a link and the source to a small web app. After opening the app we see a red dot and the number 0. Opening the page source gives us the following code for the client.

```js
const centerX = window.innerWidth / 2;
const centerY = window.innerHeight / 2;
const centerPoint = document.getElementById('centerPoint');
const spinCountDiv = document.getElementById('spinCount');
centerPoint.style.left = centerX - 5 + 'px';
centerPoint.style.top = centerY - 5 + 'px';

const socket = new WebSocket(`wss://${window.location.host}/ws`);

socket.addEventListener('open', () => {
    console.log('connected');
});

socket.addEventListener('message', (event) => {
    const data = JSON.parse(event.data);
    if (data.spins !== undefined) {
        spinCountDiv.textContent = `${data.spins}`;
    }
    if (data.message) {
        alert(data.message);
    }
});

document.addEventListener('mousemove', (event) => {
    const { clientX, clientY } = event;
    const message = {
        x: clientX,
        y: clientY,
        centerX: centerX,
        centerY: centerY
    };
    socket.send(JSON.stringify(message));
});
```

So, communication happens over a websocket. The client sends messages to the server, whenever the mouse moves, containing the mouse position and the window center point. Also the client reacts on server messages, setting the counter to `spins` or, if a message was send, displaying an alert with the message.

Lets see what the server does. The major part of the logic is within the `message` event handler.

```js
ws.on('message', (message) => {
        const data = JSON.parse(message);
        const client = clients.get(ws);

        if (client) {
            const { x, y, centerX, centerY } = data;

            if (client.touchedPoints.some(point => point.x === x && point.y === y)) {
                return;
            }

            client.touchedPoints.push({ x, y });

            const currentAngle = Math.atan2(y - centerY, x - centerX) * (180 / Math.PI);

            if (client.lastAngle !== null) {
                let delta = currentAngle - client.lastAngle;
                if (delta > 180) delta -= 360;
                if (delta < -180) delta += 360;
                client.cumulativeAngle += delta;

                while (Math.abs(client.cumulativeAngle) >= 360) {
                    client.cumulativeAngle -= 360 * Math.sign(client.cumulativeAngle);
                    client.spins += 1;
                }

                ws.send(JSON.stringify({ spins: client.spins }));

                if (client.spins >= 9999) {
                    ws.send(JSON.stringify({ message: process.env.FLAG ?? "vsctf{test_flag}" }));
                    client.spins = 0;
                }
            }

            client.lastAngle = currentAngle;
        }
    });
```

Right, the server calculates the angle between the x axis through the center point and the vector from center point to mouse position. It tracks then if the angle increases and after one full spin the `spins` property in client data is increased by one. Also client data is send back as a answer to a received packet. Interestingly the server tracks mouse coordinates. Already known coordinates are just silently discarded. When `spins` grows greater or equal `9999` the flag is send per message attribute.

The idea here is to rotate a point in a circle around the center point and send the coordinates per script. The number of points on the circle sent can be very sparse as it still meets the condition of increasing angle and we don't want to send too many packets for just one spin (remember, we need 9999 spins in total). Since the points are tracked we cannot reuse them more than once, but instead we increase the circle radious giving us a whole set of new points.

After spiraling enough times, we get the flag. The following code can easily pasted into the debugger console and will use the already available websocket connection to communicate.

```js
function message(angle, radius) {
    let cx = Math.cos(Math.PI*2*angle/360) * radius;
    let cy = Math.sin(Math.PI*2*angle/360) * radius;
    return {
        x: centerX+cx,
        y: centerY+cy,
        centerX: centerX,
        centerY: centerY
    }
}

for (let rad = 1; rad <= 1100; rad += 0.1) {
    for (let angle = 0; angle <= 360.0; angle += 90.0) {
        socket.send(JSON.stringify(message(angle, rad)));
    }
}
```

Flag `vsctf{i_ran_out_of_flag_ideas_so_have_this_random_string_2CSJzbfeWqVBnwU5q8}`