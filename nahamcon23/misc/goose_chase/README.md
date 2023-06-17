# NahamCon 2023

## Goose Chase

> I am truly sorry. I really do apologize... I hope you can bear with me as I set you all loose together, on a communal collaboriative wild goose chase.
>
>  Author: @JohnHammond#6971
>

Tags: _misc_

## Solution
A link to a google sheet is given. When opened the sheet seems empty. Creating a copy of the sheet gives access to a second tab `The Way to the Goose`. This tab also seems empty. Showing formulas reveales one cell with content:

```
=IMPORTRANGE("https://docs.google.com/spreadsheets/d/1zKlRsajdRbQWrGq8XcsM0fC-fVplcVPXRQ7ZLR85J3s/","Goose Chase!A1")
```

Following this link and creating a copy of the sheet fails due to a strange filename. Inspecting the filename reveals the flag.

Flag `flag{323264294cc2a4ebb2c8d5f9e0afb0f7}`