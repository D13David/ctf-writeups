# Cyber Apocalypse 2024

## Flag Command

> Embark on the "Dimensional Escape Quest" where you wake up in a mysterious forest maze that's not quite of this world. Navigate singing squirrels, mischievous nymphs, and grumpy wizards in a whimsical labyrinth that may lead to otherworldly surprises. Will you conquer the enchanted maze or find yourself lost in a different dimension of magical challenges? The journey unfolds in this mystical escape!
> 
> Author: Xclow3n
> 

Tags: _web_

## Solution
For this challenge we get a `text adventure`-like webapp. After typing in *start* the game begins.

```
YOU WAKE UP IN A FOREST.

You have 4 options!
HEAD NORTH
HEAD SOUTH
HEAD EAST
HEAD WEST
```

In the code, we can see that the game fetches the possible options via `/api/options` endpoint.

```js
const fetchOptions = () => {
    fetch('/api/options')
        .then((data) => data.json())
        .then((res) => {
            availableOptions = res.allPossibleCommands;

        })
        .catch(() => {
            availableOptions = undefined;
        })
}
```

After we enter our command, the program checks if our input is valid for the current step:

```js
async function CheckMessage() {
    fetchingResponse = true;
    currentCommand = commandHistory[commandHistory.length - 1];

    if (availableOptions[currentStep].includes(currentCommand) || availableOptions['secret'].includes(currentCommand)) {
     ...
    }
}
```

So lets see what our options are actually, and most interestingly, what are the `secret` options? After fetching the options via endpoint:

```json
{
  "allPossibleCommands": {
    "1": [
      "HEAD NORTH",
      "HEAD WEST",
      "HEAD EAST",
      "HEAD SOUTH"
    ],
    "2": [
      "GO DEEPER INTO THE FOREST",
      "FOLLOW A MYSTERIOUS PATH",
      "CLIMB A TREE",
      "TURN BACK"
    ],
    "3": [
      "EXPLORE A CAVE",
      "CROSS A RICKETY BRIDGE",
      "FOLLOW A GLOWING BUTTERFLY",
      "SET UP CAMP"
    ],
    "4": [
      "ENTER A MAGICAL PORTAL",
      "SWIM ACROSS A MYSTERIOUS LAKE",
      "FOLLOW A SINGING SQUIRREL",
      "BUILD A RAFT AND SAIL DOWNSTREAM"
    ],
    "secret": [
      "Blip-blop, in a pickle with a hiccup! Shmiggity-shmack"
    ]
  }
}
```

So, why not try out the secret option?

```
>> Blip-blop, in a pickle with a hiccup! Shmiggity-shmack

HTB{D3v3l0p3r_t00l5_4r3_b35t_wh4t_y0u_Th1nk??!}

You escaped the forest and won the game! Congratulations! Press restart to play again.
```

Flag `HTB{D3v3l0p3r_t00l5_4r3_b35t_wh4t_y0u_Th1nk??!}`