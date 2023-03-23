# Cyber Apocalypse 2023

## Trapped Source

> Intergalactic Ministry of Spies tested Pandora's movement and intelligence abilities. She found herself locked in a room with no apparent means of escape. Her task was to unlock the door and make her way out. Can you help her in opening the door?
>
>  Author: N/A
>

Tags: _web_

## Solution
When opening the hosted site, we see a keypad where we can enter values. By looking at the source code we also see the pin.
```
<script>
        window.CONFIG = window.CONFIG || {
                buildNumber: "v20190816",
                debug: false,
                modelName: "Valencia",
                correctPin: "8291",
        }
</script>
```

![pin](image001.png)